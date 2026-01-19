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

  static const int totalSteps = 6;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PhoneSignupController>();

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
            child: LinearProgressIndicator(
              value: (c.step + 1) / totalSteps,
            ),
          ),
          Expanded(
            child: PageView(
              controller: c.page,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                /// STEP 0 – Phone + OTP
                _PhoneOtpStep(
                  formKey: c.phoneFormKey,
                  phoneCtrl: c.phoneCtrl,
                  otpCtrl: c.otpCtrl,
                  sendOtp: c.sendOtp,
                  verifyOtp: c.verifyOtp,
                ),

                /// STEP 1 – Password
                _PasswordStep(
                  pwdCtrl: c.pwdCtrl,
                  confirmCtrl: c.confirmCtrl,
                  formKey: c.passwordFormKey,
                ),

                /// STEP 2 – Account Created
                _AccountCreatedStep(
                  onProceed: c.goToProfileSetup,
                  onSkip: () => c.finishAndGoDashboard(context),
                ),

                /// STEP 3 – Name & Email
                _NameEmailStep(
                  formKey: c.nameFormKey,
                  firstCtrl: c.firstCtrl,
                  lastCtrl: c.lastCtrl,
                  emailCtrl: c.emailCtrl,
                  emailValidator: c.emailValidator,
                ),

                /// STEP 4 – Govt ID
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

                /// STEP 5 – Address + Profile Image
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
                    final picked =
                    await picker.pickImage(source: ImageSource.gallery);
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
              ],
            ),
          ),

          /// BOTTOM CONTINUE BUTTON
          if (c.step != 2)
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
                      case 0:
                        await c.sendOtp();
                        break;
                      case 1:
                        await c.createAccount();
                        break;
                      case 3:
                        if (c.nameFormKey.currentState!.validate()) {
                          c.next();
                        }
                        break;
                      case 4:
                        c.next();
                        break;
                      case 5:
                        await c.saveAndFinish(context);
                        break;
                    }
                  },
                  child: c.busy
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : Text(c.step == 5 ? 'Finish' : 'Continue'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



class _PasswordStep extends StatelessWidget {
  final TextEditingController pwdCtrl, confirmCtrl;
  final GlobalKey<FormState> formKey;

  const _PasswordStep({
    required this.pwdCtrl,
    required this.confirmCtrl,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Password',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),

            TextFormField(
              controller: pwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                filled: true,
              ),
              validator: (v) =>
              v != null && v.length >= 6 ? null : 'Min 6 characters',
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Confirm Password',
                filled: true,
              ),
              validator: (v) =>
              v == pwdCtrl.text ? null : 'Passwords do not match',
            ),
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
          Icon(Icons.verified_rounded, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          Text('Account Created Successfully',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'You can complete your profile now or skip for later',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onProceed,
              child: const Text('Proceed to Create Profile'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSkip,
              child: const Text('Skip at this time'),
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
                  // labelText: 'Phone Number',
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            /// FIRST NAME
            Text(
              'First Name',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: firstCtrl,
              decoration: const InputDecoration(
                hintText: 'First Name',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'First name required' : null,
            ),

            const SizedBox(height: 16),

            /// LAST NAME
            Text(
              'Last Name',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: lastCtrl,
              decoration: const InputDecoration(
                hintText: 'Last Name',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Last name required' : null,
            ),

            const SizedBox(height: 16),

            /// EMAIL
            Text(
              'Email Address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email Address',
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Name',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: firstCtrl,
                  decoration: const InputDecoration(
                    hintText: 'First Name',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Last Name',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: lastCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Last Name',
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Email',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                StatefulBuilder(
                  builder: (context, setState) => TextFormField(
                    controller: pwdCtrl,
                    obscureText: !showPwd,
                    decoration: InputDecoration(
                      hintText: 'Password',
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
                Text(
                  'Confirm Password',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
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
          Text(
            'ID Type',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
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
              hintText: 'ID Type',
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'ID Number',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          /// ID NUMBER
          TextFormField(
            controller: numberCtrl,
            decoration: const InputDecoration(
              filled: true,
              labelText: 'ID Number',
            ),
          ),

          const SizedBox(height: 20),
          Text(
            'Upload ID Image',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
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

          // Profile Image Section
          Text('Profile Image', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.outlineVariant,
                    width: 1.5,
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

              /// EDIT / UPLOAD BUTTON
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPickProfile,
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: scheme.primary,
                    child: Icon(
                      profileImage != null
                          ? Icons.edit
                          : Icons.camera_alt_outlined,
                      size: 18,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// TEXT ACTION (like ID upload design)
          TextButton.icon(
            onPressed: onPickProfile,
            icon: Icon(
              profileImage != null ? Icons.edit : Icons.upload_file,
              size: 18,
            ),
            label: Text(
              profileImage != null ? 'Change Profile Photo' : 'Upload Profile Photo',
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Full Address',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Address Field
          TextFormField(
            controller: city,
            maxLines: 5,
            decoration: const InputDecoration(
              // labelText: 'Full Address',
              hintText: 'City, State, Country',
              filled: true,
              fillColor: Color(0xFFF5F5F5),
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
