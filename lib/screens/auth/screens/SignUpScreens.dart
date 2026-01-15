// lib/auth/phone_signup_wizard.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PhoneSignupController>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: c.step == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: c.back,
              ),
        title: const Text('Create your account'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(value: (c.step + 1) / 4),
          ),
          Expanded(
            child: PageView(
              controller: c.page,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // STEP 0: Phone + OTP
                _PhoneOtpStep(
                  phoneCtrl: c.phoneCtrl,
                  otpCtrl: c.otpCtrl,
                  formKey: c.phoneFormKey,
                  sendOtp: c.sendOtp,
                  verifyOtp: c.verifyOtp,
                ),

                // STEP 1: Name, Email, Password
                _NameEmailPasswordStep(
                  firstCtrl: c.firstCtrl,
                  lastCtrl: c.lastCtrl,
                  emailCtrl: c.emailCtrl,
                  pwdCtrl: c.pwdCtrl,
                  confirmCtrl: c.confirmCtrl,
                  nameFormKey: c.nameFormKey,
                  passwordFormKey: c.passwordFormKey,
                  emailValidator: c.emailValidator,
                  pwdValidator: c.passwordValidator,
                ),

                // STEP 2: Govt ID
                _GovtIdStep(
                  value: c.govtIdType,
                  onChanged: (v) => c.govtIdType = v,
                  numberCtrl: c.govtIdNumberCtrl,
                  file: c.idProofImage,
                  onUpload: c.pickGovtIdImage,
                ),

                // STEP 3: Address + Terms + Profile Image
                _AddressProfileStep(
                  city: c.cityCtrl,
                  accepted: c.acceptedTerms,
                  onAccept: (v) => c.acceptedTerms = v ?? false,
                  profileImage: c.profileImage,
                  onPickProfile: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked == null) return;
                    final compressed =
                        await FlutterImageCompress.compressAndGetFile(
                          picked.path,
                          '${picked.path}_compressed.jpg',
                          quality: 70,
                        );
                    c.profileImage = compressed != null
                        ? XFile(compressed.path)
                        : null;
                    c.notifyListeners();
                  },
                ),
                _AccountCreatedStep(onFinish: () => c.saveAndFinish(context)),
              ],
            ),
          ),
          // Only show the bottom "Continue" button for steps 0–3
          if (c.step < 4)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.busy
                      ? null
                      : () {
                          switch (c.step) {
                            case 0:
                              c.sendOtp();
                              break;
                            case 1:
                              c.verifyOtp();
                              break;
                            case 2:
                            case 3:
                              c.next();
                              break; // move to next step
                          }
                        },
                  child: c.busy
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text('Continue'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';
// import '../provider/phone_signup_controller.dart';

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

            // Show phone input only if OTP not sent
            if (!c.otpSent) ...[
              TextFormField(
                controller: widget.phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+2348012345678',
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                ),
                validator: (v) =>
                    v != null && RegExp(r'^\+\d{6,15}$').hasMatch(v.trim())
                    ? null
                    : 'Enter valid phone',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.busy
                      ? null
                      : () async {
                          await widget.sendOtp();
                          startResendCountdown();
                        },
                  child: c.busy
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text('Send OTP'),
                ),
              ),
            ],

            // Show OTP input if OTP sent
            if (c.otpSent) ...[
              const SizedBox(height: 20),
              Text(
                'Enter the 6-digit code sent to ${widget.phoneCtrl.text}',
                style: Theme.of(context).textTheme.bodyMedium,
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
                      border: Border.all(color: scheme.primary),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: c.busy ? null : widget.verifyOtp,
                  child: c.busy
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text('Verify OTP'),
                ),
              ),
              const SizedBox(height: 12),

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

class _NameEmailPasswordStep extends StatelessWidget {
  final GlobalKey<FormState> nameFormKey;
  final GlobalKey<FormState> passwordFormKey;
  final TextEditingController firstCtrl,
      lastCtrl,
      emailCtrl,
      pwdCtrl,
      confirmCtrl;
  final String? Function(String?) emailValidator;
  final String? Function(String?) pwdValidator;

