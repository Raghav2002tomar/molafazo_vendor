// // lib/auth/phone_signup_wizard.dart
// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hive/hive.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../didit_demo_screen.dart';
// import '../../../providers/translate_provider.dart';
// import '../../../service/colors.dart';
// import '../../../services/local_user_storage.dart';
// import '../../../widgets/address_selection_screen.dart';
// import '../provider/phone_signup_controller.dart';
//
// class PhoneSignupWizard extends StatelessWidget {
//   const PhoneSignupWizard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => PhoneSignupController(),
//       child: const _PhoneSignupView(),
//     );
//   }
// }
//
// class _PhoneSignupView extends StatelessWidget {
//   const _PhoneSignupView();
//
//   static const int totalSteps = 6;
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.watch<PhoneSignupController>();
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: c.step == 0 || c.step == 1
//             ? null
//             : IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           onPressed: c.back,
//         ),
//         title: const Text('Create your account'),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Progress Indicator
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: LinearProgressIndicator(
//                 value: (c.step + 1) / totalSteps,
//               ),
//             ),
//
//             // Page Content
//             Expanded(
//               child: PageView(
//                 controller: c.page,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   // STEP 0 – Phone & OTP
//                   _PhoneOtpStep(
//                     formKey: c.phoneFormKey,
//                     phoneCtrl: c.phoneCtrl,
//                     otpCtrl: c.otpCtrl,
//                     sendOtp: c.sendOtp,
//                     verifyOtp: c.verifyOtp,
//                   ),
//
//                   // STEP 1 – Account Created (No bottom button)
//                   _AccountCreatedStep(
//                     onProceed: () => c.goToStep(SignupStep.nameEmail),
//                     onSkip: () => c.finishAndGoDashboard(context),
//                   ),
//
//                   // STEP 2 – Name & Email
//                   _NameEmailStep(
//                     formKey: c.nameFormKey,
//                     firstCtrl: c.firstCtrl,
//                     lastCtrl: c.lastCtrl,
//                     emailCtrl: c.emailCtrl,
//                     emailValidator: c.emailValidator,
//                   ),
//
//                   // STEP 3 – Password
//                   _PasswordStep(
//                     pwdCtrl: c.pwdCtrl,
//                     confirmCtrl: c.confirmCtrl,
//                     formKey: c.passwordFormKey,
//                   ),
//
//                   // STEP 4 – Govt ID
//                   _GovtIdStep(
//                     // file: c.idProofImage,
//                     // onUpload: c.pickGovtIdImage,
//                   ),
//
//                   // STEP 5 – Address + Profile Image
//                   _AddressProfileStep(
//                     city: c.cityCtrl,
//                     accepted: c.acceptedTerms,
//                     onAccept: (v) {
//                       c.acceptedTerms = v ?? false;
//                       c.notifyListeners();
//                     },
//                     profileImage: c.profileImage,
//                     onPickProfile: () async {
//                       final picker = ImagePicker();
//                       final picked = await picker.pickImage(
//                           source: ImageSource.gallery);
//                       if (picked == null) return;
//
//                       final compressed =
//                       await FlutterImageCompress.compressAndGetFile(
//                         picked.path,
//                         '${picked.path}_compressed.jpg',
//                         quality: 70,
//                       );
//
//                       c.profileImage =
//                       compressed != null ? XFile(compressed.path) : null;
//                       c.notifyListeners();
//                     },
//                     selectedLat: c.selectedLat,
//                     selectedLng: c.selectedLng,
//                     selectedAddress: c.selectedAddress,
//                     onAddressSelected: (address, lat, lng) {
//                       c.selectedAddress = address;
//                       c.selectedLat = lat;
//                       c.selectedLng = lng;
//                       c.cityCtrl.text = address; // Update the controller
//                       c.notifyListeners();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//             // BOTTOM CONTINUE BUTTON (Hidden for Account Created step)
//
//             if (c.step != SignupStep.accountCreated)
//               Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: c.busy
//                         ? null
//                         : () async {
//                       switch (c.step) {
//                         case SignupStep.phoneOtp:
//                           if (!c.otpSent) {
//                             // Send OTP
//                             await c.sendOtp(context);
//                           } else {
//                             // Verify OTP
//                             await c.verifyOtp();
//                           }
//                           break;
//
//                         case SignupStep.nameEmail:
//                           if (c.nameFormKey.currentState!.validate()) {
//                             c.goToStep(SignupStep.password);
//                           }
//                           break;
//
//                         case SignupStep.password:
//                           if (c.passwordFormKey.currentState!
//                               .validate()) {
//                             c.goToStep(SignupStep.govtId);
//                           }
//                           break;
//
//                         // case SignupStep.govtId:
//                         //   print("Govt ID step - file exists: ${c.idProofImage != null}");
//                         //   if (c.idProofImage != null) {
//                         //     print("Navigating to next step...");
//                         //     c.goToStep(SignupStep.addressProfile);
//                         //   } else {
//                         //     Fluttertoast.showToast(msg: 'Please upload your government ID');
//                         //   }
//                         //   break;
//                         case SignupStep.govtId:
//                           c.goToStep(SignupStep.addressProfile);
//                           break;
//                         case SignupStep.addressProfile:
//                           if (c.acceptedTerms) {
//                             await c.saveAndFinish(context);
//                           } else {
//                             Fluttertoast.showToast(
//                                 msg: 'Accept Terms & Conditions');
//                           }
//                           break;
//                       }
//                     },
//                     child: c.busy
//                         ? const CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     )
//                         : Text(_getButtonText(c.step, c.otpSent)),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getButtonText(int step, bool otpSent) {
//     switch (step) {
//       case SignupStep.phoneOtp:
//         return otpSent ? 'Verify OTP' : 'Send OTP';
//       case SignupStep.addressProfile:
//         return 'Finish';
//       default:
//         return 'Continue';
//     }
//   }
// }
//
// // ==============================================================================
// // STEP WIDGETS
// // ==============================================================================
//
// class _PhoneOtpStep extends StatefulWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController phoneCtrl;
//   final TextEditingController otpCtrl;
//   final Future<void> Function(BuildContext context) sendOtp;
//   final Future<void> Function() verifyOtp;
//
//   const _PhoneOtpStep({
//     required this.formKey,
//     required this.phoneCtrl,
//     required this.otpCtrl,
//     required this.sendOtp,
//     required this.verifyOtp,
//   });
//
//   @override
//   State<_PhoneOtpStep> createState() => _PhoneOtpStepState();
// }
//
// class _PhoneOtpStepState extends State<_PhoneOtpStep> {
//   int _resendCountdown = 30;
//   Timer? _timer;
//
//   void startResendCountdown() {
//     _resendCountdown = 30;
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendCountdown == 0) {
//         timer.cancel();
//       } else {
//         setState(() => _resendCountdown--);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.watch<PhoneSignupController>();
//     final scheme = Theme.of(context).colorScheme;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: widget.formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Phone Verification",
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "Enter your phone number to receive a verification code",
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Phone Input
//             TextFormField(
//               controller: widget.phoneCtrl,
//               keyboardType: TextInputType.number,
//               maxLength: 10,
//               enabled: !c.otpSent,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(10),
//               ],
//               decoration: InputDecoration(
//                 counterText: "",
//                 prefix: Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: Text(
//                     "+234",
//                     style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 16,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                       color: AppTheme.seedSecondary.withOpacity(0.3)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppTheme.seedPrimary, width: 2),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.red),
//                 ),
//               ),
//               style: GoogleFonts.poppins(color: Colors.black87),
//               validator: (v) {
//                 if (v == null || v.isEmpty) {
//                   return 'Phone number is required';
//                 }
//                 if (v.length != 10) {
//                   return 'Enter exactly 10 digits';
//                 }
//                 return null;
//               },
//             ),
//
//             // OTP Input (shown after OTP sent)
//             if (c.otpSent) ...[
//               const SizedBox(height: 24),
//               Text(
//                 'Enter the 6-digit code sent to +234 ${widget.phoneCtrl.text}',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Center(
//                 child: Pinput(
//                   controller: widget.otpCtrl,
//                   length: 6,
//                   defaultPinTheme: PinTheme(
//                     width: 50,
//                     height: 50,
//                     textStyle: const TextStyle(
//                       fontSize: 20,
//                       color: Colors.black,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey),
//                     ),
//                   ),
//                   focusedPinTheme: PinTheme(
//                     width: 50,
//                     height: 50,
//                     textStyle: const TextStyle(
//                       fontSize: 20,
//                       color: Colors.black,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: scheme.primary, width: 2),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Resend OTP
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Didn't receive OTP?",
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   const SizedBox(width: 6),
//                   TextButton(
//                     onPressed: _resendCountdown == 0
//                         ? () async {
//                       await widget.sendOtp(context);
//                       startResendCountdown();
//                     }
//                         : null,
//                     child: Text(
//                       _resendCountdown == 0
//                           ? "Resend OTP"
//                           : "Resend in $_resendCountdown s",
//                       style: TextStyle(
//                         color: _resendCountdown == 0
//                             ? scheme.primary
//                             : Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _AccountCreatedStep extends StatelessWidget {
//   final VoidCallback onProceed;
//   final VoidCallback onSkip;
//
//   const _AccountCreatedStep({
//     required this.onProceed,
//     required this.onSkip,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.verified_rounded,
//               size: 80,
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Account Created Successfully',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'You can complete your profile now or skip for later',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 40),
//
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: ElevatedButton(
//               onPressed: onProceed,
//               child: const Text('Complete Profile'),
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: OutlinedButton(
//               onPressed: onSkip,
//               child: const Text('Skip for now'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _NameEmailStep extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController firstCtrl;
//   final TextEditingController lastCtrl;
//   final TextEditingController emailCtrl;
//   final String? Function(String?) emailValidator;
//
//   const _NameEmailStep({
//     required this.formKey,
//     required this.firstCtrl,
//     required this.lastCtrl,
//     required this.emailCtrl,
//     required this.emailValidator,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Personal Information',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Please provide your personal details',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             Text(
//               'First Name',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: firstCtrl,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your first name',
//                 filled: true,
//                 fillColor: Color(0xFFF5F5F5),
//               ),
//               validator: (v) =>
//               v == null || v.trim().isEmpty ? 'First name required' : null,
//             ),
//
//             const SizedBox(height: 20),
//
//             Text(
//               'Last Name',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: lastCtrl,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your last name',
//                 filled: true,
//                 fillColor: Color(0xFFF5F5F5),
//               ),
//               validator: (v) =>
//               v == null || v.trim().isEmpty ? 'Last name required' : null,
//             ),
//
//             const SizedBox(height: 20),
//
//             Text(
//               'Email Address',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: emailCtrl,
//               keyboardType: TextInputType.emailAddress,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your email address',
//                 filled: true,
//                 fillColor: Color(0xFFF5F5F5),
//               ),
//               validator: emailValidator,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _PasswordStep extends StatefulWidget {
//   final TextEditingController pwdCtrl, confirmCtrl;
//   final GlobalKey<FormState> formKey;
//
//   const _PasswordStep({
//     required this.pwdCtrl,
//     required this.confirmCtrl,
//     required this.formKey,
//   });
//
//   @override
//   State<_PasswordStep> createState() => _PasswordStepState();
// }
//
// class _PasswordStepState extends State<_PasswordStep> {
//   bool _showPassword = false;
//   bool _showConfirmPassword = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: widget.formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Create Password',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Choose a strong password for your account',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             Text(
//               'Password',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: widget.pwdCtrl,
//               obscureText: !_showPassword,
//               decoration: InputDecoration(
//                 hintText: 'Enter password (min 6 characters)',
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _showPassword ? Icons.visibility : Icons.visibility_off,
//                   ),
//                   onPressed: () =>
//                       setState(() => _showPassword = !_showPassword),
//                 ),
//               ),
//               validator: (v) =>
//               v != null && v.length >= 6 ? null : 'Min 6 characters',
//             ),
//
//             const SizedBox(height: 20),
//
//             Text(
//               'Confirm Password',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: widget.confirmCtrl,
//               obscureText: !_showConfirmPassword,
//               decoration: InputDecoration(
//                 hintText: 'Re-enter your password',
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _showConfirmPassword
//                         ? Icons.visibility
//                         : Icons.visibility_off,
//                   ),
//                   onPressed: () => setState(
//                           () => _showConfirmPassword = !_showConfirmPassword),
//                 ),
//               ),
//               validator: (v) =>
//               v == widget.pwdCtrl.text ? null : 'Passwords do not match',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _GovtIdStep extends StatefulWidget {
//   const _GovtIdStep({super.key});
//
//   @override
//   State<_GovtIdStep> createState() => _GovtIdStepState();
// }
//
// class _GovtIdStepState extends State<_GovtIdStep> {
//
//   bool isVerified = false; // manage state (convert to StatefulWidget if needed)
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Identity Verification',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           Text(
//             'Please upload a valid government ID (required)',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: Colors.grey[600],
//             ),
//           ),
//
//           const SizedBox(height: 24),
//
//           Text(
//             'Verify Document *',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               color: Colors.red,
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           // ✅ BUTTON FIXED
//           OutlinedButton.icon(
//             onPressed: isVerified
//                 ? null
//                 : () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => VerificationScreen(),
//                 ),
//               );
//
//               if (result == true) {
//                 setState(() {
//                   isVerified = true;
//                 });
//               }
//             },
//             icon: Icon(
//               isVerified ? Icons.verified : Icons.upload_file,
//               color: isVerified ? Colors.green : null,
//             ),
//             label: Text(
//               isVerified ? 'Document Verified' : 'Upload ID Proof (Required)',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class _AddressProfileStep extends StatefulWidget {
//   final TextEditingController city;
//   final bool accepted;
//   final ValueChanged<bool?> onAccept;
//   final XFile? profileImage;
//   final VoidCallback onPickProfile;
//
//   // Add these new parameters
//   final double? selectedLat;
//   final double? selectedLng;
//   final String? selectedAddress;
//   final Function(String address, double lat, double lng) onAddressSelected;
//
//   const _AddressProfileStep({
//     required this.city,
//     required this.accepted,
//     required this.onAccept,
//     required this.profileImage,
//     required this.onPickProfile,
//     // Add these required parameters
//     required this.selectedLat,
//     required this.selectedLng,
//     required this.selectedAddress,
//     required this.onAddressSelected,
//   });
//
//   @override
//   State<_AddressProfileStep> createState() => _AddressProfileStepState();
// }
//
// class _AddressProfileStepState extends State<_AddressProfileStep> {
//   // Address variables with lat/lng
//   // String? _selectedAddress;
//   // double? _selectedLat;
//   // double? _selectedLng;
//   final addressCtrl = TextEditingController();
//   String? _selectedCity;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize from controller if available
//     if (widget.selectedAddress != null && widget.selectedAddress!.isNotEmpty) {
//       addressCtrl.text = widget.selectedAddress!;
//     }
//   }
//
//   @override
//   void dispose() {
//     addressCtrl.dispose();
//     super.dispose();
//   }
//
//   /// ---------- ADDRESS SELECTION WITH MAP ----------
//   Future<void> _openMapAddressPicker() async {
//     final result = await Navigator.push<Map<String, dynamic>>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddressSelectionScreen(
//           initialAddress: widget.selectedAddress ?? widget.city.text,
//           initialLat: widget.selectedLat,
//           initialLng: widget.selectedLng,
//         ),
//       ),
//     );
//
//     if (result != null) {
//       // Update the controller directly
//       widget.city.text = result['address'];
//
//       // Update the controller's properties through the parent
//       widget.onAddressSelected(
//         result['address'],
//         result['lat'],
//         result['lng'],
//       );
//
//       // Update local UI state
//       setState(() {
//         addressCtrl.text = result['address'];
//         _selectedCity = result['city'];
//       });
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Profile & Address',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Complete your profile with a photo and address',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // Profile Image Section
//           Text('Profile Image',
//               style: Theme.of(context).textTheme.titleMedium),
//           const SizedBox(height: 12),
//
//           Center(
//             child: Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: scheme.outlineVariant,
//                       width: 2,
//                     ),
//                   ),
//                   child: ClipOval(
//                     child: widget.profileImage != null
//                         ? Image.file(
//                       File(widget.profileImage!.path),
//                       fit: BoxFit.cover,
//                     )
//                         : Container(
//                       color: scheme.surfaceContainerHighest,
//                       child: Icon(
//                         Icons.person_outline,
//                         size: 48,
//                         color: scheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: widget.onPickProfile,
//                     borderRadius: BorderRadius.circular(20),
//                     child: CircleAvatar(
//                       radius: 20,
//                       backgroundColor: scheme.primary,
//                       child: Icon(
//                         widget.profileImage != null
//                             ? Icons.edit
//                             : Icons.camera_alt_outlined,
//                         size: 20,
//                         color: scheme.onPrimary,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           Center(
//             child: TextButton.icon(
//               onPressed: widget.onPickProfile,
//               icon: Icon(
//                 widget.profileImage != null ? Icons.edit : Icons.upload_file,
//                 size: 18,
//               ),
//               label: Text(
//                 widget.profileImage != null
//                     ? 'Change Profile Photo'
//                     : 'Upload Profile Photo',
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 24),
//
//           // Address Section with Map Picker
//           Text(
//             'Delivery Address',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 12),
//
//           // Address Selection Card with Map
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: scheme.outlineVariant),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: InkWell(
//               onTap: _openMapAddressPicker,
//               borderRadius: BorderRadius.circular(12),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: scheme.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         Icons.map_outlined,
//                         color: scheme.primary,
//                         size: 24,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Select Address',
//                             style: textTheme.labelMedium?.copyWith(
//                               color: scheme.onSurfaceVariant,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             widget.selectedAddress == null || widget.selectedAddress!.isEmpty
//                                 ? 'Choose your address on map'
//                                 : widget.selectedAddress!,
//                             style: textTheme.bodyMedium?.copyWith(
//                               color: widget.selectedAddress == null || widget.selectedAddress!.isEmpty
//                                   ? scheme.onSurfaceVariant
//                                   : scheme.onSurface,
//                               fontWeight: widget.selectedAddress == null || widget.selectedAddress!.isEmpty
//                                   ? FontWeight.normal
//                                   : FontWeight.w500,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           if (widget.selectedLat != null && widget.selectedLng != null) ...[
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.location_on,
//                                   size: 12,
//                                   color: scheme.primary,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   'Coordinates selected',
//                                   style: textTheme.labelSmall?.copyWith(
//                                     color: scheme.primary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                     Icon(
//                       Icons.chevron_right,
//                       color: scheme.onSurfaceVariant,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Hidden field for validation (optional)
//           if (widget.selectedAddress == null || widget.selectedAddress!.isEmpty)
//             Padding(
//               padding: const EdgeInsets.only(top: 8, left: 12),
//               child: Text(
//                 'Address is required',
//                 style: TextStyle(
//                   color: Colors.red.shade700,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//
//
//           const SizedBox(height: 24),
//
//           // Terms & Conditions Checkbox
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: widget.accepted ? scheme.primary : Colors.grey[300]!,
//               ),
//             ),
//             child: CheckboxListTile(
//               contentPadding: EdgeInsets.zero,
//               value: widget.accepted,
//               onChanged: widget.onAccept,
//               controlAffinity: ListTileControlAffinity.leading,
//               title: const Text(
//                 'I accept the Terms & Conditions',
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// lib/auth/phone_signup_wizard.dart


// ________________________________________



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

import '../../../didit_demo_screen.dart';
import '../../../providers/translate_provider.dart';
import '../../../service/colors.dart';
import '../../../services/local_user_storage.dart';
import '../../../widgets/address_selection_screen.dart';
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

  static const int totalSteps = 5; // 5 steps total

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

                  // STEP 1 – Account Created
                  _AccountCreatedStep(
                    onProceed: () => c.goToStep(SignupStep.emailPassword),
                    onSkip: () => c.finishAndGoDashboard(context),
                  ),

                  // STEP 2 – Email & Password
                  _EmailPasswordStep(
                    emailCtrl: c.emailCtrl,
                    pwdCtrl: c.pwdCtrl,
                    confirmCtrl: c.confirmCtrl,
                    formKey: c.emailPasswordFormKey,
                    emailValidator: c.emailValidator,
                  ),

                  // STEP 3 – Govt ID
                  _GovtIdStep(),

                  // STEP 4 – Address
                  _AddressStep(
                    city: c.cityCtrl,
                    accepted: c.acceptedTerms,
                    onAccept: (v) {
                      c.acceptedTerms = v ?? false;
                      c.notifyListeners();
                    },
                    selectedLat: c.selectedLat,
                    selectedLng: c.selectedLng,
                    selectedAddress: c.selectedAddress,
                    onAddressSelected: (address, lat, lng) {
                      c.selectedAddress = address;
                      c.selectedLat = lat;
                      c.selectedLng = lng;
                      c.cityCtrl.text = address;
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
                            await c.sendOtp(context);
                          } else {
                            await c.verifyOtp();
                          }
                          break;

                        case SignupStep.emailPassword:
                          if (c.emailPasswordFormKey.currentState!.validate()) {
                            c.goToStep(SignupStep.govtId);
                          }
                          break;

                        case SignupStep.govtId:
                          if (c.isDocumentVerified) {
                            c.goToStep(SignupStep.address);
                          } else {
                            Fluttertoast.showToast(msg: 'Please verify your government ID first');
                          }
                          break;

                        case SignupStep.address:
                          if (c.acceptedTerms) {
                            await c.saveAndFinish(context);
                          } else {
                            Fluttertoast.showToast(msg: 'Accept Terms & Conditions');
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
      case SignupStep.address:
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
  final Future<void> Function(BuildContext context) sendOtp;
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
                      await widget.sendOtp(context);
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

class _EmailPasswordStep extends StatefulWidget {
  final TextEditingController emailCtrl;
  final TextEditingController pwdCtrl;
  final TextEditingController confirmCtrl;
  final GlobalKey<FormState> formKey;
  final String? Function(String?) emailValidator;

  const _EmailPasswordStep({
    required this.emailCtrl,
    required this.pwdCtrl,
    required this.confirmCtrl,
    required this.formKey,
    required this.emailValidator,
  });

  @override
  State<_EmailPasswordStep> createState() => _EmailPasswordStepState();
}

class _EmailPasswordStepState extends State<_EmailPasswordStep> {
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
              'Email & Password',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your email and create a password',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Email Field
            Text(
              'Email Address',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email address',
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              validator: widget.emailValidator,
            ),

            const SizedBox(height: 20),

            // Password Field
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

            // Confirm Password Field
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

class _GovtIdStep extends StatefulWidget {
  const _GovtIdStep({super.key});

  @override
  State<_GovtIdStep> createState() => _GovtIdStepState();
}

class _GovtIdStepState extends State<_GovtIdStep> {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<PhoneSignupController>();
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Identity Verification',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please verify your identity using our secure KYC process',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Verification Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: c.isDocumentVerified
                    ? [Colors.green.shade50, Colors.green.shade100]
                    : [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: c.isDocumentVerified ? Colors.green : Colors.blue,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  c.isDocumentVerified ? Icons.verified : Icons.shield_outlined,
                  size: 60,
                  color: c.isDocumentVerified ? Colors.green : Colors.blue,
                ),
                const SizedBox(height: 12),
                Text(
                  c.isDocumentVerified ? 'Document Verified!' : 'Verification Required',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: c.isDocumentVerified ? Colors.green.shade800 : Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  c.isDocumentVerified
                      ? 'Your identity has been successfully verified'
                      : 'Click the button below to start the verification process',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.isDocumentVerified ? Colors.green.shade700 : Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 20),

                if (c.isDocumentVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Verified',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                if (!c.isDocumentVerified)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: c.isVerifying ? null : () async {
                        c.isVerifying = true;
                        c.notifyListeners();

                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VerificationScreen(),
                          ),
                        );

                        c.isVerifying = false;

                        if (result == true) {
                          c.isDocumentVerified = true;
                          c.notifyListeners();

                          Fluttertoast.showToast(
                            msg: 'Document verified successfully!',
                            backgroundColor: Colors.green,
                          );

                          // Auto navigate to next step after 1 second
                          Future.delayed(const Duration(seconds: 1), () {
                            if (mounted) {
                              c.goToStep(SignupStep.address);
                            }
                          });
                        } else if (result == false) {
                          Fluttertoast.showToast(
                            msg: 'Verification failed. Please try again.',
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      icon: c.isVerifying
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.verified_user),
                      label: Text(c.isVerifying ? 'Verifying...' : 'Start Verification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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

class _AddressStep extends StatefulWidget {
  final TextEditingController city;
  final bool accepted;
  final ValueChanged<bool?> onAccept;
  final double? selectedLat;
  final double? selectedLng;
  final String? selectedAddress;
  final Function(String address, double lat, double lng) onAddressSelected;

  const _AddressStep({
    required this.city,
    required this.accepted,
    required this.onAccept,
    required this.selectedLat,
    required this.selectedLng,
    required this.selectedAddress,
    required this.onAddressSelected,
  });

  @override
  State<_AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<_AddressStep> {
  final addressCtrl = TextEditingController();
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    if (widget.selectedAddress != null && widget.selectedAddress!.isNotEmpty) {
      addressCtrl.text = widget.selectedAddress!;
    }
  }

  @override
  void dispose() {
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _openMapAddressPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressSelectionScreen(
          initialAddress: widget.selectedAddress ?? widget.city.text,
          initialLat: widget.selectedLat,
          initialLng: widget.selectedLng,
        ),
      ),
    );

    if (result != null) {
      widget.city.text = result['address'];
      widget.onAddressSelected(
        result['address'],
        result['lat'],
        result['lng'],
      );

      setState(() {
        addressCtrl.text = result['address'];
        _selectedCity = result['city'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Address',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your delivery address',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Address Selection Card with Map
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: _openMapAddressPicker,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.map_outlined,
                        color: scheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Address',
                            style: textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.selectedAddress == null || widget.selectedAddress!.isEmpty
                                ? 'Choose your address on map'
                                : widget.selectedAddress!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: widget.selectedAddress == null || widget.selectedAddress!.isEmpty
                                  ? scheme.onSurfaceVariant
                                  : scheme.onSurface,
                              fontWeight: widget.selectedAddress == null || widget.selectedAddress!.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.selectedLat != null && widget.selectedLng != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: scheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Coordinates selected',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: scheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (widget.selectedAddress == null || widget.selectedAddress!.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                'Address is required',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 32),

          // Terms & Conditions Checkbox
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.accepted ? scheme.primary : Colors.grey[300]!,
              ),
            ),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: widget.accepted,
              onChanged: widget.onAccept,
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

// _________________________________________________

// lib/auth/phone_signup_wizard.dart
// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hive/hive.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../didit_demo_screen.dart';
// import '../../../providers/translate_provider.dart';
// import '../../../service/colors.dart';
// import '../../../services/local_user_storage.dart';
// import '../../../widgets/address_selection_screen.dart';
// import '../provider/phone_signup_controller.dart';
//
// class PhoneSignupWizard extends StatelessWidget {
//   const PhoneSignupWizard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => PhoneSignupController(),
//       child: const _PhoneSignupView(),
//     );
//   }
// }
//
// class _PhoneSignupView extends StatelessWidget {
//   const _PhoneSignupView();
//
//   static const int totalSteps = 6; // 6 steps total
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.watch<PhoneSignupController>();
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: c.step == 0 || c.step == 1
//             ? null
//             : IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           onPressed: c.back,
//         ),
//         title: const Text('Create your account'),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Progress Indicator
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: LinearProgressIndicator(
//                 value: (c.step + 1) / totalSteps,
//               ),
//             ),
//
//             // Page Content
//             Expanded(
//               child: PageView(
//                 controller: c.page,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   // STEP 0 – Phone & OTP
//                   _PhoneOtpStep(
//                     formKey: c.phoneFormKey,
//                     phoneCtrl: c.phoneCtrl,
//                     otpCtrl: c.otpCtrl,
//                     sendOtp: c.sendOtp,
//                     verifyOtp: c.verifyOtp,
//                   ),
//
//                   // STEP 1 – Account Created
//                   _AccountCreatedStep(
//                     onProceed: () => c.goToStep(SignupStep.nameEmail),
//                     onSkip: () => c.finishAndGoDashboard(context),
//                   ),
//
//                   // STEP 2 – Name & Email
//                   _NameEmailStep(
//                     formKey: c.nameFormKey,
//                     firstCtrl: c.firstCtrl,
//                     lastCtrl: c.lastCtrl,
//                     emailCtrl: c.emailCtrl,
//                     emailValidator: c.emailValidator,
//                   ),
//
//                   // STEP 3 – Password
//                   _PasswordStep(
//                     pwdCtrl: c.pwdCtrl,
//                     confirmCtrl: c.confirmCtrl,
//                     formKey: c.passwordFormKey,
//                   ),
//
//                   // STEP 4 – Govt ID
//                   _GovtIdStep(),
//
//                   // STEP 5 – Address + Profile Image
//                   _AddressProfileStep(
//                     city: c.cityCtrl,
//                     accepted: c.acceptedTerms,
//                     onAccept: (v) {
//                       c.acceptedTerms = v ?? false;
//                       c.notifyListeners();
//                     },
//                     profileImage: c.profileImage,
//                     onPickProfile: () async {
//                       final picker = ImagePicker();
//                       final picked = await picker.pickImage(
//                           source: ImageSource.gallery);
//                       if (picked == null) return;
//
//                       final compressed =
//                       await FlutterImageCompress.compressAndGetFile(
//                         picked.path,
//                         '${picked.path}_compressed.jpg',
//                         quality: 70,
//                       );
//
//                       c.profileImage =
//                       compressed != null ? XFile(compressed.path) : null;
//                       c.notifyListeners();
//                     },
//                     selectedLat: c.selectedLat,
//                     selectedLng: c.selectedLng,
//                     selectedAddress: c.selectedAddress,
//                     onAddressSelected: (address, lat, lng) {
//                       c.selectedAddress = address;
//                       c.selectedLat = lat;
//                       c.selectedLng = lng;
//                       c.cityCtrl.text = address;
//                       c.notifyListeners();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//             // BOTTOM CONTINUE BUTTON (Hidden for Account Created step)
//             if (c.step != SignupStep.accountCreated)
//               Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: c.busy
//                         ? null
//                         : () async {
//                       switch (c.step) {
//                         case SignupStep.phoneOtp:
//                           if (!c.otpSent) {
//                             await c.sendOtp(context);
//                           } else {
//                             await c.verifyOtp();
//                           }
//                           break;
//
//                         case SignupStep.nameEmail:
//                           if (c.nameFormKey.currentState!.validate()) {
//                             c.goToStep(SignupStep.password);
//                           }
//                           break;
//
//                         case SignupStep.password:
//                           if (c.passwordFormKey.currentState!.validate()) {
//                             c.goToStep(SignupStep.govtId);
//                           }
//                           break;
//
//                         case SignupStep.govtId:
//                           if (c.isDocumentVerified) {
//                             c.goToStep(SignupStep.addressProfile);
//                           } else {
//                             Fluttertoast.showToast(msg: 'Please verify your government ID first');
//                           }
//                           break;
//
//                         case SignupStep.addressProfile:
//                           if (c.acceptedTerms) {
//                             await c.saveAndFinish(context);
//                           } else {
//                             Fluttertoast.showToast(msg: 'Accept Terms & Conditions');
//                           }
//                           break;
//                       }
//                     },
//                     child: c.busy
//                         ? const CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     )
//                         : Text(_getButtonText(c.step, c.otpSent)),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _getButtonText(int step, bool otpSent) {
//     switch (step) {
//       case SignupStep.phoneOtp:
//         return otpSent ? 'Verify OTP' : 'Send OTP';
//       case SignupStep.addressProfile:
//         return 'Finish';
//       default:
//         return 'Continue';
//     }
//   }
// }
//
// // ==============================================================================
// // STEP WIDGETS
// // ==============================================================================
//
// class _PhoneOtpStep extends StatefulWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController phoneCtrl;
//   final TextEditingController otpCtrl;
//   final Future<void> Function(BuildContext context) sendOtp;
//   final Future<void> Function() verifyOtp;
//
//   const _PhoneOtpStep({
//     required this.formKey,
//     required this.phoneCtrl,
//     required this.otpCtrl,
//     required this.sendOtp,
//     required this.verifyOtp,
//   });
//
//   @override
//   State<_PhoneOtpStep> createState() => _PhoneOtpStepState();
// }
//
// class _PhoneOtpStepState extends State<_PhoneOtpStep> {
//   int _resendCountdown = 30;
//   Timer? _timer;
//
//   void startResendCountdown() {
//     _resendCountdown = 30;
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendCountdown == 0) {
//         timer.cancel();
//       } else {
//         setState(() => _resendCountdown--);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.watch<PhoneSignupController>();
//     final scheme = Theme.of(context).colorScheme;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: widget.formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Phone Verification",
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "Enter your phone number to receive a verification code",
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Phone Input
//             TextFormField(
//               controller: widget.phoneCtrl,
//               keyboardType: TextInputType.number,
//               maxLength: 10,
//               enabled: !c.otpSent,
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(10),
//               ],
//               decoration: InputDecoration(
//                 counterText: "",
//                 prefix: Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: Text(
//                     "+234",
//                     style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 16,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                       color: AppTheme.seedSecondary.withOpacity(0.3)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: AppTheme.seedPrimary, width: 2),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Colors.red),
//                 ),
//               ),
//               style: GoogleFonts.poppins(color: Colors.black87),
//               validator: (v) {
//                 if (v == null || v.isEmpty) {
//                   return 'Phone number is required';
//                 }
//                 if (v.length != 10) {
//                   return 'Enter exactly 10 digits';
//                 }
//                 return null;
//               },
//             ),
//
//             // OTP Input (shown after OTP sent)
//             if (c.otpSent) ...[
//               const SizedBox(height: 24),
//               Text(
//                 'Enter the 6-digit code sent to +234 ${widget.phoneCtrl.text}',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Center(
//                 child: Pinput(
//                   controller: widget.otpCtrl,
//                   length: 6,
//                   defaultPinTheme: PinTheme(
//                     width: 50,
//                     height: 50,
//                     textStyle: const TextStyle(
//                       fontSize: 20,
//                       color: Colors.black,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey),
//                     ),
//                   ),
//                   focusedPinTheme: PinTheme(
//                     width: 50,
//                     height: 50,
//                     textStyle: const TextStyle(
//                       fontSize: 20,
//                       color: Colors.black,
//                     ),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: scheme.primary, width: 2),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Resend OTP
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Didn't receive OTP?",
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                   const SizedBox(width: 6),
//                   TextButton(
//                     onPressed: _resendCountdown == 0
//                         ? () async {
//                       await widget.sendOtp(context);
//                       startResendCountdown();
//                     }
//                         : null,
//                     child: Text(
//                       _resendCountdown == 0
//                           ? "Resend OTP"
//                           : "Resend in $_resendCountdown s",
//                       style: TextStyle(
//                         color: _resendCountdown == 0
//                             ? scheme.primary
//                             : Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _AccountCreatedStep extends StatelessWidget {
//   final VoidCallback onProceed;
//   final VoidCallback onSkip;
//
//   const _AccountCreatedStep({
//     required this.onProceed,
//     required this.onSkip,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.verified_rounded,
//               size: 80,
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Account Created Successfully',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'You can complete your profile now or skip for later',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 40),
//
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: ElevatedButton(
//               onPressed: onProceed,
//               child: const Text('Complete Profile'),
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: OutlinedButton(
//               onPressed: onSkip,
//               child: const Text('Skip for now'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _NameEmailStep extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController firstCtrl;
//   final TextEditingController lastCtrl;
//   final TextEditingController emailCtrl;
//   final String? Function(String?) emailValidator;
//
//   const _NameEmailStep({
//     required this.formKey,
//     required this.firstCtrl,
//     required this.lastCtrl,
//     required this.emailCtrl,
//     required this.emailValidator,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Personal Information',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Please provide your personal details',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             Text(
//               'First Name',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: firstCtrl,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your first name',
//                 filled: true,
//                 fillColor: Color(0xFFF5F5F5),
//               ),
//               validator: (v) =>
//               v == null || v.trim().isEmpty ? 'First name required' : null,
//             ),
//
//             const SizedBox(height: 20),
//
//             Text(
//               'Last Name',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: lastCtrl,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your last name',
//                 filled: true,
//                 fillColor: Color(0xFFF5F5F5),
//               ),
//               validator: (v) =>
//               v == null || v.trim().isEmpty ? 'Last name required' : null,
//             ),
//
//             const SizedBox(height: 20),
//
//             Text(
//               'Email Address',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: emailCtrl,
//               keyboardType: TextInputType.emailAddress,
//               decoration: const InputDecoration(
//                 hintText: 'Enter your email address',
//                 filled: true,
//                 fillColor: Color(0xFFF5F5F5),
//               ),
//               validator: emailValidator,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _PasswordStep extends StatefulWidget {
//   final TextEditingController pwdCtrl, confirmCtrl;
//   final GlobalKey<FormState> formKey;
//
//   const _PasswordStep({
//     required this.pwdCtrl,
//     required this.confirmCtrl,
//     required this.formKey,
//   });
//
//   @override
//   State<_PasswordStep> createState() => _PasswordStepState();
// }
//
// class _PasswordStepState extends State<_PasswordStep> {
//   bool _showPassword = false;
//   bool _showConfirmPassword = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Form(
//         key: widget.formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Create Password',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Choose a strong password for your account',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             Text(
//               'Password',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: widget.pwdCtrl,
//               obscureText: !_showPassword,
//               decoration: InputDecoration(
//                 hintText: 'Enter password (min 6 characters)',
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _showPassword ? Icons.visibility : Icons.visibility_off,
//                   ),
//                   onPressed: () =>
//                       setState(() => _showPassword = !_showPassword),
//                 ),
//               ),
//               validator: (v) =>
//               v != null && v.length >= 6 ? null : 'Min 6 characters',
//             ),
//
//             const SizedBox(height: 20),
//
//             Text(
//               'Confirm Password',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: widget.confirmCtrl,
//               obscureText: !_showConfirmPassword,
//               decoration: InputDecoration(
//                 hintText: 'Re-enter your password',
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _showConfirmPassword
//                         ? Icons.visibility
//                         : Icons.visibility_off,
//                   ),
//                   onPressed: () => setState(
//                           () => _showConfirmPassword = !_showConfirmPassword),
//                 ),
//               ),
//               validator: (v) =>
//               v == widget.pwdCtrl.text ? null : 'Passwords do not match',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _GovtIdStep extends StatefulWidget {
//   const _GovtIdStep({super.key});
//
//   @override
//   State<_GovtIdStep> createState() => _GovtIdStepState();
// }
//
// class _GovtIdStepState extends State<_GovtIdStep> {
//   @override
//   Widget build(BuildContext context) {
//     final c = context.watch<PhoneSignupController>();
//     final scheme = Theme.of(context).colorScheme;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Identity Verification',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Please verify your identity using our secure KYC process',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // Verification Card
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: c.isDocumentVerified
//                     ? [Colors.green.shade50, Colors.green.shade100]
//                     : [Colors.blue.shade50, Colors.blue.shade100],
//               ),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: c.isDocumentVerified ? Colors.green : Colors.blue,
//                 width: 2,
//               ),
//             ),
//             child: Column(
//               children: [
//                 Icon(
//                   c.isDocumentVerified ? Icons.verified : Icons.shield_outlined,
//                   size: 60,
//                   color: c.isDocumentVerified ? Colors.green : Colors.blue,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   c.isDocumentVerified ? 'Document Verified!' : 'Verification Required',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: c.isDocumentVerified ? Colors.green.shade800 : Colors.blue.shade800,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   c.isDocumentVerified
//                       ? 'Your identity has been successfully verified'
//                       : 'Click the button below to start the verification process',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: c.isDocumentVerified ? Colors.green.shade700 : Colors.blue.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 if (c.isDocumentVerified)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: const [
//                         Icon(Icons.check_circle, color: Colors.white, size: 18),
//                         SizedBox(width: 8),
//                         Text(
//                           'Verified',
//                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 if (!c.isDocumentVerified)
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: c.isVerifying ? null : () async {
//                         c.isVerifying = true;
//                         c.notifyListeners();
//
//                         final result = await Navigator.push<bool>(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const VerificationScreen(),
//                           ),
//                         );
//
//                         c.isVerifying = false;
//
//                         if (result == true) {
//                           c.isDocumentVerified = true;
//                           c.notifyListeners();
//
//                           Fluttertoast.showToast(
//                             msg: 'Document verified successfully!',
//                             backgroundColor: Colors.green,
//                           );
//
//                           // Auto navigate to next step after 1 second
//                           Future.delayed(const Duration(seconds: 1), () {
//                             if (mounted) {
//                               c.goToStep(SignupStep.addressProfile);
//                             }
//                           });
//                         } else if (result == false) {
//                           Fluttertoast.showToast(
//                             msg: 'Verification failed. Please try again.',
//                             backgroundColor: Colors.red,
//                           );
//                         }
//                       },
//                       icon: c.isVerifying
//                           ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                           : const Icon(Icons.verified_user),
//                       label: Text(c.isVerifying ? 'Verifying...' : 'Start Verification'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: scheme.primary,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _AddressProfileStep extends StatefulWidget {
//   final TextEditingController city;
//   final bool accepted;
//   final ValueChanged<bool?> onAccept;
//   final XFile? profileImage;
//   final VoidCallback onPickProfile;
//   final double? selectedLat;
//   final double? selectedLng;
//   final String? selectedAddress;
//   final Function(String address, double lat, double lng) onAddressSelected;
//
//   const _AddressProfileStep({
//     required this.city,
//     required this.accepted,
//     required this.onAccept,
//     required this.profileImage,
//     required this.onPickProfile,
//     required this.selectedLat,
//     required this.selectedLng,
//     required this.selectedAddress,
//     required this.onAddressSelected,
//   });
//
//   @override
//   State<_AddressProfileStep> createState() => _AddressProfileStepState();
// }
//
// class _AddressProfileStepState extends State<_AddressProfileStep> {
//   final addressCtrl = TextEditingController();
//   String? _selectedCity;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.selectedAddress != null && widget.selectedAddress!.isNotEmpty) {
//       addressCtrl.text = widget.selectedAddress!;
//     }
//   }
//
//   @override
//   void dispose() {
//     addressCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _openMapAddressPicker() async {
//     final result = await Navigator.push<Map<String, dynamic>>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddressSelectionScreen(
//           initialAddress: widget.selectedAddress ?? widget.city.text,
//           initialLat: widget.selectedLat,
//           initialLng: widget.selectedLng,
//         ),
//       ),
//     );
//
//     if (result != null) {
//       widget.city.text = result['address'];
//       widget.onAddressSelected(
//         result['address'],
//         result['lat'],
//         result['lng'],
//       );
//
//       setState(() {
//         addressCtrl.text = result['address'];
//         _selectedCity = result['city'];
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Profile & Address',
//             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Complete your profile with a photo and address',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // Profile Image Section
//           Text('Profile Image',
//               style: Theme.of(context).textTheme.titleMedium),
//           const SizedBox(height: 12),
//
//           Center(
//             child: Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: scheme.outlineVariant,
//                       width: 2,
//                     ),
//                   ),
//                   child: ClipOval(
//                     child: widget.profileImage != null
//                         ? Image.file(
//                       File(widget.profileImage!.path),
//                       fit: BoxFit.cover,
//                     )
//                         : Container(
//                       color: scheme.surfaceContainerHighest,
//                       child: Icon(
//                         Icons.person_outline,
//                         size: 48,
//                         color: scheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: widget.onPickProfile,
//                     borderRadius: BorderRadius.circular(20),
//                     child: CircleAvatar(
//                       radius: 20,
//                       backgroundColor: scheme.primary,
//                       child: Icon(
//                         widget.profileImage != null
//                             ? Icons.edit
//                             : Icons.camera_alt_outlined,
//                         size: 20,
//                         color: scheme.onPrimary,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           Center(
//             child: TextButton.icon(
//               onPressed: widget.onPickProfile,
//               icon: Icon(
//                 widget.profileImage != null ? Icons.edit : Icons.upload_file,
//                 size: 18,
//               ),
//               label: Text(
//                 widget.profileImage != null
//                     ? 'Change Profile Photo'
//                     : 'Upload Profile Photo',
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 24),
//
//           // Address Section with Map Picker
//           Text(
//             'Delivery Address',
//             style: Theme.of(context).textTheme.titleMedium,
//           ),
//           const SizedBox(height: 12),
//
//           // Address Selection Card with Map
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: scheme.outlineVariant),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: InkWell(
//               onTap: _openMapAddressPicker,
//               borderRadius: BorderRadius.circular(12),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: scheme.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         Icons.map_outlined,
//                         color: scheme.primary,
//                         size: 24,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Select Address',
//                             style: textTheme.labelMedium?.copyWith(
//                               color: scheme.onSurfaceVariant,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             widget.selectedAddress == null || widget.selectedAddress!.isEmpty
//                                 ? 'Choose your address on map'
//                                 : widget.selectedAddress!,
//                             style: textTheme.bodyMedium?.copyWith(
//                               color: widget.selectedAddress == null || widget.selectedAddress!.isEmpty
//                                   ? scheme.onSurfaceVariant
//                                   : scheme.onSurface,
//                               fontWeight: widget.selectedAddress == null || widget.selectedAddress!.isEmpty
//                                   ? FontWeight.normal
//                                   : FontWeight.w500,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           if (widget.selectedLat != null && widget.selectedLng != null) ...[
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.location_on,
//                                   size: 12,
//                                   color: scheme.primary,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   'Coordinates selected',
//                                   style: textTheme.labelSmall?.copyWith(
//                                     color: scheme.primary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                     Icon(
//                       Icons.chevron_right,
//                       color: scheme.onSurfaceVariant,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           if (widget.selectedAddress == null || widget.selectedAddress!.isEmpty)
//             Padding(
//               padding: const EdgeInsets.only(top: 8, left: 12),
//               child: Text(
//                 'Address is required',
//                 style: TextStyle(
//                   color: Colors.red.shade700,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//
//           const SizedBox(height: 24),
//
//           // Terms & Conditions Checkbox
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: widget.accepted ? scheme.primary : Colors.grey[300]!,
//               ),
//             ),
//             child: CheckboxListTile(
//               contentPadding: EdgeInsets.zero,
//               value: widget.accepted,
//               onChanged: widget.onAccept,
//               controlAffinity: ListTileControlAffinity.leading,
//               title: const Text(
//                 'I accept the Terms & Conditions',
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }