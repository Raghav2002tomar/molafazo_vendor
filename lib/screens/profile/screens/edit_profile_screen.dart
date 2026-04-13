//
// import 'dart:convert';
// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// import '../../../didit_demo_screen.dart';
// import '../../../services/api_service.dart';
// import '../../../widgets/address_selection_screen.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   // Controllers
//   final firstCtrl = TextEditingController();
//   final lastCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final mobileCtrl = TextEditingController();
//   final addressCtrl = TextEditingController();
//   final pwdCtrl = TextEditingController();
//   final confirmCtrl = TextEditingController();
//   final govtIdNumberCtrl = TextEditingController();
//   String deviceType = Platform.isAndroid ? "android" : "ios";
//   // Address variables with lat/lng
//   String? _selectedAddress;
//   double? _selectedLat;
//   double? _selectedLng;
//   String? _selectedCity;
//   String? _selectedCityName; // Optional: store city name separately
//
//
//   // Govt ID
//   String? govtIdType;
//   XFile? profileImage;
//   XFile? govtIdImage;
//
//   bool saving = false;
//   bool acceptedTerms = false;
//
//   // Password visibility
//   bool pwdObscure = true;
//   bool confirmObscure = true;
//
//
//
//   Future<String> getDeviceId() async {
//     final deviceInfo = DeviceInfoPlugin();
//
//     if (Platform.isAndroid) {
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       return androidInfo.id;
//     } else {
//       IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//       return iosInfo.identifierForVendor ?? "";
//     }
//   }
//   // Dropdown items for ID type
//   final List<DropdownMenuItem<String>> _idTypeItems = const [
//     DropdownMenuItem(value: 'aadhar', child: Text('Aadhar Card')),
//     DropdownMenuItem(value: 'pan', child: Text('PAN Card')),
//     DropdownMenuItem(value: 'voter', child: Text('Voter ID')),
//     DropdownMenuItem(value: 'driving', child: Text('Driving License')),
//     DropdownMenuItem(value: 'passport', child: Text('Passport')),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   @override
//   void dispose() {
//     firstCtrl.dispose();
//     lastCtrl.dispose();
//     emailCtrl.dispose();
//     mobileCtrl.dispose();
//     addressCtrl.dispose();
//     pwdCtrl.dispose();
//     confirmCtrl.dispose();
//     govtIdNumberCtrl.dispose();
//     super.dispose();
//   }
//
//   /// ---------- LOAD USER DATA ----------
//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userJson = prefs.getString("user");
//
//     if (userJson != null) {
//       final data = jsonDecode(userJson);
//
//       // Name
//       final fullName = data["name"] ?? '';
//       final nameParts = fullName.split(' ');
//       firstCtrl.text = nameParts.isNotEmpty ? nameParts[0] : '';
//       lastCtrl.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
//
//       // Contact
//       emailCtrl.text = data["email"] ?? '';
//       mobileCtrl.text = data["mobile"] ?? '';
//
//       // Address with lat/lng
//       if (data["address_line1"] != null) {
//         // Build full address from components
//         final addressParts = [
//           data["address_line1"],
//           data["address_line2"],
//           data["city"],
//           data["state"],
//           data["country"],
//           data["postal_code"],
//         ].where((s) => s != null && s.toString().isNotEmpty).join(', ');
//
//         addressCtrl.text = addressParts;
//
//         // Store lat/lng if available
//         if (data["latitude"] != null && data["longitude"] != null) {
//           _selectedLat = double.tryParse(data["latitude"].toString());
//           _selectedLng = double.tryParse(data["longitude"].toString());
//         }
//       } else {
//         addressCtrl.text = data["city"] ?? '';
//       }
//
//       // Government ID
//       govtIdType = data["gov_id_type"];
//       govtIdNumberCtrl.text = data["gov_id_number"] ?? '';
//
//       // Profile photo
//       if (data["profile_photo"] != null && data["profile_photo"].toString().isNotEmpty) {
//         profileImage = XFile(data["profile_photo"]);
//       }
//
//       // Government ID documents
//       if (data["government_id_documents"] != null &&
//           (data["government_id_documents"] as List).isNotEmpty) {
//         govtIdImage = XFile(data["government_id_documents"][0]);
//       }
//
//       setState(() {});
//     }
//   }
//
//   /// ---------- ADDRESS SELECTION WITH MAP ----------
//   Future<void> _openMapAddressPicker() async {
//     final result = await Navigator.push<Map<String, dynamic>>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddressSelectionScreen(
//           initialAddress: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
//           initialLat: _selectedLat,
//           initialLng: _selectedLng,
//           // onAddressSelected: (address, lat, lng) {
//           //   Navigator.pop(context, {
//           //     'address': address,
//           //     'lat': lat,
//           //     'lng': lng,
//           //     'city': _selectedCity, // 👈 ADD THIS
//           //
//           //   });
//           // },
//         ),
//       ),
//     );
//
//     if (result != null) {
//       setState(() {
//         addressCtrl.text = result['address'];
//         _selectedLat = result['lat'];
//         _selectedLng = result['lng'];
//         _selectedAddress = result['address'];
//         _selectedCity = result['city']; // 👈 ADD THIS
//       });
//     }
//   }
//
//   /// ---------- IMAGE PICKER ----------
//   Future<void> pickImage(bool isProfile) async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//
//     final compressed = await FlutterImageCompress.compressAndGetFile(
//       picked.path,
//       '${picked.path}_compressed.jpg',
//       quality: 70,
//     );
//
//     setState(() {
//       if (isProfile) {
//         profileImage = compressed != null ? XFile(compressed.path) : null;
//       } else {
//         govtIdImage = compressed != null ? XFile(compressed.path) : null;
//       }
//     });
//   }
//
//   /// ---------- VALIDATORS ----------
//   String? _requiredValidator(String? v) =>
//       v == null || v.trim().isEmpty ? 'Required' : null;
//
//   String? _emailValidator(String? v) {
//     if (v == null || v.isEmpty) return 'Required';
//     final regex = RegExp(r'^\S+@\S+\.\S+$');
//     if (!regex.hasMatch(v)) return 'Invalid email';
//     return null;
//   }
//
//   String? _passwordValidator(String? v) {
//     if (v == null || v.isEmpty) return 'Required';
//     if (v.length < 6) return 'Password must be at least 6 chars';
//     return null;
//   }
//
//   String? _confirmPasswordValidator(String? v) {
//     if (v == null || v.isEmpty) return 'Required';
//     if (v != pwdCtrl.text) return 'Passwords do not match';
//     return null;
//   }
//
//   /// ---------- SAVE PROFILE API ----------
//   Future<void> saveProfile() async {
//     String deviceType = Platform.isAndroid ? "android" : "ios";
//     String deviceId = await getDeviceId();
//
//     if (!_formKey.currentState!.validate()) return;
//
//     if (!acceptedTerms) {
//       Fluttertoast.showToast(msg: "Please accept the terms & conditions");
//       return;
//     }
//
//     /// ✅ FIX 1: Ensure city is selected
//     // if (_selectedCity == null || _selectedCity!.toString().isEmpty) {
//     //   Fluttertoast.showToast(msg: "Please select city");
//     //   return;
//     // }
//
//     /// ✅ FIX 2: Ensure address exists
//     if (addressCtrl.text.trim().isEmpty) {
//       Fluttertoast.showToast(msg: "Please select address");
//       return;
//     }
//
//     setState(() => saving = true);
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString("api_token");
//
//     if (token == null) {
//       Fluttertoast.showToast(msg: "Session expired. Please login again.");
//       setState(() => saving = false);
//       return;
//     }
//
//     File? govtIdFile;
//     if (govtIdImage != null) {
//       if (govtIdImage!.path.startsWith('http')) {
//         govtIdFile = await _downloadTempFile(govtIdImage!.path);
//       } else {
//         govtIdFile = File(govtIdImage!.path);
//       }
//     }
//
//     /// ✅ FIX 3: Always use latest address
//     String addressLine1 = addressCtrl.text.trim();
//
//     /// ✅ DEBUG PRINT (VERY IMPORTANT)
//     print("====== FINAL API DATA ======");
//     print("City: $_selectedCity");
//     print("Address: $addressLine1");
//     print("Lat: $_selectedLat");
//     print("Lng: $_selectedLng");
//
//     final res = await ApiService.multipart(
//       endpoint: "/vendor/complete-profile",
//       token: token,
//       fields: {
//         "name": "${firstCtrl.text.trim()} ${lastCtrl.text.trim()}",
//         "email": emailCtrl.text.trim(),
//         "mobile": mobileCtrl.text.trim(),
//         "password": pwdCtrl.text.trim(),
//         "password_confirmation": confirmCtrl.text.trim(),
//
//         /// ✅ ADDRESS FIX
//         "address_line1": addressLine1,
//         "address_line2": "",
//
//         /// ✅ MOST IMPORTANT FIX
//         "city": _selectedCity!.toString(),   // 🔥 FORCE NOT NULL
//
//         "state": "City",
//         "country": "tajikistan",
//         "postal_code": "12232",
//
//         "latitude": _selectedLat?.toString() ?? "",
//         "longitude": _selectedLng?.toString() ?? "",
//
//         "terms_accepted": acceptedTerms ? "1" : "0",
//         "alt_mobile": mobileCtrl.text.trim(),
//
//         "device_id": deviceId,
//         "device_type": deviceType,
//
//         "fcm_token": "1234321",
//       },
//       files: {
//         if (profileImage != null) "profile_photo": File(profileImage!.path),
//         if (govtIdFile != null) "gov_id_document[]": govtIdFile,
//       },
//     );
//
//     setState(() => saving = false);
//
//     if (res["success"] == true || res["status"] == true) {
//       Fluttertoast.showToast(msg: "Profile updated successfully 🎉");
//
//       /// ✅ FIX 4: Save updated city locally
//       final updatedUser = {
//         "city": _selectedCity,
//         "address": addressLine1,
//       };
//
//       await prefs.setString("user_city", _selectedCity!.toString());
//
//       if (context.mounted) Navigator.pop(context, true);
//     } else {
//       Fluttertoast.showToast(msg: res["message"] ?? "Profile update failed");
//     }
//   }
//   /// ---------- DOWNLOAD TEMP FILE ----------
//   Future<File> _downloadTempFile(String url) async {
//     final response = await http.get(Uri.parse(url));
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
//     return file.writeAsBytes(response.bodyBytes);
//   }
//
//   /// ---------- INPUT DECORATION ----------
//   InputDecoration _inputDecoration(String label, {Widget? suffix, Widget? prefixIcon}) {
//     return InputDecoration(
//       labelText: label,
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       isDense: true,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       suffixIcon: suffix,
//       prefixIcon: prefixIcon,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
//       ),
//     );
//   }
//
//   Widget _passwordToggle(bool isPwd) {
//     return IconButton(
//       icon: Icon(
//           isPwd
//               ? (pwdObscure ? Icons.visibility_off : Icons.visibility)
//               : (confirmObscure ? Icons.visibility_off : Icons.visibility)
//       ),
//       onPressed: () {
//         setState(() {
//           if (isPwd) {
//             pwdObscure = !pwdObscure;
//           } else {
//             confirmObscure = !confirmObscure;
//           }
//         });
//       },
//     );
//   }
//
//   Widget _buildProfileImage() {
//     final cs = Theme.of(context).colorScheme;
//
//     if (profileImage == null) {
//       return CircleAvatar(
//         radius: 42,
//         backgroundColor: cs.surfaceContainerHighest,
//         child: Icon(Icons.person, size: 36, color: cs.onSurfaceVariant),
//       );
//     }
//
//     return CircleAvatar(
//       radius: 42,
//       backgroundColor: cs.surfaceContainerHighest,
//       child: ClipOval(
//         child: Image.file(
//           File(profileImage!.path),
//           width: 84,
//           height: 84,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) =>
//               Icon(Icons.person, size: 36, color: cs.onSurfaceVariant),
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildGovtIdImage() {
//   //   final cs = Theme.of(context).colorScheme;
//   //
//   //   if (govtIdImage == null) {
//   //     return OutlinedButton.icon(
//   //       onPressed: () => pickImage(false),
//   //       icon: const Icon(Icons.upload_file, size: 18),
//   //       label: const Text('Upload ID Image'),
//   //       style: OutlinedButton.styleFrom(
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(12),
//   //         ),
//   //         side: BorderSide(color: cs.outlineVariant),
//   //       ),
//   //     );
//   //   }
//   //
//   //   Widget imageWidget;
//   //
//   //   if (govtIdImage!.path.startsWith('http')) {
//   //     imageWidget = FutureBuilder<File>(
//   //       future: _downloadTempFile(govtIdImage!.path),
//   //       builder: (context, snapshot) {
//   //         if (snapshot.connectionState != ConnectionState.done) {
//   //           return Container(
//   //             height: 140,
//   //             color: Colors.grey[300],
//   //             child: const Center(child: CircularProgressIndicator()),
//   //           );
//   //         }
//   //
//   //         if (snapshot.hasError || snapshot.data == null) {
//   //           return Container(
//   //             height: 140,
//   //             color: Colors.grey[300],
//   //             child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.red)),
//   //           );
//   //         }
//   //
//   //         return Image.file(
//   //           snapshot.data!,
//   //           height: 140,
//   //           width: double.infinity,
//   //           fit: BoxFit.cover,
//   //           errorBuilder: (context, error, stackTrace) {
//   //             return Container(
//   //               height: 140,
//   //               color: Colors.grey[300],
//   //               child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.red)),
//   //             );
//   //           },
//   //         );
//   //       },
//   //     );
//   //   } else {
//   //     imageWidget = Image.file(
//   //       File(govtIdImage!.path),
//   //       height: 140,
//   //       width: double.infinity,
//   //       fit: BoxFit.cover,
//   //       errorBuilder: (context, error, stackTrace) {
//   //         return Container(
//   //           height: 140,
//   //           color: Colors.grey[300],
//   //           child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.red)),
//   //         );
//   //       },
//   //     );
//   //   }
//   //
//   //   return ClipRRect(
//   //     borderRadius: BorderRadius.circular(12),
//   //     child: Stack(
//   //       children: [
//   //         imageWidget,
//   //         Positioned(
//   //           top: 4,
//   //           right: 4,
//   //           child: InkWell(
//   //             onTap: () => pickImage(false),
//   //             child: CircleAvatar(
//   //               radius: 14,
//   //               backgroundColor: Colors.black54,
//   //               child: const Icon(Icons.edit, size: 16, color: Colors.white),
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//   Widget _buildGovtIdButton() {
//     bool isVerified = false; // add this in your state
//
//    return OutlinedButton.icon(
//       onPressed: isVerified
//           ? null // disable if verified
//           : () async {
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VerificationScreen(),
//           ),
//         );
//
//         if (result == true) {
//           setState(() {
//             isVerified = true;
//           });
//         }
//       },
//       icon: Icon(
//         isVerified ? Icons.verified : Icons.upload_file,
//         size: 18,
//         color: isVerified ? Colors.green : null,
//       ),
//       label: Text(
//         isVerified ? 'Document Verified' : 'Verify Document',
//       ),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: scheme.surface,
//         foregroundColor: scheme.onSurface,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             // Profile Image
//             Center(
//               child: Stack(
//                 alignment: Alignment.bottomRight,
//                 children: [
//                   _buildProfileImage(),
//                   InkWell(
//                     onTap: () => pickImage(true),
//                     child: CircleAvatar(
//                       radius: 16,
//                       backgroundColor: scheme.primary,
//                       child: Icon(Icons.edit, size: 14, color: scheme.onPrimary),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // Basic Information Section
//             Text('Basic Information', style: textTheme.titleMedium),
//             const SizedBox(height: 12),
//
//             TextFormField(
//               controller: firstCtrl,
//               decoration: _inputDecoration(
//                   'First Name',
//                   prefixIcon: Icon(Icons.person_outline, color: scheme.onSurfaceVariant)
//               ),
//               validator: _requiredValidator,
//             ),
//             const SizedBox(height: 12),
//
//             TextFormField(
//               controller: lastCtrl,
//               decoration: _inputDecoration(
//                   'Last Name',
//                   prefixIcon: Icon(Icons.person_outline, color: scheme.onSurfaceVariant)
//               ),
//               validator: _requiredValidator,
//             ),
//             const SizedBox(height: 12),
//
//             TextFormField(
//               controller: emailCtrl,
//               keyboardType: TextInputType.emailAddress,
//               decoration: _inputDecoration(
//                   'Email',
//                   prefixIcon: Icon(Icons.email_outlined, color: scheme.onSurfaceVariant)
//               ),
//               validator: _emailValidator,
//             ),
//             const SizedBox(height: 12),
//
//             // Mobile (read-only)
//             TextFormField(
//               readOnly: true,
//               controller: mobileCtrl,
//               keyboardType: TextInputType.phone,
//               decoration: _inputDecoration(
//                   'Mobile Number',
//                   prefixIcon: Icon(Icons.phone_outlined, color: scheme.onSurfaceVariant)
//               ),
//             ),
//             const SizedBox(height: 12),
//
//             TextFormField(
//               controller: pwdCtrl,
//               obscureText: pwdObscure,
//               decoration: _inputDecoration(
//                   'Password',
//                   prefixIcon: Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
//                   suffix: _passwordToggle(true)
//               ),
//               validator: _passwordValidator,
//             ),
//             const SizedBox(height: 12),
//
//             TextFormField(
//               controller: confirmCtrl,
//               obscureText: confirmObscure,
//               decoration: _inputDecoration(
//                   'Confirm Password',
//                   prefixIcon: Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
//                   suffix: _passwordToggle(false)
//               ),
//               validator: _confirmPasswordValidator,
//             ),
//
//             const SizedBox(height: 24),
//
//             // Government ID Section
//             Text('Government ID', style: textTheme.titleMedium),
//             const SizedBox(height: 12),
//
//
//             _buildGovtIdButton(),
//
//
//
//             const SizedBox(height: 24),
//
//             // Address Section
//             Text('Address', style: textTheme.titleMedium),
//             const SizedBox(height: 12),
//
//             // Address Selection Card with Map
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: scheme.outlineVariant),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: InkWell(
//                 onTap: _openMapAddressPicker,
//                 borderRadius: BorderRadius.circular(12),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: scheme.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Icon(
//                           Icons.map_outlined,
//                           color: scheme.primary,
//                           size: 24,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Delivery Address',
//                               style: textTheme.labelMedium?.copyWith(
//                                 color: scheme.onSurfaceVariant,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               addressCtrl.text.isEmpty
//                                   ? 'Select your address on map'
//                                   : addressCtrl.text,
//                               style: textTheme.bodyMedium?.copyWith(
//                                 color: addressCtrl.text.isEmpty
//                                     ? scheme.onSurfaceVariant
//                                     : scheme.onSurface,
//                                 fontWeight: addressCtrl.text.isEmpty
//                                     ? FontWeight.normal
//                                     : FontWeight.w500,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             // if (_selectedLat != null && _selectedLng != null) ...[
//                             //   const SizedBox(height: 4),
//                             //   Row(
//                             //     children: [
//                             //       Icon(
//                             //         Icons.location_on,
//                             //         size: 12,
//                             //         color: scheme.primary,
//                             //       ),
//                             //       const SizedBox(width: 4),
//                             //       // Text(
//                             //       //   'Coordinates: ${_selectedLat!.toStringAsFixed(4)}, ${_selectedLng!.toStringAsFixed(4)}',
//                             //       //   style: textTheme.labelSmall?.copyWith(
//                             //       //     color: scheme.primary,
//                             //       //   ),
//                             //       // ),
//                             //     ],
//                             //   ),
//                             // ],
//                           ],
//                         ),
//                       ),
//                       Icon(
//                         Icons.chevron_right,
//                         color: scheme.onSurfaceVariant,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // Terms and Conditions
//             Row(
//               children: [
//                 Checkbox(
//                   value: acceptedTerms,
//                   onChanged: (v) => setState(() => acceptedTerms = v ?? false),
//                   activeColor: scheme.primary,
//                 ),
//                 Expanded(
//                   child: Text(
//                     "I accept the terms & conditions",
//                     style: textTheme.bodyMedium,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//
//             // Save Button
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: saving ? null : saveProfile,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: scheme.primary,
//                   foregroundColor: scheme.onPrimary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: saving
//                     ? const SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                 )
//                     : const Text(
//                   'Save Changes',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 40),
//           ]),
//         ),
//       ),
//     );
//   }
// }

// ----------------------------------------------------


import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../didit_demo_screen.dart';
import '../../../services/api_service.dart';
import '../../../widgets/address_selection_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final govtIdNumberCtrl = TextEditingController();

  String deviceType = Platform.isAndroid ? "android" : "ios";

  // Address variables with lat/lng
  String? _selectedAddress;
  double? _selectedLat;
  double? _selectedLng;
  String? _selectedCity;
  String? _selectedCityName;

  // Govt ID
  String? govtIdType;
  XFile? profileImage;
  XFile? govtIdImage;

  bool saving = false;
  bool acceptedTerms = false;
  bool isDocumentVerified = false; // Document verification status

  // Password visibility
  bool pwdObscure = true;
  bool confirmObscure = true;

  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "";
    }
  }

  // Dropdown items for ID type
  final List<DropdownMenuItem<String>> _idTypeItems = const [
    DropdownMenuItem(value: 'aadhar', child: Text('Aadhar Card')),
    DropdownMenuItem(value: 'pan', child: Text('PAN Card')),
    DropdownMenuItem(value: 'voter', child: Text('Voter ID')),
    DropdownMenuItem(value: 'driving', child: Text('Driving License')),
    DropdownMenuItem(value: 'passport', child: Text('Passport')),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    firstCtrl.dispose();
    lastCtrl.dispose();
    emailCtrl.dispose();
    mobileCtrl.dispose();
    addressCtrl.dispose();
    pwdCtrl.dispose();
    confirmCtrl.dispose();
    govtIdNumberCtrl.dispose();
    super.dispose();
  }

  /// ---------- LOAD USER DATA ----------
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user");

    if (userJson != null) {
      final data = jsonDecode(userJson);

      // Name (will be displayed but disabled)
      final fullName = data["name"] ?? '';
      final nameParts = fullName.split(' ');
      firstCtrl.text = nameParts.isNotEmpty ? nameParts[0] : '';
      lastCtrl.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Contact
      emailCtrl.text = data["email"] ?? '';
      mobileCtrl.text = data["mobile"] ?? '';

      // Address with lat/lng
      if (data["address_line1"] != null) {
        final addressParts = [
          data["address_line1"],
          data["address_line2"],
          data["city"],
          data["state"],
          data["country"],
          data["postal_code"],
        ].where((s) => s != null && s.toString().isNotEmpty).join(', ');

        addressCtrl.text = addressParts;

        if (data["latitude"] != null && data["longitude"] != null) {
          _selectedLat = double.tryParse(data["latitude"].toString());
          _selectedLng = double.tryParse(data["longitude"].toString());
        }
      } else {
        addressCtrl.text = data["city"] ?? '';
      }

      // Government ID
      govtIdType = data["gov_id_type"];
      govtIdNumberCtrl.text = data["gov_id_number"] ?? '';

      // Check if document is already verified (based on existing data)
      if (data["gov_id_verified"] == true ||
          (data["government_id_documents"] != null &&
              (data["government_id_documents"] as List).isNotEmpty)) {
        isDocumentVerified = true;
      }

      // Profile photo (will be disabled)
      if (data["profile_photo"] != null && data["profile_photo"].toString().isNotEmpty) {
        profileImage = XFile(data["profile_photo"]);
      }

      // Government ID documents
      if (data["government_id_documents"] != null &&
          (data["government_id_documents"] as List).isNotEmpty) {
        govtIdImage = XFile(data["government_id_documents"][0]);
      }

      setState(() {});
    }
  }

  /// ---------- ADDRESS SELECTION WITH MAP ----------
  Future<void> _openMapAddressPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressSelectionScreen(
          initialAddress: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
          initialLat: _selectedLat,
          initialLng: _selectedLng,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        addressCtrl.text = result['address'];
        _selectedLat = result['lat'];
        _selectedLng = result['lng'];
        _selectedAddress = result['address'];
        _selectedCity = result['city'];
      });
    }
  }

  /// ---------- IMAGE PICKER (DISABLED) ----------
  Future<void> pickImage(bool isProfile) async {
    // Disabled - no longer allowing profile photo updates
    Fluttertoast.showToast(msg: "Profile photo cannot be changed");
    return;
  }

  /// ---------- VALIDATORS ----------
  String? _requiredValidator(String? v) =>
      v == null || v.trim().isEmpty ? 'Required' : null;

  String? _emailValidator(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    final regex = RegExp(r'^\S+@\S+\.\S+$');
    if (!regex.hasMatch(v)) return 'Invalid email';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (v.length < 6) return 'Password must be at least 6 chars';
    return null;
  }

  String? _confirmPasswordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (v != pwdCtrl.text) return 'Passwords do not match';
    return null;
  }

  /// ---------- SAVE PROFILE API ----------
  Future<void> saveProfile() async {
    String deviceType = Platform.isAndroid ? "android" : "ios";
    String deviceId = await getDeviceId();

    if (!_formKey.currentState!.validate()) return;

    if (!acceptedTerms) {
      Fluttertoast.showToast(msg: "Please accept the terms & conditions");
      return;
    }

    if (addressCtrl.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please select address");
      return;
    }

    setState(() => saving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("api_token");

    if (token == null) {
      Fluttertoast.showToast(msg: "Session expired. Please login again.");
      setState(() => saving = false);
      return;
    }

    String addressLine1 = addressCtrl.text.trim();

    print("====== FINAL API DATA ======");
    print("Email: ${emailCtrl.text.trim()}");
    print("City: $_selectedCity");
    print("Address: $addressLine1");
    print("Lat: $_selectedLat");
    print("Lng: $_selectedLng");

    final res = await ApiService.multipart(
      endpoint: "/vendor/complete-profile",
      token: token,
      fields: {
        // Name fields are not updated - sending existing values
        "name": "${firstCtrl.text.trim()} ${lastCtrl.text.trim()}",
        "email": emailCtrl.text.trim(), // Email is now editable
        "mobile": mobileCtrl.text.trim(),
        "password": pwdCtrl.text.trim(),
        "password_confirmation": confirmCtrl.text.trim(),

        "address_line1": addressLine1,
        "address_line2": "",

        "city": _selectedCity?.toString() ?? "",
        "state": "City",
        "country": "tajikistan",
        "postal_code": "12232",

        "latitude": _selectedLat?.toString() ?? "",
        "longitude": _selectedLng?.toString() ?? "",

        "terms_accepted": acceptedTerms ? "1" : "0",
        "alt_mobile": mobileCtrl.text.trim(),

        "device_id": deviceId,
        "device_type": deviceType,
        "fcm_token": "1234321",
      },
      files: {
        // No files uploaded - profile photo and govt ID cannot be changed
      },
    );

    setState(() => saving = false);

    if (res["success"] == true || res["status"] == true) {
      Fluttertoast.showToast(msg: "Profile updated successfully 🎉");

      // Update local storage with new email
      final userJson = prefs.getString("user");
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        userData["email"] = emailCtrl.text.trim();
        await prefs.setString("user", jsonEncode(userData));
        await prefs.setString("user_email", emailCtrl.text.trim());
      }

      if (_selectedCity != null) {
        await prefs.setString("user_city", _selectedCity!.toString());
      }

      if (context.mounted) Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: res["message"] ?? "Profile update failed");
    }
  }

  /// ---------- DOWNLOAD TEMP FILE ----------
  Future<File> _downloadTempFile(String url) async {
    final response = await http.get(Uri.parse(url));
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    return file.writeAsBytes(response.bodyBytes);
  }

  /// ---------- INPUT DECORATION ----------
  InputDecoration _inputDecoration(String label, {Widget? suffix, Widget? prefixIcon, bool enabled = true}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      suffixIcon: suffix,
      prefixIcon: prefixIcon,
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
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
    );
  }

  Widget _passwordToggle(bool isPwd) {
    return IconButton(
      icon: Icon(
          isPwd
              ? (pwdObscure ? Icons.visibility_off : Icons.visibility)
              : (confirmObscure ? Icons.visibility_off : Icons.visibility)
      ),
      onPressed: () {
        setState(() {
          if (isPwd) {
            pwdObscure = !pwdObscure;
          } else {
            confirmObscure = !confirmObscure;
          }
        });
      },
    );
  }

  /// ---------- PROFILE IMAGE (DISABLED - READ ONLY) ----------
  Widget _buildProfileImage() {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (profileImage == null)
          CircleAvatar(
            radius: 42,
            backgroundColor: cs.surfaceContainerHighest,
            child: Icon(Icons.person, size: 36, color: cs.onSurfaceVariant),
          )
        else
          CircleAvatar(
            radius: 42,
            backgroundColor: cs.surfaceContainerHighest,
            child: ClipOval(
              child: Image.file(
                File(profileImage!.path),
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 36, color: cs.onSurfaceVariant),
              ),
            ),
          ),
        // Disabled edit button - showing lock icon instead
        Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.lock, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// ---------- GOVT ID VERIFICATION WIDGET (CAN'T RE-VERIFY) ----------
  Widget _buildGovtIdButton() {
    final scheme = Theme.of(context).colorScheme;

    if (isDocumentVerified) {
      // Already verified - show verified status with lock (can't verify again)
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade50, Colors.green.shade100],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document Verified',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  Text(
                    'Your identity has been verified',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.lock, color: Colors.green.shade600, size: 18),
          ],
        ),
      );
    }

    // Not verified - show verify button (one-time verification)
    return OutlinedButton.icon(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VerificationScreen(),
          ),
        );

        if (result == true) {
          setState(() {
            isDocumentVerified = true;
          });

          // Save verification status to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool("gov_id_verified", true);

          Fluttertoast.showToast(
            msg: "Document verified successfully!",
            backgroundColor: Colors.green,
          );
        } else if (result == false) {
          Fluttertoast.showToast(
            msg: "Verification failed. Please try again.",
            backgroundColor: Colors.red,
          );
        }
      },
      icon: const Icon(Icons.verified_user, size: 18),
      label: const Text('Verify Document'),
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: scheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Profile Image (Disabled - Read Only)
            Center(child: _buildProfileImage()),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Profile photo cannot be changed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Basic Information Section
            Text('Basic Information', style: textTheme.titleMedium),
            const SizedBox(height: 12),

            // Note about disabled fields
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Name cannot be changed. Contact support for updates.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // First Name (Disabled)
            TextFormField(
              controller: firstCtrl,
              enabled: false, // Disabled - cannot edit
              decoration: _inputDecoration(
                'First Name',
                prefixIcon: Icon(Icons.person_outline, color: scheme.onSurfaceVariant),
                enabled: false,
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),

            // Last Name (Disabled)
            TextFormField(
              controller: lastCtrl,
              enabled: false, // Disabled - cannot edit
              decoration: _inputDecoration(
                'Last Name',
                prefixIcon: Icon(Icons.person_outline, color: scheme.onSurfaceVariant),
                enabled: false,
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 12),

            // Email (Editable)
            TextFormField(
              controller: emailCtrl,
              enabled: true, // Email is now editable
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                'Email',
                prefixIcon: Icon(Icons.email_outlined, color: scheme.onSurfaceVariant),
                enabled: true,
              ),
              validator: _emailValidator,
            ),
            const SizedBox(height: 12),

            // Mobile (Read-only - always disabled)
            TextFormField(
              readOnly: true,
              enabled: false,
              controller: mobileCtrl,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                'Mobile Number',
                prefixIcon: Icon(Icons.phone_outlined, color: scheme.onSurfaceVariant),
                enabled: false,
              ),
            ),
            const SizedBox(height: 12),

            // Password (Editable)
            TextFormField(
              controller: pwdCtrl,
              obscureText: pwdObscure,
              decoration: _inputDecoration(
                'Password',
                prefixIcon: Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
                suffix: _passwordToggle(true),
              ),
              validator: _passwordValidator,
            ),
            const SizedBox(height: 12),

            // Confirm Password (Editable)
            TextFormField(
              controller: confirmCtrl,
              obscureText: confirmObscure,
              decoration: _inputDecoration(
                'Confirm Password',
                prefixIcon: Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
                suffix: _passwordToggle(false),
              ),
              validator: _confirmPasswordValidator,
            ),

            const SizedBox(height: 24),

            // Government ID Section
            Text('Government ID', style: textTheme.titleMedium),
            const SizedBox(height: 12),

            // Govt ID Verification (One-time only)
            _buildGovtIdButton(),

            const SizedBox(height: 24),

            // Address Section
            Text('Address', style: textTheme.titleMedium),
            const SizedBox(height: 12),

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
                              'Delivery Address',
                              style: textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addressCtrl.text.isEmpty
                                  ? 'Select your address on map'
                                  : addressCtrl.text,
                              style: textTheme.bodyMedium?.copyWith(
                                color: addressCtrl.text.isEmpty
                                    ? scheme.onSurfaceVariant
                                    : scheme.onSurface,
                                fontWeight: addressCtrl.text.isEmpty
                                    ? FontWeight.normal
                                    : FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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

            const SizedBox(height: 24),

            // Terms and Conditions
            Row(
              children: [
                Checkbox(
                  value: acceptedTerms,
                  onChanged: (v) => setState(() => acceptedTerms = v ?? false),
                  activeColor: scheme.primary,
                ),
                Expanded(
                  child: Text(
                    "I accept the terms & conditions",
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saving ? null : saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}


// -----------------------------------------------------------------
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// import '../../../didit_demo_screen.dart';
// import '../../../services/api_service.dart';
// import '../../../widgets/address_selection_screen.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   // Controllers
//   final firstCtrl = TextEditingController();
//   final lastCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final mobileCtrl = TextEditingController();
//   final addressCtrl = TextEditingController();
//   final pwdCtrl = TextEditingController();
//   final confirmCtrl = TextEditingController();
//   final govtIdNumberCtrl = TextEditingController();
//
//   String deviceType = Platform.isAndroid ? "android" : "ios";
//
//   // Address variables with lat/lng
//   String? _selectedAddress;
//   double? _selectedLat;
//   double? _selectedLng;
//   String? _selectedCity;
//   String? _selectedCityName;
//
//   // Govt ID
//   String? govtIdType;
//   XFile? profileImage;
//   XFile? govtIdImage;
//
//   bool saving = false;
//   bool acceptedTerms = false;
//   bool isDocumentVerified = false;
//
//   // Password visibility
//   bool pwdObscure = true;
//   bool confirmObscure = true;
//
//   Future<String> getDeviceId() async {
//     final deviceInfo = DeviceInfoPlugin();
//
//     if (Platform.isAndroid) {
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       return androidInfo.id;
//     } else {
//       IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//       return iosInfo.identifierForVendor ?? "";
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }
//
//   @override
//   void dispose() {
//     firstCtrl.dispose();
//     lastCtrl.dispose();
//     emailCtrl.dispose();
//     mobileCtrl.dispose();
//     addressCtrl.dispose();
//     pwdCtrl.dispose();
//     confirmCtrl.dispose();
//     govtIdNumberCtrl.dispose();
//     super.dispose();
//   }
//
//   /// ---------- LOAD USER DATA ----------
//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userJson = prefs.getString("user");
//
//     if (userJson != null) {
//       final data = jsonDecode(userJson);
//
//       // Name
//       final fullName = data["name"] ?? '';
//       final nameParts = fullName.split(' ');
//       firstCtrl.text = nameParts.isNotEmpty ? nameParts[0] : '';
//       lastCtrl.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
//
//       // Contact
//       emailCtrl.text = data["email"] ?? '';
//       mobileCtrl.text = data["mobile"] ?? '';
//
//       // Address with lat/lng
//       if (data["address_line1"] != null) {
//         final addressParts = [
//           data["address_line1"],
//           data["address_line2"],
//           data["city"],
//           data["state"],
//           data["country"],
//           data["postal_code"],
//         ].where((s) => s != null && s.toString().isNotEmpty).join(', ');
//
//         addressCtrl.text = addressParts;
//
//         if (data["latitude"] != null && data["longitude"] != null) {
//           _selectedLat = double.tryParse(data["latitude"].toString());
//           _selectedLng = double.tryParse(data["longitude"].toString());
//         }
//       } else {
//         addressCtrl.text = data["city"] ?? '';
//       }
//
//       // Government ID
//       govtIdType = data["gov_id_type"];
//       govtIdNumberCtrl.text = data["gov_id_number"] ?? '';
//
//       // Check if document is already verified
//       if (data["gov_id_verified"] == true ||
//           (data["government_id_documents"] != null &&
//               (data["government_id_documents"] as List).isNotEmpty)) {
//         isDocumentVerified = true;
//       }
//
//       // Profile photo
//       if (data["profile_photo"] != null && data["profile_photo"].toString().isNotEmpty) {
//         profileImage = XFile(data["profile_photo"]);
//       }
//
//       setState(() {});
//     }
//   }
//
//   /// ---------- ADDRESS SELECTION WITH MAP ----------
//   Future<void> _openMapAddressPicker() async {
//     final result = await Navigator.push<Map<String, dynamic>>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddressSelectionScreen(
//           initialAddress: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
//           initialLat: _selectedLat,
//           initialLng: _selectedLng,
//         ),
//       ),
//     );
//
//     if (result != null) {
//       setState(() {
//         addressCtrl.text = result['address'];
//         _selectedLat = result['lat'];
//         _selectedLng = result['lng'];
//         _selectedAddress = result['address'];
//         _selectedCity = result['city'];
//       });
//     }
//   }
//
//   /// ---------- IMAGE PICKER ----------
//   Future<void> pickImage(bool isProfile) async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//
//     final compressed = await FlutterImageCompress.compressAndGetFile(
//       picked.path,
//       '${picked.path}_compressed.jpg',
//       quality: 70,
//     );
//
//     setState(() {
//       if (isProfile) {
//         profileImage = compressed != null ? XFile(compressed.path) : null;
//       } else {
//         govtIdImage = compressed != null ? XFile(compressed.path) : null;
//       }
//     });
//   }
//
//   /// ---------- VALIDATORS ----------
//   String? _requiredValidator(String? v) =>
//       v == null || v.trim().isEmpty ? 'Required' : null;
//
//   String? _emailValidator(String? v) {
//     if (v == null || v.isEmpty) return 'Required';
//     final regex = RegExp(r'^\S+@\S+\.\S+$');
//     if (!regex.hasMatch(v)) return 'Invalid email';
//     return null;
//   }
//
//   String? _passwordValidator(String? v) {
//     if (v == null || v.isEmpty) return 'Required';
//     if (v.length < 6) return 'Password must be at least 6 chars';
//     return null;
//   }
//
//   String? _confirmPasswordValidator(String? v) {
//     if (v == null || v.isEmpty) return 'Required';
//     if (v != pwdCtrl.text) return 'Passwords do not match';
//     return null;
//   }
//
//   /// ---------- SAVE PROFILE API ----------
//   Future<void> saveProfile() async {
//     String deviceType = Platform.isAndroid ? "android" : "ios";
//     String deviceId = await getDeviceId();
//
//     if (!_formKey.currentState!.validate()) return;
//
//     if (!acceptedTerms) {
//       Fluttertoast.showToast(msg: "Please accept the terms & conditions");
//       return;
//     }
//
//     if (addressCtrl.text.trim().isEmpty) {
//       Fluttertoast.showToast(msg: "Please select address");
//       return;
//     }
//
//     setState(() => saving = true);
//
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString("api_token");
//
//     if (token == null) {
//       Fluttertoast.showToast(msg: "Session expired. Please login again.");
//       setState(() => saving = false);
//       return;
//     }
//
//     String addressLine1 = addressCtrl.text.trim();
//
//     // Prepare profile photo file
//     File? profileFile;
//     if (profileImage != null) {
//       if (profileImage!.path.startsWith('http')) {
//         profileFile = await _downloadTempFile(profileImage!.path);
//       } else {
//         profileFile = File(profileImage!.path);
//       }
//     }
//
//     print("====== FINAL API DATA ======");
//     print("Name: ${firstCtrl.text.trim()} ${lastCtrl.text.trim()}");
//     print("Email: ${emailCtrl.text.trim()}");
//     print("City: $_selectedCity");
//     print("Address: $addressLine1");
//
//     final res = await ApiService.multipart(
//       endpoint: "/vendor/complete-profile",
//       token: token,
//       fields: {
//         "name": "${firstCtrl.text.trim()} ${lastCtrl.text.trim()}",
//         "email": emailCtrl.text.trim(),
//         "mobile": mobileCtrl.text.trim(),
//         "password": pwdCtrl.text.trim(),
//         "password_confirmation": confirmCtrl.text.trim(),
//
//         "address_line1": addressLine1,
//         "address_line2": "",
//
//         "city": _selectedCity?.toString() ?? "",
//         "state": "City",
//         "country": "tajikistan",
//         "postal_code": "12232",
//
//         "latitude": _selectedLat?.toString() ?? "",
//         "longitude": _selectedLng?.toString() ?? "",
//
//         "terms_accepted": acceptedTerms ? "1" : "0",
//         "alt_mobile": mobileCtrl.text.trim(),
//
//         "device_id": deviceId,
//         "device_type": deviceType,
//         "fcm_token": "1234321",
//       },
//       files: {
//         if (profileFile != null) "profile_photo": profileFile,
//       },
//     );
//
//     setState(() => saving = false);
//
//     if (res["success"] == true || res["status"] == true) {
//       Fluttertoast.showToast(msg: "Profile updated successfully 🎉");
//
//       // Update local storage
//       final userJson = prefs.getString("user");
//       if (userJson != null) {
//         final userData = jsonDecode(userJson);
//         userData["name"] = "${firstCtrl.text.trim()} ${lastCtrl.text.trim()}";
//         userData["email"] = emailCtrl.text.trim();
//         await prefs.setString("user", jsonEncode(userData));
//         await prefs.setString("user_name", "${firstCtrl.text.trim()} ${lastCtrl.text.trim()}");
//         await prefs.setString("user_email", emailCtrl.text.trim());
//       }
//
//       if (_selectedCity != null) {
//         await prefs.setString("user_city", _selectedCity!.toString());
//       }
//
//       if (context.mounted) Navigator.pop(context, true);
//     } else {
//       Fluttertoast.showToast(msg: res["message"] ?? "Profile update failed");
//     }
//   }
//
//   /// ---------- DOWNLOAD TEMP FILE ----------
//   Future<File> _downloadTempFile(String url) async {
//     final response = await http.get(Uri.parse(url));
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
//     return file.writeAsBytes(response.bodyBytes);
//   }
//
//   /// ---------- INPUT DECORATION ----------
//   InputDecoration _inputDecoration(String label, {Widget? suffix, Widget? prefixIcon, bool enabled = true}) {
//     return InputDecoration(
//       labelText: label,
//       filled: true,
//       fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
//       isDense: true,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       suffixIcon: suffix,
//       prefixIcon: prefixIcon,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
//       ),
//     );
//   }
//
//   Widget _passwordToggle(bool isPwd) {
//     return IconButton(
//       icon: Icon(
//           isPwd
//               ? (pwdObscure ? Icons.visibility_off : Icons.visibility)
//               : (confirmObscure ? Icons.visibility_off : Icons.visibility)
//       ),
//       onPressed: () {
//         setState(() {
//           if (isPwd) {
//             pwdObscure = !pwdObscure;
//           } else {
//             confirmObscure = !confirmObscure;
//           }
//         });
//       },
//     );
//   }
//
//   /// ---------- PROFILE IMAGE (EDITABLE) ----------
//   Widget _buildProfileImage() {
//     final cs = Theme.of(context).colorScheme;
//
//     return Stack(
//       alignment: Alignment.bottomRight,
//       children: [
//         if (profileImage == null)
//           CircleAvatar(
//             radius: 42,
//             backgroundColor: cs.surfaceContainerHighest,
//             child: Icon(Icons.person, size: 36, color: cs.onSurfaceVariant),
//           )
//         else
//           CircleAvatar(
//             radius: 42,
//             backgroundColor: cs.surfaceContainerHighest,
//             child: ClipOval(
//               child: Image.file(
//                 File(profileImage!.path),
//                 width: 84,
//                 height: 84,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) =>
//                     Icon(Icons.person, size: 36, color: cs.onSurfaceVariant),
//               ),
//             ),
//           ),
//         InkWell(
//           onTap: () => pickImage(true),
//           child: CircleAvatar(
//             radius: 16,
//             backgroundColor: cs.primary,
//             child: Icon(Icons.edit, size: 14, color: cs.onPrimary),
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// ---------- GOVT ID VERIFICATION WIDGET ----------
//   Widget _buildGovtIdButton() {
//     final scheme = Theme.of(context).colorScheme;
//
//     if (isDocumentVerified) {
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.green.shade50, Colors.green.shade100],
//           ),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.green, width: 1),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.green,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.verified, color: Colors.white, size: 20),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Document Verified',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green.shade800,
//                     ),
//                   ),
//                   Text(
//                     'Your identity has been verified',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.green.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(Icons.lock, color: Colors.green.shade600, size: 18),
//           ],
//         ),
//       );
//     }
//
//     return OutlinedButton.icon(
//       onPressed: () async {
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const VerificationScreen(),
//           ),
//         );
//
//         if (result == true) {
//           setState(() {
//             isDocumentVerified = true;
//           });
//
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setBool("gov_id_verified", true);
//
//           Fluttertoast.showToast(
//             msg: "Document verified successfully!",
//             backgroundColor: Colors.green,
//           );
//         } else if (result == false) {
//           Fluttertoast.showToast(
//             msg: "Verification failed. Please try again.",
//             backgroundColor: Colors.red,
//           );
//         }
//       },
//       icon: const Icon(Icons.verified_user, size: 18),
//       label: const Text('Verify Document'),
//       style: OutlinedButton.styleFrom(
//         foregroundColor: scheme.primary,
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         side: BorderSide(color: scheme.primary),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: scheme.surface,
//         foregroundColor: scheme.onSurface,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             // Profile Image (Editable)
//             Center(child: _buildProfileImage()),
//
//             const SizedBox(height: 8),
//
//             Center(
//               child: Text(
//                 'Tap on edit icon to change photo',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // Basic Information Section
//             Text('Basic Information', style: textTheme.titleMedium),
//             const SizedBox(height: 12),
//
//             // First Name (Editable)
//             TextFormField(
//               controller: firstCtrl,
//               enabled: true,
//               decoration: _inputDecoration(
//                 'First Name',
//                 prefixIcon: Icon(Icons.person_outline, color: scheme.onSurfaceVariant),
//                 enabled: true,
//               ),
//               validator: _requiredValidator,
//             ),
//             const SizedBox(height: 12),
//
//             // Last Name (Editable)
//             TextFormField(
//               controller: lastCtrl,
//               enabled: true,
//               decoration: _inputDecoration(
//                 'Last Name',
//                 prefixIcon: Icon(Icons.person_outline, color: scheme.onSurfaceVariant),
//                 enabled: true,
//               ),
//               validator: _requiredValidator,
//             ),
//             const SizedBox(height: 12),
//
//             // Email (Editable)
//             TextFormField(
//               controller: emailCtrl,
//               enabled: true,
//               keyboardType: TextInputType.emailAddress,
//               decoration: _inputDecoration(
//                 'Email',
//                 prefixIcon: Icon(Icons.email_outlined, color: scheme.onSurfaceVariant),
//                 enabled: true,
//               ),
//               validator: _emailValidator,
//             ),
//             const SizedBox(height: 12),
//
//             // Mobile (Read-only)
//             TextFormField(
//               readOnly: true,
//               enabled: false,
//               controller: mobileCtrl,
//               keyboardType: TextInputType.phone,
//               decoration: _inputDecoration(
//                 'Mobile Number',
//                 prefixIcon: Icon(Icons.phone_outlined, color: scheme.onSurfaceVariant),
//                 enabled: false,
//               ),
//             ),
//             const SizedBox(height: 12),
//
//             // Password (Editable)
//             TextFormField(
//               controller: pwdCtrl,
//               obscureText: pwdObscure,
//               decoration: _inputDecoration(
//                 'Password',
//                 prefixIcon: Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
//                 suffix: _passwordToggle(true),
//               ),
//               validator: _passwordValidator,
//             ),
//             const SizedBox(height: 12),
//
//             // Confirm Password (Editable)
//             TextFormField(
//               controller: confirmCtrl,
//               obscureText: confirmObscure,
//               decoration: _inputDecoration(
//                 'Confirm Password',
//                 prefixIcon: Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
//                 suffix: _passwordToggle(false),
//               ),
//               validator: _confirmPasswordValidator,
//             ),
//
//             const SizedBox(height: 24),
//
//             // Government ID Section
//             Text('Government ID', style: textTheme.titleMedium),
//             const SizedBox(height: 12),
//
//             _buildGovtIdButton(),
//
//             const SizedBox(height: 24),
//
//             // Address Section
//             Text('Address', style: textTheme.titleMedium),
//             const SizedBox(height: 12),
//
//             // Address Selection Card with Map
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: scheme.outlineVariant),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: InkWell(
//                 onTap: _openMapAddressPicker,
//                 borderRadius: BorderRadius.circular(12),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: scheme.primary.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Icon(
//                           Icons.map_outlined,
//                           color: scheme.primary,
//                           size: 24,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Delivery Address',
//                               style: textTheme.labelMedium?.copyWith(
//                                 color: scheme.onSurfaceVariant,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               addressCtrl.text.isEmpty
//                                   ? 'Select your address on map'
//                                   : addressCtrl.text,
//                               style: textTheme.bodyMedium?.copyWith(
//                                 color: addressCtrl.text.isEmpty
//                                     ? scheme.onSurfaceVariant
//                                     : scheme.onSurface,
//                                 fontWeight: addressCtrl.text.isEmpty
//                                     ? FontWeight.normal
//                                     : FontWeight.w500,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                       Icon(
//                         Icons.chevron_right,
//                         color: scheme.onSurfaceVariant,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // Terms and Conditions
//             Row(
//               children: [
//                 Checkbox(
//                   value: acceptedTerms,
//                   onChanged: (v) => setState(() => acceptedTerms = v ?? false),
//                   activeColor: scheme.primary,
//                 ),
//                 Expanded(
//                   child: Text(
//                     "I accept the terms & conditions",
//                     style: textTheme.bodyMedium,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//
//             // Save Button
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: saving ? null : saveProfile,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: scheme.primary,
//                   foregroundColor: scheme.onPrimary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: saving
//                     ? const SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                 )
//                     : const Text(
//                   'Save Changes',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 40),
//           ]),
//         ),
//       ),
//     );
//   }
// }