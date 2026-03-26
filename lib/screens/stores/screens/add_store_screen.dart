// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/services.dart';
//
// import '../controller/add_store_controller.dart';
// import '../../../widgets/address_selection_screen.dart';
//
// class AddStoreScreen extends StatefulWidget {
//   const AddStoreScreen({super.key});
//
//   @override
//   State<AddStoreScreen> createState() => _AddStoreScreenState();
// }
//
// class _AddStoreScreenState extends State<AddStoreScreen> {
//
//   final nameCtrl = TextEditingController();
//   final mobileCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final addressCtrl = TextEditingController();
//   final descCtrl = TextEditingController();
//
//   // New variables for address coordinates
//   double? _selectedLat;
//   double? _selectedLng;
//
//   // Image dimension tracking
//   Map<String, dynamic>? _logoDimensions;
//   Map<String, dynamic>? _backgroundDimensions;
//   XFile? storeProofImage;
//   XFile? storeBackgroundImage;
//
//   // Required dimensions - updated for background
//   final Map<String, Map<String, dynamic>> _requiredDimensions = {
//     'logo': {
//       'minWidth': 200,
//       'minHeight': 200,
//       'maxWidth': 500,
//       'maxHeight': 500,
//       'description': '200x200 - 500x500 pixels',
//     },
//     'background': {
//       'requiredWidth': 1408,
//       'requiredHeight': 768,
//       'description': '1408x768 pixels',
//     },
//   };
//
//   @override
//   void dispose() {
//     nameCtrl.dispose();
//     mobileCtrl.dispose();
//     emailCtrl.dispose();
//     addressCtrl.dispose();
//     descCtrl.dispose();
//     super.dispose();
//   }
//
//   /// Get image dimensions
//   Future<Map<String, dynamic>?> _getImageDimensions(File file) async {
//     try {
//       final bytes = await file.readAsBytes();
//       final image = await decodeImageFromList(bytes);
//       await Future.delayed(Duration.zero);
//       return {
//         'width': image.width,
//         'height': image.height,
//       };
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'Failed to read image dimensions');
//       return null;
//     }
//   }
//
//   /// Logo validation - size check
//   bool _validateLogoDimensions(
//       Map<String, dynamic> dimensions,
//       Map<String, dynamic> requirements,
//       ) {
//     final width = dimensions['width'] as int;
//     final height = dimensions['height'] as int;
//
//     // Check minimum dimensions
//     if (width < (requirements['minWidth'] as int) ||
//         height < (requirements['minHeight'] as int)) {
//       _showDimensionError(
//           'Image too small',
//           'Minimum size: ${requirements['minWidth']}x${requirements['minHeight']}px\n'
//               'Your image: ${width}x${height}px'
//       );
//       return false;
//     }
//
//     // Check maximum dimensions
//     if (width > (requirements['maxWidth'] as int) ||
//         height > (requirements['maxHeight'] as int)) {
//       _showDimensionError(
//           'Image too large',
//           'Maximum size: ${requirements['maxWidth']}x${requirements['maxHeight']}px\n'
//               'Your image: ${width}x${height}px'
//       );
//       return false;
//     }
//
//     return true;
//   }
//
//   /// Background validation - exact 1408x768 check
//   bool _validateBackgroundDimensions(
//       Map<String, dynamic> dimensions,
//       Map<String, dynamic> requirements,
//       ) {
//     final width = dimensions['width'] as int;
//     final height = dimensions['height'] as int;
//
//     final requiredWidth = requirements['requiredWidth'] as int;
//     final requiredHeight = requirements['requiredHeight'] as int;
//
//     // Check exact dimensions
//     if (width != requiredWidth || height != requiredHeight) {
//       _showDimensionError(
//           'Invalid Background Image',
//           'Required size: ${requiredWidth}x${requiredHeight}px\n'
//               'Your image: ${width}x${height}px\n\n'
//               'Please upload an image with exact dimensions 1408x768 pixels.'
//       );
//       return false;
//     }
//
//     return true;
//   }
//
//   void _showDimensionError(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Updated image picker with validation
//   Future<void> _pickImageWithValidation(
//       BuildContext context,
//       AddStoreController c,
//       String imageType,
//       ) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//
//       /// Pick image
//       final XFile? pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 80,
//       );
//
//       if (pickedFile == null) return;
//
//       /// Convert only for dimension checking
//       final File file = File(pickedFile.path);
//
//       /// Get dimensions
//       final dimensions = await _getImageDimensions(file);
//       if (dimensions == null) return;
//
//       /// ================= LOGO =================
//       if (imageType == 'logo') {
//         final isValid = _validateLogoDimensions(
//           dimensions,
//           _requiredDimensions['logo']!,
//         );
//
//         if (!isValid) return;
//
//         setState(() {
//           /// ✅ IMPORTANT FIX (NO CASTING)
//           c.storeProofImage = pickedFile;
//           _logoDimensions = dimensions;
//         });
//
//         /// notify provider UI
//         c.notifyListeners();
//
//         Fluttertoast.showToast(
//           msg:
//           'Logo uploaded (${dimensions['width']}x${dimensions['height']})',
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//         );
//       }
//
//       /// ================= BACKGROUND =================
//       else if (imageType == 'background') {
//         final isValid = _validateBackgroundDimensions(
//           dimensions,
//           _requiredDimensions['background']!,
//         );
//
//         if (!isValid) return;
//
//         setState(() {
//           /// ✅ IMPORTANT FIX (NO CASTING)
//           c.storeBackgroundImage = pickedFile;
//           _backgroundDimensions = dimensions;
//         });
//
//         /// notify provider UI
//         c.notifyListeners();
//
//         Fluttertoast.showToast(
//           msg:
//           'Background uploaded (${dimensions['width']}x${dimensions['height']})',
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//         );
//       }
//     } catch (e) {
//       debugPrint("Image Pick Error: $e");
//
//       Fluttertoast.showToast(
//         msg: "Failed to pick image",
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//     }
//   }
//
//   /// Updated address picker
//   Future<void> _openAddressPicker(AddStoreController c) async {
//     final result = await Navigator.push<Map<String, dynamic>>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddressSelectionScreen(
//           initialAddress: addressCtrl.text.isNotEmpty ? addressCtrl.text : null,
//           initialLat: _selectedLat,
//           initialLng: _selectedLng,
//           onAddressSelected: (address, lat, lng) {
//             Navigator.pop(context, {
//               'address': address,
//               'lat': lat,
//               'lng': lng,
//             });
//           },
//         ),
//       ),
//     );
//
//     if (result != null) {
//       setState(() {
//         addressCtrl.text = result['address'];
//         _selectedLat = result['lat'];
//         _selectedLng = result['lng'];
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return ChangeNotifierProvider(
//       create: (_) => AddStoreController(),
//       child: Consumer<AddStoreController>(
//         builder: (context, c, _) {
//
//           return Scaffold(
//
//             backgroundColor: Colors.grey[100],
//
//             appBar: AppBar(
//               title: const Text("Create Store"),
//               backgroundColor: Colors.white,
//               elevation: 0,
//               foregroundColor: Colors.black,
//             ),
//
//             body: Form(
//               key: c.formKey,
//
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//
//                     /// STORE INFO
//                     sectionTitle("Store Information"),
//
//                     label("Store Name *"),
//                     textField(nameCtrl, "Enter store name"),
//
//                     label("Mobile Number *"),
//                     textField(
//                       mobileCtrl,
//                       "Enter mobile number",
//                       keyboard: TextInputType.phone,
//                     ),
//
//                     label("Email *"),
//                     textField(
//                       emailCtrl,
//                       "Enter email",
//                       keyboard: TextInputType.emailAddress,
//                     ),
//
//                     label("Address *"),
//                     InkWell(
//                       onTap: () => _openAddressPicker(c),
//                       child: InputDecorator(
//                         decoration: inputDecoration("Tap to select location on map").copyWith(
//                           suffixIcon: Icon(Icons.map_outlined, color: Colors.grey),
//                         ),
//                         child: Text(
//                           addressCtrl.text.isEmpty
//                               ? "Select location on map"
//                               : addressCtrl.text,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ),
//                     if (_selectedLat != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 4, left: 12),
//                         child: Text(
//                           '📍 ${_selectedLat!.toStringAsFixed(4)}, ${_selectedLng!.toStringAsFixed(4)}',
//                           style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//                         ),
//                       ),
//
//                     label("Store Type *"),
//                     // Multiple selection for store types
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Column(
//                         children: c.storeTypes.map((type) {
//                           return CheckboxListTile(
//                             title: Text(type['label']!),
//                             value: c.selectedStoreTypes.contains(type['value']),
//                             onChanged: (selected) {
//                               setState(() {
//                                 if (selected == true) {
//                                   c.selectedStoreTypes.add(type['value']!);
//                                 } else {
//                                   c.selectedStoreTypes.remove(type['value']!);
//                                 }
//                                 c.notifyListeners();
//                               });
//                             },
//                             controlAffinity: ListTileControlAffinity.leading,
//                             dense: true,
//                             contentPadding: const EdgeInsets.symmetric(horizontal: 8),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                     if (c.selectedStoreTypes.isEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 4, left: 12),
//                         child: Text(
//                           'Please select at least one store type',
//                           style: TextStyle(fontSize: 12, color: Colors.red.shade700),
//                         ),
//                       ),
//
//                     const SizedBox(height: 10),
//
//                     SwitchListTile(
//                       title: const Text("Self Pickup"),
//                       value: c.selfPickup,
//                       onChanged: (v) {
//                         c.selfPickup = v;
//                         c.notifyListeners();
//                       },
//                     ),
//
//                     SwitchListTile(
//                       title: const Text("Delivery By Seller"),
//                       value: c.deliveryBySeller,
//                       onChanged: (v) {
//                         c.deliveryBySeller = v;
//                         c.notifyListeners();
//                       },
//                     ),
//
//                     /// TIMING
//                     sectionTitle("Store Timing"),
//
//                     Row(
//                       children: [
//
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () =>
//                                 c.pickTime(context, true),
//                             child: Text(
//                               c.openingTime == null
//                                   ? "Opening Time"
//                                   : c.openingTime!
//                                   .format(context),
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(width: 12),
//
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () =>
//                                 c.pickTime(context, false),
//                             child: Text(
//                               c.closingTime == null
//                                   ? "Closing Time"
//                                   : c.closingTime!
//                                   .format(context),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     /// BACKGROUND IMAGE
//                     sectionTitle("Store Background Image *"),
//
//                     // Requirement info box with exact size requirement
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       margin: const EdgeInsets.only(bottom: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue.shade200),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.info_outline, color: Colors.blue, size: 18),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   'Background Image Requirements:',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blue.shade700,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '• Exact size required: ${_requiredDimensions['background']!['description']}',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           Text(
//                             '• Please ensure your image is exactly 1408x768 pixels',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.red.shade700,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Background image upload/display
//                     if (c.storeBackgroundImage == null) ...[
//                       uploadBox(
//                         title: "Tap to Upload Background Image",
//                         subtitle: "Must be exactly 1408x768 pixels",
//                         icon: Icons.image,
//                         onTap: () => _pickImageWithValidation(context, c, 'background'),
//                       ),
//                     ] else ...[
//                       Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.file(
//                               File(c.storeBackgroundImage!.path),
//                               height: 180,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   c.clearStoreBackground();
//                                   _backgroundDimensions = null;
//                                 });
//                               },
//                               child: const CircleAvatar(
//                                 radius: 14,
//                                 backgroundColor: Colors.red,
//                                 child: Icon(Icons.close, color: Colors.white, size: 16),
//                               ),
//                             ),
//                           ),
//                           if (_backgroundDimensions != null)
//                             Positioned(
//                               bottom: 8,
//                               left: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black54,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   '${_backgroundDimensions!['width']} x ${_backgroundDimensions!['height']} px',
//                                   style: const TextStyle(color: Colors.white, fontSize: 11),
//                                 ),
//                               ),
//                             ),
//                           // FIXED: Changed the condition to use correct dimensions (1408x768)
//                           if (_backgroundDimensions != null &&
//                               (_backgroundDimensions!['width'] != 1408 || _backgroundDimensions!['height'] != 768))
//                             Positioned(
//                               top: 8,
//                               left: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   'Wrong Size! Must be 1408x768',
//                                   style: TextStyle(color: Colors.white, fontSize: 10),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//
//                     const SizedBox(height: 20),
//
//                     /// STORE LOGO
//                     sectionTitle("Store Logo *"),
//
//                     // Simple requirement info box
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       margin: const EdgeInsets.only(bottom: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue.shade200),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline, color: Colors.blue, size: 18),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Required size: ${_requiredDimensions['logo']!['description']}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.blue.shade700,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Logo upload/display
//                     if (c.storeProofImage == null) ...[
//                       uploadBox(
//                         title: "Tap to Upload Logo",
//                         subtitle: "200x200 to 500x500 pixels",
//                         icon: Icons.store,
//                         onTap: () => _pickImageWithValidation(context, c, 'logo'),
//                       ),
//                     ] else ...[
//                       Stack(
//                         children: [
//                           Container(
//                             height: 180,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.grey.shade300),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.file(
//                                 File(c.storeProofImage!.path),
//                                 height: 180,
//                                 width: double.infinity,
//                                 fit: BoxFit.contain,
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   c.clearStoreProof();
//                                   _logoDimensions = null;
//                                 });
//                               },
//                               child: const CircleAvatar(
//                                 radius: 14,
//                                 backgroundColor: Colors.red,
//                                 child: Icon(Icons.close, color: Colors.white, size: 16),
//                               ),
//                             ),
//                           ),
//                           if (_logoDimensions != null)
//                             Positioned(
//                               bottom: 8,
//                               left: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black54,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   '${_logoDimensions!['width']} x ${_logoDimensions!['height']} px',
//                                   style: const TextStyle(color: Colors.white, fontSize: 11),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//
//                     const SizedBox(height: 20),
//
//                     /// DESCRIPTION
//                     sectionTitle("Description"),
//
//                     textField(
//                       descCtrl,
//                       "Enter store description",
//                       maxLines: 3,
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     /// SUBMIT BUTTON
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//
//                       child: ElevatedButton(
//
//                         onPressed: c.submitting
//                             ? null
//                             : () async {
//
//                           if (!c.formKey.currentState!.validate())
//                             return;
//
//                           // Check if at least one store type is selected
//                           if (c.selectedStoreTypes.isEmpty) {
//                             Fluttertoast.showToast(msg: "Please select at least one store type");
//                             return;
//                           }
//
//                           if (c.storeBackgroundImage == null) {
//                             Fluttertoast.showToast(msg: "Background image required");
//                             return;
//                           }
//
//                           // Verify background image dimensions again before submission
//                           if (_backgroundDimensions != null) {
//                             // FIXED: Changed from 1920/1080 to 1408/768
//                             if (_backgroundDimensions!['width'] != 1408 ||
//                                 _backgroundDimensions!['height'] != 768) {
//                               Fluttertoast.showToast(
//                                 msg: "Background image must be exactly 1408x768 pixels",
//                                 backgroundColor: Colors.red,
//                                 textColor: Colors.white,
//                               );
//                               return;
//                             }
//                           }
//
//                           if (c.storeProofImage == null) {
//                             Fluttertoast.showToast(msg: "Logo image required");
//                             return;
//                           }
//
//                           if (_selectedLat == null || _selectedLng == null) {
//                             Fluttertoast.showToast(msg: "Please select location on map");
//                             return;
//                           }
//
//                           await c.submitStore(
//                             name: nameCtrl.text,
//                             mobile: mobileCtrl.text,
//                             email: emailCtrl.text,
//                             city: addressCtrl.text,
//                             address: addressCtrl.text,
//                             description: descCtrl.text,
//                             latitude: _selectedLat.toString(),
//                             longitude: _selectedLng.toString(),
//                           );
//                         },
//
//                         child: c.submitting
//                             ? const CircularProgressIndicator(color: Colors.white)
//                             : const Text(
//                           "Create Store",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 50),
//
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   /// COMPONENTS
//
//   Widget sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20, bottom: 8),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   Widget label(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10, bottom: 6),
//       child: Text(
//         text,
//         style: const TextStyle(fontWeight: FontWeight.w600),
//       ),
//     );
//   }
//
//   Widget textField(
//       TextEditingController controller,
//       String hint, {
//         int maxLines = 1,
//         TextInputType keyboard = TextInputType.text,
//       }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboard,
//       decoration: inputDecoration(hint),
//       validator: (v) => v == null || v.isEmpty ? "Required" : null,
//     );
//   }
//
//   InputDecoration inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//     );
//   }
//
//   Widget uploadBox({
//     required String title,
//     String? subtitle,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         height: 120,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade300),
//           color: Colors.grey.shade50,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Colors.grey.shade600),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey.shade800,
//               ),
//             ),
//             if (subtitle != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey.shade500,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/services.dart';
//
// import '../controller/add_store_controller.dart';
// import '../../../widgets/address_selection_screen.dart';
// import '../../../screens/citys/CitySearchScreen.dart';
//
// class AddStoreScreen extends StatefulWidget {
//   const AddStoreScreen({super.key});
//
//   @override
//   State<AddStoreScreen> createState() => _AddStoreScreenState();
// }
//
// class _AddStoreScreenState extends State<AddStoreScreen> {
//   final nameCtrl = TextEditingController();
//   final mobileCtrl = TextEditingController();
//   final addressCtrl = TextEditingController();
//   final landmarkCtrl = TextEditingController();
//   final descCtrl = TextEditingController();
//   final cityCtrl = TextEditingController();
//
//   // New variables
//   bool _sellOffline = false;
//   String? _selectedCity;
//   double? _selectedLat;
//   double? _selectedLng;
//   String? _selectedAddress;
//
//   // Image dimension tracking
//   Map<String, dynamic>? _logoDimensions;
//   Map<String, dynamic>? _backgroundDimensions;
//
//   // Required dimensions
//   final Map<String, Map<String, dynamic>> _requiredDimensions = {
//     'logo': {
//       'minWidth': 200,
//       'minHeight': 200,
//       'maxWidth': 500,
//       'maxHeight': 500,
//       'description': '200x200 - 500x500 pixels',
//     },
//     'background': {
//       'requiredWidth': 1408,
//       'requiredHeight': 768,
//       'description': '1408x768 pixels',
//     },
//   };
//
//   @override
//   void dispose() {
//     nameCtrl.dispose();
//     mobileCtrl.dispose();
//     addressCtrl.dispose();
//     landmarkCtrl.dispose();
//     descCtrl.dispose();
//     cityCtrl.dispose();
//     super.dispose();
//   }
//
//   /// Get image dimensions
//   Future<Map<String, dynamic>?> _getImageDimensions(File file) async {
//     try {
//       final bytes = await file.readAsBytes();
//       final image = await decodeImageFromList(bytes);
//       await Future.delayed(Duration.zero);
//       return {
//         'width': image.width,
//         'height': image.height,
//       };
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'Failed to read image dimensions');
//       return null;
//     }
//   }
//
//   /// Logo validation
//   bool _validateLogoDimensions(
//       Map<String, dynamic> dimensions,
//       Map<String, dynamic> requirements,
//       ) {
//     final width = dimensions['width'] as int;
//     final height = dimensions['height'] as int;
//
//     if (width < (requirements['minWidth'] as int) ||
//         height < (requirements['minHeight'] as int)) {
//       _showDimensionError(
//           'Image too small',
//           'Minimum size: ${requirements['minWidth']}x${requirements['minHeight']}px\n'
//               'Your image: ${width}x${height}px'
//       );
//       return false;
//     }
//
//     if (width > (requirements['maxWidth'] as int) ||
//         height > (requirements['maxHeight'] as int)) {
//       _showDimensionError(
//           'Image too large',
//           'Maximum size: ${requirements['maxWidth']}x${requirements['maxHeight']}px\n'
//               'Your image: ${width}x${height}px'
//       );
//       return false;
//     }
//
//     return true;
//   }
//
//   /// Background validation
//   bool _validateBackgroundDimensions(
//       Map<String, dynamic> dimensions,
//       Map<String, dynamic> requirements,
//       ) {
//     final width = dimensions['width'] as int;
//     final height = dimensions['height'] as int;
//
//     final requiredWidth = requirements['requiredWidth'] as int;
//     final requiredHeight = requirements['requiredHeight'] as int;
//
//     if (width != requiredWidth || height != requiredHeight) {
//       _showDimensionError(
//           'Invalid Background Image',
//           'Required size: ${requiredWidth}x${requiredHeight}px\n'
//               'Your image: ${width}x${height}px\n\n'
//               'Please upload an image with exact dimensions 1408x768 pixels.'
//       );
//       return false;
//     }
//
//     return true;
//   }
//
//   void _showDimensionError(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Image picker with validation
//   Future<void> _pickImageWithValidation(
//       BuildContext context,
//       AddStoreController c,
//       String imageType,
//       ) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//
//       final XFile? pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 80,
//       );
//
//       if (pickedFile == null) return;
//
//       final File file = File(pickedFile.path);
//       final dimensions = await _getImageDimensions(file);
//       if (dimensions == null) return;
//
//       if (imageType == 'logo') {
//         final isValid = _validateLogoDimensions(
//           dimensions,
//           _requiredDimensions['logo']!,
//         );
//
//         if (!isValid) return;
//
//         setState(() {
//           c.storeProofImage = pickedFile;
//           _logoDimensions = dimensions;
//         });
//
//         c.notifyListeners();
//
//         Fluttertoast.showToast(
//           msg: 'Logo uploaded (${dimensions['width']}x${dimensions['height']})',
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//         );
//       } else if (imageType == 'background') {
//         final isValid = _validateBackgroundDimensions(
//           dimensions,
//           _requiredDimensions['background']!,
//         );
//
//         if (!isValid) return;
//
//         setState(() {
//           c.storeBackgroundImage = pickedFile;
//           _backgroundDimensions = dimensions;
//         });
//
//         c.notifyListeners();
//
//         Fluttertoast.showToast(
//           msg: 'Background uploaded (${dimensions['width']}x${dimensions['height']})',
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//         );
//       }
//     } catch (e) {
//       debugPrint("Image Pick Error: $e");
//       Fluttertoast.showToast(
//         msg: "Failed to pick image",
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//     }
//   }
//
//   /// Open city selection
//   Future<void> _selectCity() async {
//     final city = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const CitySearchScreen(),
//       ),
//     );
//
//     if (city != null) {
//       setState(() {
//         _selectedCity = city.name;
//         cityCtrl.text = city.name;
//       });
//     }
//   }
//
//   /// Open address selection on map
//   Future<void> _selectAddressOnMap() async {
//     final result = await Navigator.push<Map<String, dynamic>>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddressSelectionScreen(
//           initialAddress: _selectedAddress,
//           initialLat: _selectedLat,
//           initialLng: _selectedLng,
//           onAddressSelected: (address, lat, lng) {
//             Navigator.pop(context, {
//               'address': address,
//               'lat': lat,
//               'lng': lng,
//             });
//           },
//         ),
//       ),
//     );
//
//     if (result != null) {
//       setState(() {
//         _selectedAddress = result['address'];
//         _selectedLat = result['lat'];
//         _selectedLng = result['lng'];
//         addressCtrl.text = result['address'];
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => AddStoreController(),
//       child: Consumer<AddStoreController>(
//         builder: (context, c, _) {
//           return Scaffold(
//             backgroundColor: Colors.grey[100],
//             appBar: AppBar(
//               title: const Text("Create Store"),
//               backgroundColor: Colors.white,
//               elevation: 0,
//               foregroundColor: Colors.black,
//             ),
//             body: Form(
//               key: c.formKey,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// STORE INFO
//                     sectionTitle("Store Information"),
//                     label("Store Name *"),
//                     textField(nameCtrl, "Enter store name"),
//
//                     label("Mobile Number *"),
//                     textField(
//                       mobileCtrl,
//                       "Enter mobile number",
//                       keyboard: TextInputType.phone,
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     /// DO YOU SELL OFFLINE? TOGGLE
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade300),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 "Do you sell offline?",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 "Enable if you have a physical store location",
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Switch(
//                             value: _sellOffline,
//                             onChanged: (value) {
//                               setState(() {
//                                 _sellOffline = value;
//                                 if (!value) {
//                                   // Clear address fields when switching to online only
//                                   _selectedCity = null;
//                                   _selectedAddress = null;
//                                   _selectedLat = null;
//                                   _selectedLng = null;
//                                   cityCtrl.clear();
//                                   addressCtrl.clear();
//                                 }
//                               });
//                             },
//                             activeColor: Colors.black,
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     /// CITY SELECTION (Always shown)
//                     label("City *"),
//                     InkWell(
//                       onTap: _selectCity,
//                       child: InputDecorator(
//                         decoration: inputDecoration("Select city").copyWith(
//                           suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//                         ),
//                         child: Text(
//                           _selectedCity ?? "Select city",
//                           style: TextStyle(
//                             color: _selectedCity == null ? Colors.grey : Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     /// ADDRESS FIELDS (Only shown if selling offline)
//                     if (_sellOffline) ...[
//                       // const SizedBox(height: 16),
//                       // label("Address *"),
//                       // InkWell(
//                       //   onTap: _selectAddressOnMap,
//                       //   child: InputDecorator(
//                       //     decoration: inputDecoration("Select location on map").copyWith(
//                       //       suffixIcon: Icon(Icons.map_outlined, color: Colors.grey),
//                       //     ),
//                       //     child: Text(
//                       //       _selectedAddress ?? "Tap to select location on map",
//                       //       maxLines: 2,
//                       //       overflow: TextOverflow.ellipsis,
//                       //       style: TextStyle(
//                       //         color: _selectedAddress == null ? Colors.grey : Colors.black,
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),
//                       // if (_selectedLat != null)
//                       //   Padding(
//                       //     padding: const EdgeInsets.only(top: 4, left: 12),
//                       //     child: Text(
//                       //       '📍 ${_selectedLat!.toStringAsFixed(4)}, ${_selectedLng!.toStringAsFixed(4)}',
//                       //       style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//                       //     ),
//                       //   ),
//                       const SizedBox(height: 8),
//                       label("Address *"),
//                       textField(addressCtrl, "Enter Address"),
//
//                       const SizedBox(height: 8),
//                       label("Landmark (Optional)"),
//                       textField(landmarkCtrl, "Enter landmark (e.g., near city mall)"),
//                     ],
//
//                     const SizedBox(height: 8),
//
//                     SwitchListTile(
//                       title: const Text("Self Pickup"),
//                       value: c.selfPickup,
//                       onChanged: (v) {
//                         c.selfPickup = v;
//                         c.notifyListeners();
//                       },
//                     ),
//
//                     SwitchListTile(
//                       title: const Text("Delivery By Seller"),
//                       value: c.deliveryBySeller,
//                       onChanged: (v) {
//                         c.deliveryBySeller = v;
//                         c.notifyListeners();
//                       },
//                     ),
//
//                     /// TIMING
//                     sectionTitle("Store Timing"),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => c.pickTime(context, true),
//                             child: Text(
//                               c.openingTime == null
//                                   ? "Opening Time"
//                                   : c.openingTime!.format(context),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => c.pickTime(context, false),
//                             child: Text(
//                               c.closingTime == null
//                                   ? "Closing Time"
//                                   : c.closingTime!.format(context),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     /// BACKGROUND IMAGE
//                     sectionTitle("Store Background Image *"),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       margin: const EdgeInsets.only(bottom: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue.shade200),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(Icons.info_outline, color: Colors.blue, size: 18),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   'Background Image Requirements:',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blue.shade700,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             '• Exact size required: ${_requiredDimensions['background']!['description']}',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           Text(
//                             '• Please ensure your image is exactly 1408x768 pixels',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.red.shade700,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     if (c.storeBackgroundImage == null) ...[
//                       uploadBox(
//                         title: "Tap to Upload Background Image",
//                         subtitle: "Must be exactly 1408x768 pixels",
//                         icon: Icons.image,
//                         onTap: () => _pickImageWithValidation(context, c, 'background'),
//                       ),
//                     ] else ...[
//                       Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.file(
//                               File(c.storeBackgroundImage!.path),
//                               height: 180,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   c.clearStoreBackground();
//                                   _backgroundDimensions = null;
//                                 });
//                               },
//                               child: const CircleAvatar(
//                                 radius: 14,
//                                 backgroundColor: Colors.red,
//                                 child: Icon(Icons.close, color: Colors.white, size: 16),
//                               ),
//                             ),
//                           ),
//                           if (_backgroundDimensions != null)
//                             Positioned(
//                               bottom: 8,
//                               left: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black54,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   '${_backgroundDimensions!['width']} x ${_backgroundDimensions!['height']} px',
//                                   style: const TextStyle(color: Colors.white, fontSize: 11),
//                                 ),
//                               ),
//                             ),
//                           if (_backgroundDimensions != null &&
//                               (_backgroundDimensions!['width'] != 1408 || _backgroundDimensions!['height'] != 768))
//                             Positioned(
//                               top: 8,
//                               left: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: const Text(
//                                   'Wrong Size! Must be 1408x768',
//                                   style: TextStyle(color: Colors.white, fontSize: 10),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//
//                     const SizedBox(height: 20),
//
//                     /// STORE LOGO
//                     sectionTitle("Store Logo *"),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       margin: const EdgeInsets.only(bottom: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue.shade200),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.info_outline, color: Colors.blue, size: 18),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Required size: ${_requiredDimensions['logo']!['description']}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.blue.shade700,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     if (c.storeProofImage == null) ...[
//                       uploadBox(
//                         title: "Tap to Upload Logo",
//                         subtitle: "200x200 to 500x500 pixels",
//                         icon: Icons.store,
//                         onTap: () => _pickImageWithValidation(context, c, 'logo'),
//                       ),
//                     ] else ...[
//                       Stack(
//                         children: [
//                           Container(
//                             height: 180,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.grey.shade300),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.file(
//                                 File(c.storeProofImage!.path),
//                                 height: 180,
//                                 width: double.infinity,
//                                 fit: BoxFit.contain,
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   c.clearStoreProof();
//                                   _logoDimensions = null;
//                                 });
//                               },
//                               child: const CircleAvatar(
//                                 radius: 14,
//                                 backgroundColor: Colors.red,
//                                 child: Icon(Icons.close, color: Colors.white, size: 16),
//                               ),
//                             ),
//                           ),
//                           if (_logoDimensions != null)
//                             Positioned(
//                               bottom: 8,
//                               left: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.black54,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   '${_logoDimensions!['width']} x ${_logoDimensions!['height']} px',
//                                   style: const TextStyle(color: Colors.white, fontSize: 11),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ],
//
//                     const SizedBox(height: 20),
//
//                     /// DESCRIPTION
//                     sectionTitle("Description"),
//                     textField(
//                       descCtrl,
//                       "Enter store description",
//                       maxLines: 3,
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     /// SUBMIT BUTTON
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         onPressed: c.submitting
//                             ? null
//                             : () async {
//                           if (!c.formKey.currentState!.validate()) return;
//
//                           // Validation
//                           if (_selectedCity == null) {
//                             Fluttertoast.showToast(msg: "Please select city");
//                             return;
//                           }
//                           //
//                           // if (_sellOffline) {
//                           //   if (_selectedAddress == null) {
//                           //     Fluttertoast.showToast(msg: "Please select address on map");
//                           //     return;
//                           //   }
//                           //   if (_selectedLat == null || _selectedLng == null) {
//                           //     Fluttertoast.showToast(msg: "Location coordinates missing");
//                           //     return;
//                           //   }
//                           // }
//
//                           if (c.storeBackgroundImage == null) {
//                             Fluttertoast.showToast(msg: "Background image required");
//                             return;
//                           }
//
//                           if (_backgroundDimensions != null) {
//                             if (_backgroundDimensions!['width'] != 1408 ||
//                                 _backgroundDimensions!['height'] != 768) {
//                               Fluttertoast.showToast(
//                                 msg: "Background image must be exactly 1408x768 pixels",
//                                 backgroundColor: Colors.red,
//                                 textColor: Colors.white,
//                               );
//                               return;
//                             }
//                           }
//
//                           if (c.storeProofImage == null) {
//                             Fluttertoast.showToast(msg: "Logo image required");
//                             return;
//                           }
//
//                           // Build address for API
//                           String fullAddress = '';
//                           if (_sellOffline) {
//                             fullAddress = _selectedAddress ?? '';
//                             if (landmarkCtrl.text.isNotEmpty) {
//                               fullAddress += ', ${landmarkCtrl.text}';
//                             }
//                           } else {
//                             fullAddress = _selectedCity ?? '';
//                           }
//
//                           await c.submitStore(
//                             name: nameCtrl.text,
//                             mobile: mobileCtrl.text,
//                             city: _selectedCity!,
//                             address: addressCtrl.text,
//                             description: descCtrl.text,
//                             latitude: _sellOffline ? _selectedLat.toString() : null,
//                             longitude: _sellOffline ? _selectedLng.toString() : null,
//                           );
//                         },
//                         child: c.submitting
//                             ? const CircularProgressIndicator(color: Colors.white)
//                             : const Text(
//                           "Create Store",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 50),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   /// COMPONENTS
//   Widget sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20, bottom: 8),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
//
//   Widget label(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10, bottom: 6),
//       child: Text(
//         text,
//         style: const TextStyle(fontWeight: FontWeight.w600),
//       ),
//     );
//   }
//
//   Widget textField(
//       TextEditingController controller,
//       String hint, {
//         int maxLines = 1,
//         TextInputType keyboard = TextInputType.text,
//       }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboard,
//       decoration: inputDecoration(hint),
//       validator: (v) => v == null || v.isEmpty ? "Required" : null,
//     );
//   }
//
//   InputDecoration inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10),
//         borderSide: BorderSide(color: Colors.grey.shade300),
//       ),
//     );
//   }
//
//   Widget uploadBox({
//     required String title,
//     String? subtitle,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         height: 120,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade300),
//           color: Colors.grey.shade50,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: Colors.grey.shade600),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey.shade800,
//               ),
//             ),
//             if (subtitle != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey.shade500,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../controller/add_store_controller.dart';
import '../../../screens/citys/CitySearchScreen.dart';

