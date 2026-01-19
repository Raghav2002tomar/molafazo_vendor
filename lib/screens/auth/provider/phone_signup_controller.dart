import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/local_user_storage.dart';

class PhoneSignupController extends ChangeNotifier {
  // ------------------ PAGE / STATE ------------------
  final page = PageController();
  int step = 0;
  bool busy = false;
  bool otpSent = false;

  // ------------------ CONTROLLERS ------------------
  final phoneCtrl = TextEditingController(text: '+234');
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
    return RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)
        ? null
        : 'Invalid email';
  };

  String? Function(String?) get passwordValidator => (v) {
    if (v == null || v.isEmpty) return 'Password required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  };

  // ------------------ NAVIGATION ------------------
  void next() {
    step++;
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

  // ------------------ OTP ------------------
  Future<void> sendOtp() async {
    if (!phoneFormKey.currentState!.validate()) return;

    busy = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    Fluttertoast.showToast(msg: 'OTP sent');

    otpSent = true;
    busy = false;
    notifyListeners();
  }

  Future<void> verifyOtp() async {
    if (otpCtrl.text.length != 6) {
      Fluttertoast.showToast(msg: 'Invalid OTP');
      return;
    }

    busy = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    Fluttertoast.showToast(msg: 'Phone verified');

    busy = false;
    notifyListeners();
    next(); // → Password screen
  }

  // ------------------ CREATE ACCOUNT ------------------
  Future<void> createAccount() async {
    if (!passwordFormKey.currentState!.validate()) return;

    busy = true;
    notifyListeners();

    // 🔐 API call simulation
    await Future.delayed(const Duration(seconds: 1));

    Fluttertoast.showToast(msg: 'Account created');

    busy = false;
    notifyListeners();
    next(); // → Account Created Screen
  }

  // ------------------ SUCCESS SCREEN ACTIONS ------------------
  void goToProfileSetup() {
    step = 4;
    page.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    notifyListeners();
  }

  Future<void> finishAndGoDashboard(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);

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

    await LocalUserStorage.saveUser(
      phone: phoneCtrl.text.trim(),
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
            (_) => false,
      );
    }
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
