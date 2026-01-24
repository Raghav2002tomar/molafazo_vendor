// lib/auth/phone_signup_wizard.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/translate_provider.dart';
import '../../../service/colors.dart';
import '../../../services/local_user_storage.dart';
import '../provider/phone_signup_controller.dart';

class PhoneSignupWizard extends StatelessWidget {
  const PhoneSignupWizard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhoneSignupController(),
      child: const _PhoneSignupView(),
    );
  }
}

class _PhoneSignupView extends StatelessWidget {
  const _PhoneSignupView();

  static const int totalSteps = 6;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PhoneSignupController>();

    return Scaffold(
      appBar: AppBar(
        leading: c.step == 0 || c.step == 1
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: c.back,
        ),
        title: const Text('Create your account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: (c.step + 1) / totalSteps,
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: c.page,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // STEP 0 – Phone & OTP
                  _PhoneOtpStep(
                    formKey: c.phoneFormKey,
                    phoneCtrl: c.phoneCtrl,
                    otpCtrl: c.otpCtrl,
                    sendOtp: c.sendOtp,
                    verifyOtp: c.verifyOtp,
                  ),

                  // STEP 1 – Account Created (No bottom button)
                  _AccountCreatedStep(
                    onProceed: () => c.goToStep(SignupStep.nameEmail),
                    onSkip: () => c.finishAndGoDashboard(context),
                  ),

                  // STEP 2 – Name & Email
                  _NameEmailStep(
                    formKey: c.nameFormKey,
                    firstCtrl: c.firstCtrl,
                    lastCtrl: c.lastCtrl,
                    emailCtrl: c.emailCtrl,
                    emailValidator: c.emailValidator,
                  ),

                  // STEP 3 – Password
                  _PasswordStep(
                    pwdCtrl: c.pwdCtrl,
                    confirmCtrl: c.confirmCtrl,
                    formKey: c.passwordFormKey,
                  ),

                  // STEP 4 – Govt ID
                  _GovtIdStep(
                    value: c.govtIdType,
                    onChanged: (v) {
                      c.govtIdType = v;
                      c.notifyListeners();
                    },
                    numberCtrl: c.govtIdNumberCtrl,
                    file: c.idProofImage,
                    onUpload: c.pickGovtIdImage,
                  ),

                  // STEP 5 – Address + Profile Image
                  _AddressProfileStep(
                    city: c.cityCtrl,
                    accepted: c.acceptedTerms,
                    onAccept: (v) {
                      c.acceptedTerms = v ?? false;
                      c.notifyListeners();
                    },
                    profileImage: c.profileImage,
                    onPickProfile: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                          source: ImageSource.gallery);
                      if (picked == null) return;

                      final compressed =
                      await FlutterImageCompress.compressAndGetFile(
                        picked.path,
                        '${picked.path}_compressed.jpg',
                        quality: 70,
                      );

                      c.profileImage =
                      compressed != null ? XFile(compressed.path) : null;
                      c.notifyListeners();
                    },
                  ),
                ],
              ),
            ),

            // BOTTOM CONTINUE BUTTON (Hidden for Account Created step)
            if (c.step != SignupStep.accountCreated)
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: c.busy
                        ? null
                        : () async {
                      switch (c.step) {
                        case SignupStep.phoneOtp:
                          if (!c.otpSent) {
                            // Send OTP
                            await c.sendOtp();
                          } else {
                            // Verify OTP
                            await c.verifyOtp();
                          }
                          break;

                        case SignupStep.nameEmail:
                          if (c.nameFormKey.currentState!.validate()) {
                            c.goToStep(SignupStep.password);
                          }
                          break;

                        case SignupStep.password:
                          if (c.passwordFormKey.currentState!
                              .validate()) {
                            c.goToStep(SignupStep.govtId);
                          }
                          break;

                        case SignupStep.govtId:
                          if (c.govtIdType != null &&
                              c.govtIdNumberCtrl.text.isNotEmpty) {
                            c.goToStep(SignupStep.addressProfile);
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please complete Govt ID details');
                          }
                          break;

                        case SignupStep.addressProfile:
                          if (c.acceptedTerms) {
                            await c.saveAndFinish(context);
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Accept Terms & Conditions');
                          }
                          break;
                      }
                    },
                    child: c.busy
                        ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                        : Text(_getButtonText(c.step, c.otpSent)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getButtonText(int step, bool otpSent) {
    switch (step) {
      case SignupStep.phoneOtp:
        return otpSent ? 'Verify OTP' : 'Send OTP';
      case SignupStep.addressProfile:
        return 'Finish';
      default:
        return 'Continue';
    }
  }
}

// ==============================================================================
// STEP WIDGETS
// ==============================================================================

class _PhoneOtpStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneCtrl;
  final TextEditingController otpCtrl;
  final Future<void> Function() sendOtp;
  final Future<void> Function() verifyOtp;

  const _PhoneOtpStep({
    required this.formKey,
    required this.phoneCtrl,
    required this.otpCtrl,
    required this.sendOtp,
    required this.verifyOtp,
  });

  @override
  State<_PhoneOtpStep> createState() => _PhoneOtpStepState();
}

class _PhoneOtpStepState extends State<_PhoneOtpStep> {
  int _resendCountdown = 30;
  Timer? _timer;

