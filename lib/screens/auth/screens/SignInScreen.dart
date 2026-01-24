import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_service.dart';
import 'SignUpScreens.dart';

enum LoginMode { phone, email }

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  LoginMode _mode = LoginMode.phone;

  final _formKey = GlobalKey<FormState>();

  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool otpSent = false;
  bool loading = false;

  @override
  void dispose() {
    phoneCtrl.dispose();
    otpCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  // ================= VALIDATORS =================
  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (v.trim().length != 10) {
      return 'Enter exactly 10 digits';
    }
    return null;
  }

  String? _otpValidator(String? v) {
    if (v == null || v.isEmpty) return 'OTP is required';
    if (v.length < 4) return 'Invalid OTP';
    return null;
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email required';
    return RegExp(r'^\S+@\S+\.\S+$').hasMatch(v) ? null : 'Invalid email';
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  // ================= OTP SEND =================
  Future<void> sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final res = await ApiService.postFormData(
      endpoint: "/vendor/login/otp/send",
      fields: {
        "phone_number": phoneCtrl.text.trim(),
        "device_type": "android",
        "fcm_token": "1234321",
        "device_token": "1234",
      },
    );

    setState(() => loading = false);

    if (res["success"] == true || res["data"]?["status"] == true) {
      otpSent = true;
      setState(() {});
      _toast("OTP sent successfully");
    } else {
      _toast(res["message"] ?? "Failed to send OTP");
    }
  }

  // ================= OTP VERIFY =================
  Future<void> verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final res = await ApiService.postFormData(
      endpoint: "/vendor/login/otp/verify",
      fields: {
        "phone_number": phoneCtrl.text.trim(),
        "otp": otpCtrl.text.trim(),
        "device_type": "android",
        "fcm_token": "1234321",
        "device_token": "1234",
      },
    );

    setState(() => loading = false);

    // Check for success
    if (res["success"] == true || res["data"]?["status"] == true) {
      print("Login Response: $res");

      final token = res["data"]?["api_token"];

      if (token == null || token.toString().isEmpty) {
        _toast("Authentication failed - No token received");
        return;
      }

      // Save token first
      await _saveToken(token);

      // Save complete user data
      await _saveUser(res["data"]);

      // Show success message
      _toast(res["data"]["message"] ?? "Login successful");

      // Navigate to dashboard
      _goDashboard();
    } else {
      _toast(res["data"]["message"] ?? "Invalid OTP");
    }
  }

  // ================= EMAIL LOGIN =================
  Future<void> emailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final res = await ApiService.postFormData(
      endpoint: "/vendor/login",
      fields: {
        "login": emailCtrl.text.trim(),
        "password": passwordCtrl.text,
        "device_type": "android",
        "fcm_token": "1234321",
        "device_token": "1234",
        "device_id": "1234",
      },
    );

    setState(() => loading = false);

    if (res["success"] == true || res["data"]?["status"] == true) {
      final token = res["data"]?["api_token"];

      if (token != null) {
        await _saveToken(token);
      }

      await _saveUser(res["data"]);
      _toast(res["message"] ?? "Login successful");
      _goDashboard();
    } else {
      _toast(res["message"] ?? "Login failed");
    }
  }

  // ================= LOCAL STORAGE =================
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
      await prefs.setInt("user_id", int.tryParse(userData["id"].toString()) ?? 0);
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
      await prefs.setString("user_profile_photo", userData["profile_photo"].toString());
    }

    if (userData["city"] != null) {
      await prefs.setString("user_city", userData["city"].toString());
    }

    if (userData["country"] != null) {
      await prefs.setString("user_country", userData["country"].toString());
    }

    // Mark user as logged in
    await prefs.setBool("is_logged_in", true);

    print("✅ User data saved successfully");
  }

  void _goDashboard() {
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
            (_) => false,
      );
    }
  }

  void _toast(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    /// LOGO
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Molafzo',
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cursive',
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 3),
                                  blurRadius: 10,
                                  color: scheme.primary.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Experience business sales on another level',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                              letterSpacing: 0.3,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    /// WELCOME TEXT
                    Text(
                      'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// MODE TOGGLE
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModeButton(
                              label: 'Phone',
                              icon: Icons.phone_android,
                              selected: _mode == LoginMode.phone,
                              onTap: () {
                                setState(() {
                                  _mode = LoginMode.phone;
                                  otpSent = false;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: _ModeButton(
                              label: 'Email',
                              icon: Icons.email_outlined,
                              selected: _mode == LoginMode.email,
                              onTap: () {
                                setState(() {
                                  _mode = LoginMode.email;
                                  otpSent = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// FORM FIELDS
                    if (_mode == LoginMode.phone) ..._phoneUI(),
                    if (_mode == LoginMode.email) ..._emailUI(),

                    const SizedBox(height: 32),

                    /// SIGN UP LINK
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PhoneSignupWizard(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= PHONE UI =================
  List<Widget> _phoneUI() {
    final scheme = Theme.of(context).colorScheme;

    return [
      Text(
        'Phone Number',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      AppTextField(
        controller: phoneCtrl,
        hintText: 'Enter your phone number',
        keyboardType: TextInputType.number,
        validator: _phoneValidator,
        enabled: !otpSent,
        prefixIcon: const Icon(Icons.phone_android),
        maxLength: 10,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
      ),
      if (otpSent) ...[
        const SizedBox(height: 20),
        Text(
          'Verification Code',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AppTextField(
          controller: otpCtrl,
          hintText: 'Enter OTP',
          keyboardType: TextInputType.number,
          validator: _otpValidator,
          prefixIcon: const Icon(Icons.lock_outline),
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: loading ? null : sendOtp,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Resend OTP'),
              style: TextButton.styleFrom(
                foregroundColor: scheme.primary,
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: 24),
      SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: loading ? null : (otpSent ? verifyOtp : sendOtp),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: loading
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            otpSent ? 'Verify & Sign In' : 'Send OTP',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ];
  }

  // ================= EMAIL UI =================
  List<Widget> _emailUI() {
    return [
      Text(
        'Email Address',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      AppTextField(
        controller: emailCtrl,
        hintText: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
        validator: _emailValidator,
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      const SizedBox(height: 20),
      Text(
        'Password',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      PasswordTextField(
        controller: passwordCtrl,
        validator: _passwordValidator,
        hintText: 'Enter your password',
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              _toast('Forgot password feature coming soon');
            },
            child: const Text('Forgot Password?'),
          ),
        ],
      ),
      const SizedBox(height: 24),
      SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: loading ? null : emailLogin,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: loading
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ];
  }
}

// ================= MODE TOGGLE BUTTON =================
class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? scheme.primary : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? scheme.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= APP TEXT FIELD =================
Widget AppTextField({
  required TextEditingController controller,
  String? hintText,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
  bool readOnly = false,
  bool enabled = true,
  VoidCallback? onTap,
  Widget? prefixIcon,
  int? maxLength,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    readOnly: readOnly,
    enabled: enabled,
    onTap: onTap,
    maxLength: maxLength,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      counterText: '',
      filled: true,
      fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.black,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
  );
}

// ================= PASSWORD TEXT FIELD =================
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText = 'Password',
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() => _obscure = !_obscure);
          },
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}