import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_service.dart';
import '../../../services/local_user_storage.dart';

class PhoneSignupController extends ChangeNotifier {
  // ------------------ PAGE / STATE ------------------
  final page = PageController();
  int step = 0;
  bool busy = false;
  bool otpSent = false;

  // ------------------ CONTROLLERS ------------------
  final phoneCtrl = TextEditingController(text: '');
  final otpCtrl = TextEditingController();

  final pwdCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  final govtIdNumberCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  // ------------------ FORM KEYS ------------------
  final phoneFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  final nameFormKey = GlobalKey<FormState>();

  // ------------------ DATA ------------------
  String? govtIdType;
  bool acceptedTerms = false;

  XFile? profileImage;
  XFile? idProofImage;

  // ------------------ VALIDATORS ------------------
  String? Function(String?) get emailValidator => (v) {
    if (v == null || v.trim().isEmpty) return 'Email required';
    return RegExp(r'^\S+@\S+\.\S+$').hasMatch(v) ? null : 'Invalid email';
  };

  String? Function(String?) get passwordValidator => (v) {
    if (v == null || v.isEmpty) return 'Password required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  };

  // ------------------ NAVIGATION ------------------
  void goToStep(int newStep) {
    if (newStep < 0 || newStep >= SignupStep.total) return;

    step = newStep;
    page.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    notifyListeners();
  }

  void back() {
    if (step == 0) return;
    step--;
    page.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    notifyListeners();
  }
  void showTopToast(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 15),
        Color backgroundColor = Colors.green,
      }) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: AnimatedSlide(
            offset: Offset.zero,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  // ------------------ OTP ------------------
  Future<void> sendOtp(context) async {
    if (!phoneFormKey.currentState!.validate()) return;

    busy = true;
    notifyListeners();

    final res = await ApiService.postFormData(
      endpoint: "/otp/mobile/send",
      fields: {
        "phone_number": phoneCtrl.text.trim(),
        "device_type": "android",
        "device_token": "1234",
        "fcm_token": "1234r4",
      },
    );

    busy = false;

    if (res["success"] == true || res["data"]?["status"] == true) {
      otpSent = true;
      final otp = res["data"]?["otp"]?.toString() ?? "";


      showTopToast(
        context,
        otp,
        duration: const Duration(seconds: 15),
        backgroundColor: Colors.green,
      );
      Fluttertoast.showToast(msg: res["data"]["message"] ?? "OTP sent");
    } else {
      Fluttertoast.showToast(
        msg: res["message"] ?? "Failed to send OTP",
      );
    }

    notifyListeners();
  }

  Future<void> verifyOtp() async {
    if (otpCtrl.text.length != 6) {
      Fluttertoast.showToast(msg: "Enter valid 6-digit OTP");
      return;
    }

    busy = true;
    notifyListeners();

    try {
      final url = Uri.parse("${ApiService.baseUrl}/verify-otp");

      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "phone_number": phoneCtrl.text.trim(),
          "otp": otpCtrl.text.trim(),
        },
      );

      final res = jsonDecode(response.body);

      if (res["success"] == true || res["status"] == true) {
        // Read token from response
        final token = res["api_token"] ?? res["data"]?["api_token"];
        print("token --------- $token");

        if (token != null) {
          await _saveToken(token);
        }

        if (res["data"] != null) {
          await _saveUser(res["data"]);
        }

        Fluttertoast.showToast(msg: "Account created successfully");

        // Navigate to account created step
        Future.delayed(Duration(milliseconds: 100), () {
          goToStep(SignupStep.accountCreated);
        });
      } else {
        Fluttertoast.showToast(msg: res["message"] ?? "Invalid OTP");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong: $e");
      print("❌ Error in verifyOtp: $e");
    } finally {
      busy = false; // ✅ Stop loader no matter what
      notifyListeners();
    }
  }

  // ------------------ SUCCESS SCREEN ACTIONS ------------------
  Future<void> finishAndGoDashboard(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("api_token");

    // Fetch complete profile before going to dashboard
    if (token != null) {
      await _fetchProfile(token);
    }

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
            (_) => false,
      );
    }
  }

  // ------------------ IMAGE PICKERS ------------------
  Future<void> pickGovtIdImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final compressed = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      '${picked.path}_compressed.jpg',
      quality: 70,
    );

    idProofImage = compressed != null ? XFile(compressed.path) : null;
    notifyListeners();
  }

  // ------------------ FINAL SAVE ------------------
  Future<void> saveAndFinish(BuildContext context) async {
    busy = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("api_token");

    final res = await ApiService.multipart(
      endpoint: "/vendor/complete-profile",
      token: token,
      fields: {
        "name": "${firstCtrl.text.trim()} ${lastCtrl.text.trim()}",
        "email": emailCtrl.text.trim(),
        "mobile": phoneCtrl.text.trim(),
        "password": pwdCtrl.text.trim(),
        "password_confirmation": confirmCtrl.text.trim(),
        "gov_id_type": govtIdType ?? "",
        "gov_id_number": govtIdNumberCtrl.text.trim(),
        "city": cityCtrl.text.trim(),
        "country": "india",
        "terms_accepted": acceptedTerms ? "1" : "0",
        "alt_mobile": "1234512345",
        "device_id": "123",
        "device_type": "ios",
        "fcm_token": "1234321",
      },
      files: {
        if (profileImage != null) "profile_photo": File(profileImage!.path),
        if (idProofImage != null)
          "gov_id_document[]": File(idProofImage!.path),
      },
    );

    busy = false;
    notifyListeners();

    if (res["success"] == true) {
      Fluttertoast.showToast(msg: "Profile completed 🎉");

      // Fetch complete profile after successful profile completion
      if (token != null) {
        await _fetchProfile(token);
      }

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
              (_) => false,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: res["message"] ?? "Profile update failed",
      );
    }
  }

  // ------------------ FETCH PROFILE ------------------
  Future<void> _fetchProfile(String token) async {
    try {
      final res = await ApiService.get(
        endpoint: "/get-profile",
        token: token,
      );

      if (res["success"] == true || res["data"]?["status"] == true) {
        // Save complete profile data
        await _saveUser(res["data"]);
        print("✅ Profile data fetched and saved successfully");
      } else {
        print("⚠️ Profile fetch failed: ${res['message']}");
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
    }
  }

  // ------------------ LOCAL STORAGE ------------------
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("api_token", token);
  }

  Future<void> _saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Save complete user data as JSON string
    await prefs.setString("user", jsonEncode(userData));

    // Save individual fields for easy access
    if (userData["id"] != null) {
      await prefs.setInt(
          "user_id", int.tryParse(userData["id"].toString()) ?? 0);
    }

    if (userData["role"] != null) {
      await prefs.setString("user_role", userData["role"].toString());
    }

    if (userData["mobile"] != null) {
      await prefs.setString("user_mobile", userData["mobile"].toString());
    }

    if (userData["email"] != null) {
      await prefs.setString("user_email", userData["email"].toString());
    }

    if (userData["name"] != null) {
      await prefs.setString("user_name", userData["name"].toString());
    }

    if (userData["api_token"] != null) {
      await prefs.setString("api_token", userData["api_token"].toString());
    }

    if (userData["status"] != null) {
      await prefs.setString("user_status", userData["status"].toString());
    }

    if (userData["profile_photo"] != null) {
      await prefs.setString(
          "user_profile_photo", userData["profile_photo"].toString());
    }

    if (userData["city"] != null) {
      await prefs.setString("user_city", userData["city"].toString());
    }

    if (userData["country"] != null) {
      await prefs.setString("user_country", userData["country"].toString());
    }

    if (userData["gov_id_type"] != null) {
      await prefs.setString(
          "user_gov_id_type", userData["gov_id_type"].toString());
    }

    if (userData["gov_id_number"] != null) {
      await prefs.setString(
          "user_gov_id_number", userData["gov_id_number"].toString());
    }

    // Mark user as logged in
    await prefs.setBool("is_logged_in", true);

    print("✅ User data saved successfully");
  }

  // ------------------ DISPOSE ------------------
  @override
  void dispose() {
    page.dispose();
    phoneCtrl.dispose();
    otpCtrl.dispose();
    pwdCtrl.dispose();
    confirmCtrl.dispose();
    firstCtrl.dispose();
    lastCtrl.dispose();
    emailCtrl.dispose();
    govtIdNumberCtrl.dispose();
    cityCtrl.dispose();
    super.dispose();
  }
}

class SignupStep {
  static const int phoneOtp = 0;
  static const int accountCreated = 1;
  static const int nameEmail = 2;
  static const int password = 3;
  static const int govtId = 4;
  static const int addressProfile = 5;

  static const int total = 6;
}