  void startResendCountdown() {
    _resendCountdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PhoneSignupController>();
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Phone Verification",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              "Enter your phone number to receive a verification code",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Phone Input
            TextFormField(
              controller: widget.phoneCtrl,
              keyboardType: TextInputType.number,
              maxLength: 10,
              enabled: !c.otpSent,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                counterText: "",
                prefix: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    "+234",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppTheme.seedSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.seedPrimary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              style: GoogleFonts.poppins(color: Colors.black87),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Phone number is required';
                }
                if (v.length != 10) {
                  return 'Enter exactly 10 digits';
                }
                return null;
              },
            ),

            // OTP Input (shown after OTP sent)
            if (c.otpSent) ...[
              const SizedBox(height: 24),
              Text(
                'Enter the 6-digit code sent to +234 ${widget.phoneCtrl.text}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Pinput(
                  controller: widget.otpCtrl,
                  length: 6,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: scheme.primary, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 20),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive OTP?",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: _resendCountdown == 0
                        ? () async {
                      await widget.sendOtp();
                      startResendCountdown();
                    }
                        : null,
                    child: Text(
                      _resendCountdown == 0
                          ? "Resend OTP"
                          : "Resend in $_resendCountdown s",
                      style: TextStyle(
                        color: _resendCountdown == 0
                            ? scheme.primary
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountCreatedStep extends StatelessWidget {
  final VoidCallback onProceed;
  final VoidCallback onSkip;

  const _AccountCreatedStep({
    required this.onProceed,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 80,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Account Created Successfully',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'You can complete your profile now or skip for later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onProceed,
              child: const Text('Complete Profile'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: onSkip,
              child: const Text('Skip for now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameEmailStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstCtrl;
  final TextEditingController lastCtrl;
  final TextEditingController emailCtrl;
  final String? Function(String?) emailValidator;

  const _NameEmailStep({
    required this.formKey,
    required this.firstCtrl,
    required this.lastCtrl,
    required this.emailCtrl,
    required this.emailValidator,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your personal details',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'First Name',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: firstCtrl,
              decoration: const InputDecoration(
                hintText: 'Enter your first name',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'First name required' : null,
            ),

            const SizedBox(height: 20),

            Text(
              'Last Name',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: lastCtrl,
              decoration: const InputDecoration(
                hintText: 'Enter your last name',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Last name required' : null,
            ),

            const SizedBox(height: 20),

            Text(
              'Email Address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email address',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              validator: emailValidator,
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordStep extends StatefulWidget {
  final TextEditingController pwdCtrl, confirmCtrl;
  final GlobalKey<FormState> formKey;

  const _PasswordStep({
    required this.pwdCtrl,
    required this.confirmCtrl,
    required this.formKey,
  });

  @override
  State<_PasswordStep> createState() => _PasswordStepState();
}

class _PasswordStepState extends State<_PasswordStep> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Password',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a strong password for your account',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Password',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.pwdCtrl,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                hintText: 'Enter password (min 6 characters)',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              validator: (v) =>
              v != null && v.length >= 6 ? null : 'Min 6 characters',
            ),

            const SizedBox(height: 20),

            Text(
              'Confirm Password',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.confirmCtrl,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Re-enter your password',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                          () => _showConfirmPassword = !_showConfirmPassword),
                ),
              ),
              validator: (v) =>
              v == widget.pwdCtrl.text ? null : 'Passwords do not match',
            ),
          ],
        ),
      ),
    );
  }
}

class _GovtIdStep extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;
  final TextEditingController numberCtrl;
  final VoidCallback onUpload;
  final XFile? file;

  const _GovtIdStep({
    required this.value,
    required this.onChanged,
    required this.numberCtrl,
    required this.onUpload,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Government ID Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide your government-issued ID for verification',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'ID Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            items: const [
              DropdownMenuItem(value: 'Aadhar', child: Text('Aadhar Card')),
              DropdownMenuItem(value: 'PAN', child: Text('PAN Card')),
              DropdownMenuItem(value: 'Passport', child: Text('Passport')),
            ],
            onChanged: onChanged,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              hintText: 'Select ID Type',
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'ID Number',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: numberCtrl,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              hintText: 'Enter ID number',
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Upload ID Image',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          if (file != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(file!.path),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.edit),
              label: const Text('Change ID Image'),
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: onUpload,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload ID Proof'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddressProfileStep extends StatelessWidget {
  final TextEditingController city;
  final bool accepted;
  final ValueChanged<bool?> onAccept;
  final XFile? profileImage;
  final VoidCallback onPickProfile;

  const _AddressProfileStep({
    required this.city,
    required this.accepted,
    required this.onAccept,
    required this.profileImage,
    required this.onPickProfile,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile & Address',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your profile with a photo and address',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Profile Image Section
          Text('Profile Image',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: profileImage != null
                        ? Image.file(
                      File(profileImage!.path),
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person_outline,
                        size: 48,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPickProfile,
                    borderRadius: BorderRadius.circular(20),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: scheme.primary,
                      child: Icon(
                        profileImage != null
                            ? Icons.edit
                            : Icons.camera_alt_outlined,
                        size: 20,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: TextButton.icon(
              onPressed: onPickProfile,
              icon: Icon(
                profileImage != null ? Icons.edit : Icons.upload_file,
                size: 18,
              ),
              label: Text(
                profileImage != null
                    ? 'Change Profile Photo'
                    : 'Upload Profile Photo',
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Full Address',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          TextFormField(
            controller: city,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter your full address\n(City, State, Country)',
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 24),

          // Terms & Conditions Checkbox
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accepted ? scheme.primary : Colors.grey[300]!,
              ),
            ),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              onChanged: onAccept,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'I accept the Terms & Conditions',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}