class AddStoreScreen extends StatefulWidget {
  const AddStoreScreen({super.key});

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final landmarkCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  // Variables
  String? _selectedCity;

  // Image dimension tracking
  Map<String, dynamic>? _logoDimensions;
  Map<String, dynamic>? _backgroundDimensions;

  // Required dimensions
  final Map<String, Map<String, dynamic>> _requiredDimensions = {
    'logo': {
      'minWidth': 200,
      'minHeight': 200,
      'maxWidth': 500,
      'maxHeight': 500,
      'description': '200x200 - 500x500 pixels',
    },
    'background': {
      'requiredWidth': 1408,
      'requiredHeight': 768,
      'description': '1408x768 pixels',
    },
  };

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    addressCtrl.dispose();
    landmarkCtrl.dispose();
    descCtrl.dispose();
    cityCtrl.dispose();
    super.dispose();
  }

  /// Get image dimensions
  Future<Map<String, dynamic>?> _getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);
      await Future.delayed(Duration.zero);
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to read image dimensions');
      return null;
    }
  }

  /// Logo validation
  bool _validateLogoDimensions(
      Map<String, dynamic> dimensions,
      Map<String, dynamic> requirements,
      ) {
    final width = dimensions['width'] as int;
    final height = dimensions['height'] as int;

    if (width < (requirements['minWidth'] as int) ||
        height < (requirements['minHeight'] as int)) {
      _showDimensionError(
          'Image too small',
          'Minimum size: ${requirements['minWidth']}x${requirements['minHeight']}px\n'
              'Your image: ${width}x${height}px'
      );
      return false;
    }

    if (width > (requirements['maxWidth'] as int) ||
        height > (requirements['maxHeight'] as int)) {
      _showDimensionError(
          'Image too large',
          'Maximum size: ${requirements['maxWidth']}x${requirements['maxHeight']}px\n'
              'Your image: ${width}x${height}px'
      );
      return false;
    }

    return true;
  }

  /// Background validation
  bool _validateBackgroundDimensions(
      Map<String, dynamic> dimensions,
      Map<String, dynamic> requirements,
      ) {
    final width = dimensions['width'] as int;
    final height = dimensions['height'] as int;

    final requiredWidth = requirements['requiredWidth'] as int;
    final requiredHeight = requirements['requiredHeight'] as int;

    if (width != requiredWidth || height != requiredHeight) {
      _showDimensionError(
          'Invalid Background Image',
          'Required size: ${requiredWidth}x${requiredHeight}px\n'
              'Your image: ${width}x${height}px\n\n'
              'Please upload an image with exact dimensions 1408x768 pixels.'
      );
      return false;
    }

    return true;
  }

  void _showDimensionError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Image picker with validation
  Future<void> _pickImageWithValidation(
      BuildContext context,
      AddStoreController c,
      String imageType,
      ) async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      final File file = File(pickedFile.path);
      final dimensions = await _getImageDimensions(file);
      if (dimensions == null) return;

      if (imageType == 'logo') {
        final isValid = _validateLogoDimensions(
          dimensions,
          _requiredDimensions['logo']!,
        );

        if (!isValid) return;

        setState(() {
          c.storeProofImage = pickedFile;
          _logoDimensions = dimensions;
        });

        c.notifyListeners();

        Fluttertoast.showToast(
          msg: 'Logo uploaded (${dimensions['width']}x${dimensions['height']})',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else if (imageType == 'background') {
        final isValid = _validateBackgroundDimensions(
          dimensions,
          _requiredDimensions['background']!,
        );

        if (!isValid) return;

        setState(() {
          c.storeBackgroundImage = pickedFile;
          _backgroundDimensions = dimensions;
        });

        c.notifyListeners();

        Fluttertoast.showToast(
          msg: 'Background uploaded (${dimensions['width']}x${dimensions['height']})',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Image Pick Error: $e");
      Fluttertoast.showToast(
        msg: "Failed to pick image",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  /// Open city selection
  Future<void> _selectCity() async {
    final city = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CitySearchScreen(),
      ),
    );

    if (city != null) {
      setState(() {
        _selectedCity = city.name;
        cityCtrl.text = city.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddStoreController(),
      child: Consumer<AddStoreController>(
        builder: (context, c, _) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: const Text("Create Store"),
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
            body: Form(
              key: c.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// STORE INFO
                    sectionTitle("Store Information"),
                    label("Store Name *"),
                    textField(nameCtrl, "Enter store name"),

                    label("Mobile Number *"),
                    textField(
                      mobileCtrl,
                      "Enter mobile number",
                      keyboard: TextInputType.phone,
                    ),

                    const SizedBox(height: 20),

                    /// DO YOU SELL OFFLINE? TOGGLE
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Do you sell offline?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Enable if you have a physical store location",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: c.sellOffline,
                            onChanged: (value) {
                              setState(() {
                                c.sellOffline = value;
                                if (!value) {
                                  // Clear address when switching to online only
                                  addressCtrl.clear();
                                }
                              });
                              c.notifyListeners();
                            },
                            activeColor: Colors.black,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// CITY SELECTION (Always shown)
                    label("City *"),
                    InkWell(
                      onTap: _selectCity,
                      child: InputDecorator(
                        decoration: inputDecoration("Select city").copyWith(
                          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ),
                        child: Text(
                          _selectedCity ?? "Select city",
                          style: TextStyle(
                            color: _selectedCity == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    /// ADDRESS FIELDS (Only shown if selling offline)
                    if (c.sellOffline) ...[
                      const SizedBox(height: 16),
                      label("Store Address *"),
                      textField(
                        addressCtrl,
                        "Enter complete store address",
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),
                      label("Landmark (Optional)"),
                      optionalTextField(landmarkCtrl, "Enter landmark (e.g., near city mall)"), // Use optionalTextField here
                    ],

                    const SizedBox(height: 8),

                    SwitchListTile(
                      title: const Text("Self Pickup"),
                      value: c.selfPickup,
                      onChanged: (v) {
                        c.selfPickup = v;
                        c.notifyListeners();
                      },
                    ),

                    SwitchListTile(
                      title: const Text("Delivery By Seller"),
                      value: c.deliveryBySeller,
                      onChanged: (v) {
                        c.deliveryBySeller = v;
                        c.notifyListeners();
                      },
                    ),

                    /// TIMING
                    sectionTitle("Store Timing"),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => c.pickTime(context, true),
                            child: Text(
                              c.openingTime == null
                                  ? "Opening Time"
                                  : c.openingTime!.format(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => c.pickTime(context, false),
                            child: Text(
                              c.closingTime == null
                                  ? "Closing Time"
                                  : c.closingTime!.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// BACKGROUND IMAGE
                    sectionTitle("Store Background Image *"),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Background Image Requirements:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Exact size required: ${_requiredDimensions['background']!['description']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '• Please ensure your image is exactly 1408x768 pixels',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (c.storeBackgroundImage == null) ...[
                      uploadBox(
                        title: "Tap to Upload Background Image",
                        subtitle: "Must be exactly 1408x768 pixels",
                        icon: Icons.image,
                        onTap: () => _pickImageWithValidation(context, c, 'background'),
                      ),
                    ] else ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(c.storeBackgroundImage!.path),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  c.clearStoreBackground();
                                  _backgroundDimensions = null;
                                });
                              },
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          if (_backgroundDimensions != null)
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_backgroundDimensions!['width']} x ${_backgroundDimensions!['height']} px',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ),
                          if (_backgroundDimensions != null &&
                              (_backgroundDimensions!['width'] != 1408 || _backgroundDimensions!['height'] != 768))
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Wrong Size! Must be 1408x768',
                                  style: TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    /// STORE LOGO
                    sectionTitle("Store Logo *"),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Required size: ${_requiredDimensions['logo']!['description']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (c.storeProofImage == null) ...[
                      uploadBox(
                        title: "Tap to Upload Logo",
                        subtitle: "200x200 to 500x500 pixels",
                        icon: Icons.store,
                        onTap: () => _pickImageWithValidation(context, c, 'logo'),
                      ),
                    ] else ...[
                      Stack(
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(c.storeProofImage!.path),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  c.clearStoreProof();
                                  _logoDimensions = null;
                                });
                              },
                              child: const CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          if (_logoDimensions != null)
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_logoDimensions!['width']} x ${_logoDimensions!['height']} px',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    /// DESCRIPTION
                    sectionTitle("Description"),
                    textField(
                      descCtrl,
                      "Enter store description",
                      maxLines: 3,
                    ),

                    const SizedBox(height: 30),

                    /// SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: c.submitting
                            ? null
                            : () async {
                          if (!c.formKey.currentState!.validate()) return;

                          // Validation
                          if (_selectedCity == null) {
                            Fluttertoast.showToast(msg: "Please select city");
                            return;
                          }

                          if (c.sellOffline) {
                            if (addressCtrl.text.trim().isEmpty) {
                              Fluttertoast.showToast(msg: "Please enter store address");
                              return;
                            }
                          }

                          if (c.storeBackgroundImage == null) {
                            Fluttertoast.showToast(msg: "Background image required");
                            return;
                          }

                          if (_backgroundDimensions != null) {
                            if (_backgroundDimensions!['width'] != 1408 ||
                                _backgroundDimensions!['height'] != 768) {
                              Fluttertoast.showToast(
                                msg: "Background image must be exactly 1408x768 pixels",
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              return;
                            }
                          }

                          if (c.storeProofImage == null) {
                            Fluttertoast.showToast(msg: "Logo image required");
                            return;
                          }

                          // Build full address
                          String fullAddress = '';
                          if (c.sellOffline) {
                            fullAddress = addressCtrl.text.trim();
                            if (landmarkCtrl.text.trim().isNotEmpty) {
                              fullAddress += ', ${landmarkCtrl.text.trim()}';
                            }
                          } else {
                            fullAddress = _selectedCity ?? '';
                          }

                          await c.submitStore(
                            name: nameCtrl.text,
                            mobile: mobileCtrl.text,
                            city: _selectedCity!,
                            address: fullAddress,
                            description: descCtrl.text,
                            latitude: null, // No location coordinates needed
                            longitude: null, // No location coordinates needed
                          );
                        },
                        child: c.submitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Create Store",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget optionalTextField(
      TextEditingController controller,
      String hint, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: inputDecoration(hint),
      // No validator - makes it optional
    );
  }

  /// COMPONENTS
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget textField(
      TextEditingController controller,
      String hint, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: inputDecoration(hint),
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget uploadBox({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}