  const _NameEmailPasswordStep({
    required this.nameFormKey,
    required this.passwordFormKey,
    required this.firstCtrl,
    required this.lastCtrl,
    required this.emailCtrl,
    required this.pwdCtrl,
    required this.confirmCtrl,
    required this.emailValidator,
    required this.pwdValidator,
  });

  @override
  Widget build(BuildContext context) {
    bool showPwd = false;
    bool showConfirm = false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Info & Password',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Form(
            key: nameFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: firstCtrl,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  validator: emailValidator,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: passwordFormKey,
            child: Column(
              children: [
                StatefulBuilder(
                  builder: (context, setState) => TextFormField(
                    controller: pwdCtrl,
                    obscureText: !showPwd,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPwd ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => showPwd = !showPwd),
                      ),
                    ),
                    validator: pwdValidator,
                  ),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setState) => TextFormField(
                    controller: confirmCtrl,
                    obscureText: !showConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirm ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => showConfirm = !showConfirm),
                      ),
                    ),
                    validator: (v) =>
                        v != pwdCtrl.text ? 'Passwords do not match' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// STEP 4 – Account Created
class _AccountCreatedStep extends StatelessWidget {
  final VoidCallback onFinish;

  const _AccountCreatedStep({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            color: scheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset("assets/images/Group 8.png"),
                  // CircleAvatar(
                  //   radius: 28,
                  //   backgroundColor: scheme.primary.withOpacity(0.15),
                  //   child: Icon(Icons.verified_rounded, color: scheme.primary, size: 32),
                  // ),
                  const SizedBox(height: 12),
                  Text(
                    'Account Created!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set up the store and get the business ready for activation',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _setupItem(
                    context,
                    "assets/images/busness_info.png",
                    'Add business information',
                    'Add more information about the business',
                  ),
                  _setupItem(
                    context,
                    "assets/images/store.png",
                    'Set-up your store',
                    'Create and customise the online store',
                  ),
                  _setupItem(
                    context,
                    "assets/images/product_list.png",
                    'Create your product list',
                    'Add items to your product list with images',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onFinish,
                      child: const Text('Continue to Setup'),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onFinish,
                      child: const Text('Skip for Later'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _setupItem(
    BuildContext context,
    String? icon,
    String title,
    String subtitle,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: scheme.primary.withOpacity(0.10),
        // child: Icon(icon, size: 18, color: scheme.primary),
        child: Image.asset(icon as String),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Government ID Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          /// ID TYPE
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
              labelText: 'ID Type',
            ),
          ),

          const SizedBox(height: 16),

          /// ID NUMBER
          TextFormField(
            controller: numberCtrl,
            decoration: const InputDecoration(
              filled: true,
              labelText: 'ID Number',
            ),
          ),

          const SizedBox(height: 20),

          /// IMAGE PREVIEW / UPLOAD
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
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.edit),
              label: const Text('Change ID Image'),
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: onUpload,
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
            'Business Address & Profile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),

          // Address Field
          TextFormField(
            controller: city,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Full Address',
              hintText: 'City, State, Country',
              filled: true,
              fillColor: Color(0xFFF5F5F5),
            ),
          ),

          const SizedBox(height: 30),

          // Profile Image Section
          Text('Profile Image', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: profileImage != null
                      ? FileImage(File(profileImage!.path))
                      : null,
                  child: profileImage == null
                      ? const Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: Colors.black54,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: onPickProfile,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: scheme.primary,
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Terms & Conditions Checkbox
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: accepted,
            onChanged: onAccept,
            title: const Text('I accept Terms & Conditions'),
          ),

          const SizedBox(height: 24),

          // Submit button for this step (no dashboard navigation yet)
          // SizedBox(
          //   width: double.infinity,
          //   height: 48,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       // Just go to next step without finishing the signup
          //       final c = context.read<PhoneSignupController>();
          //       c.next();
          //     },
          //     child: const Text('Continue'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
