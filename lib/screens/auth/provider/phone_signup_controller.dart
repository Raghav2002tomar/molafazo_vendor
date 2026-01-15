import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/local_user_storage.dart';

class PhoneSignupController extends ChangeNotifier {
  final page = PageController();
  int step = 0;
  bool busy = false;

  bool otpSent = false; // ✅ flag for OTP sent

  /// Controllers
  final phoneCtrl = TextEditingController(text: '+234');
  final otpCtrl = TextEditingController();
  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final altPhoneCtrl = TextEditingController();
  final govtIdNumberCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  // FORM KEYS
  final phoneFormKey = GlobalKey<FormState>();
  final otpFormKey = GlobalKey<FormState>();
  final nameFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  String? Function(String?) get emailValidator => (v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    return RegExp(r'^\S+@\S+\.\S+$').hasMatch(v) ? null : 'Invalid email';
  };

  String? Function(String?) get passwordValidator => (v) {
    if (v == null || v.isEmpty) return 'Password required';
    if (v.length < 8) return 'Minimum 8 characters';
    return null;
  };

  String? govtIdType;
  bool acceptedTerms = false;

  XFile? profileImage;
  XFile? idProofImage;
  String? verificationId;

  /// ---------- NAVIGATION ----------
  void next() {
    if (step >= 4) return;
    step++;
    page.animateToPage(step, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    notifyListeners();
  }

  void back() {
    if (step == 0) return;
    step--;
    page.animateToPage(step, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    notifyListeners();
  }

  Future<void> sendOtp() async {
    if (!phoneFormKey.currentState!.validate()) return;

    busy = true;
    notifyListeners();

    Fluttertoast.showToast(msg: "OTP sent successfully");
    await Future.delayed(const Duration(milliseconds: 700));

    verificationId = "stub-id";

    busy = false;
    otpSent = true; // ✅ mark OTP as sent
    notifyListeners();
  }

  Future<void> verifyOtp() async {
    if (otpCtrl.text.trim().length != 6) {
      Fluttertoast.showToast(msg: "Enter valid OTP");
      return;
    }

    busy = true;
    notifyListeners();

    Fluttertoast.showToast(msg: "Phone verified");
    await Future.delayed(const Duration(milliseconds: 700));

    busy = false;
    notifyListeners();
    next(); // move to next step
  }
  /// ---------- IMAGE ----------
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

  /// ---------- FINAL SAVE ----------
  Future<void> saveAndFinish(BuildContext context) async {
    busy = true;
    notifyListeners();

    await LocalUserStorage.saveUser(
      phone: phoneCtrl.text.trim(),
      altPhone: altPhoneCtrl.text.trim(),
      firstName: firstCtrl.text.trim(),
      lastName: lastCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      govtIdType: govtIdType,
      govtIdNumber: govtIdNumberCtrl.text.trim(),
      city: cityCtrl.text.trim(),
      profileImage: profileImage?.path,
      idProof: idProofImage?.path,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);

    busy = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
    }
  }

  @override
  void dispose() {
    page.dispose();
    phoneCtrl.dispose();
    otpCtrl.dispose();
    firstCtrl.dispose();
    lastCtrl.dispose();
    emailCtrl.dispose();
    pwdCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }
}
