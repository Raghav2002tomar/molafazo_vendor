//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../../../services/api_service.dart';
//
// class AddStoreController extends ChangeNotifier {
//
//   final formKey = GlobalKey<FormState>();
//   final ImagePicker picker = ImagePicker();
//
//   /// ---------------- Images ----------------
//   XFile? storeBackgroundImage;
//   XFile? storeProofImage;
//
//   /// ---------------- Store Info ----------------
//   bool submitting = false;
//   List<String> selectedStoreTypes = [];
//
//   final storeTypes = const [
//     {'label': 'Retail', 'value': '1'},
//     {'label': 'Online', 'value': '2'},
//     {'label': 'Wholesale', 'value': '3'},
//     {'label': 'Offline', 'value': '4'},
//   ];
//
//   bool selfPickup = false;
//   bool deliveryBySeller = true;
//
//   TimeOfDay? openingTime;
//   TimeOfDay? closingTime;
//
//   /// ---------------- Time Picker ----------------
//   Future<void> pickTime(BuildContext context, bool isOpening) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//
//     if (picked != null) {
//       if (isOpening) {
//         openingTime = picked;
//       } else {
//         closingTime = picked;
//       }
//       notifyListeners();
//     }
//   }
//
//   String _workingHoursString() {
//     if (openingTime == null || closingTime == null) return '';
//
//     return '${openingTime!.hour}:${openingTime!.minute.toString().padLeft(2, '0')}'
//         ' - '
//         '${closingTime!.hour}:${closingTime!.minute.toString().padLeft(2, '0')}';
//   }
//
//   /// ---------------- Image Compression ----------------
//   Future<XFile?> compressImage(File file) async {
//     try {
//       final dir = await getTemporaryDirectory();
//
//       int quality = 80;
//       int width = 1000;
//       int height = 1000;
//
//       File? compressedFile;
//
//       while (true) {
//         final targetPath =
//             "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
//
//         final result = await FlutterImageCompress.compressAndGetFile(
//           file.absolute.path,
//           targetPath,
//           quality: quality,
//           minWidth: width,
//           minHeight: height,
//           format: CompressFormat.jpeg,
//         );
//
//         if (result == null) return null;
//
//         compressedFile = File(result.path);
//
//         int size = await compressedFile.length();
//         double sizeMB = size / (1024 * 1024);
//
//         debugPrint(
//             "Compressed -> ${sizeMB.toStringAsFixed(2)}MB | Q:$quality | W:$width");
//
//         /// SUCCESS CONDITION
//         if (sizeMB <= 1) {
//           return XFile(compressedFile.path);
//         }
//
//         /// STEP 1 → reduce quality
//         if (quality > 30) {
//           quality -= 10;
//         }
//
//         /// STEP 2 → reduce resolution
//         else if (width > 400) {
//           width -= 200;
//           height -= 200;
//         }
//
//         /// FINAL FALLBACK
//         else {
//           return XFile(compressedFile.path);
//         }
//
//         file = compressedFile;
//       }
//     } catch (e) {
//       debugPrint("Compression Error: $e");
//       return null;
//     }
//   }
//
//
//
//   /// ---------------- Pick Background Image ----------------
//   Future<void> pickStoreBackgroundImage() async {
//
//     final img = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 50,
//       maxWidth: 800,
//       maxHeight: 800,
//     );
//
//     if (img == null) return;
//
//     File file = File(img.path);
//
//     final compressed = await compressImage(file);
//
//     if (compressed == null) return;
//
//     int size = await compressed.length();
//     double sizeMB = size / (1024 * 1024);
//
//     if (sizeMB > 1) {
//       Fluttertoast.showToast(msg: "Image must be less than 1MB");
//       return;
//     }
//
//     storeBackgroundImage = XFile(compressed.path);
//
//     notifyListeners();
//   }
//   void clearStoreBackground() {
//     storeBackgroundImage = null;
//     notifyListeners();
//   }
//
//   /// ---------------- Pick Logo ----------------
//   Future<void> pickStoreProofImage() async {
//
//     final img = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 40,
//       maxWidth: 500,
//       maxHeight: 500,
//     );
//
//     if (img == null) return;
//
//     File file = File(img.path);
//
//     final compressed = await compressImage(file);
//
//     if (compressed == null) return;
//
//     int size = await compressed.length();
//     double sizeMB = size / (1024 * 1024);
//
//     if (sizeMB > 1) {
//       Fluttertoast.showToast(msg: "Image must be less than 1MB");
//       return;
//     }
//
//     storeProofImage = XFile(compressed.path);
//
//     notifyListeners();
//   }
//
//   void clearStoreProof() {
//     storeProofImage = null;
//     notifyListeners();
//   }
//
//   /// ---------------- Submit Store ----------------
//   Future<void> submitStore({
//     required String name,
//     required String mobile,
//     required String city,
//     required String address,
//     required String description,
//     String? latitude,
//     String? longitude,
//   }) async {
//
//     /// ---------- FORM VALIDATION ----------
//     if (name.trim().isEmpty) {
//       Fluttertoast.showToast(msg: "Store name is required");
//       return;
//     }
//
//     if (mobile.trim().isEmpty || mobile.length != 10) {
//       Fluttertoast.showToast(msg: "Enter valid 10 digit mobile number");
//       return;
//     }
//
//
//
//     if (address.trim().isEmpty) {
//       Fluttertoast.showToast(msg: "Address is required");
//       return;
//     }
//
//     /// ---------- IMAGE VALIDATION ----------
//     if (storeBackgroundImage == null) {
//       Fluttertoast.showToast(msg: "Store background image is required");
//       return;
//     }
//
//     if (storeProofImage == null) {
//       Fluttertoast.showToast(msg: "Store logo is required");
//       return;
//     }
//
//     // /// ---------- STORE TYPE ----------
//     // if (selectedStoreTypes.isEmpty) {
//     //   Fluttertoast.showToast(msg: "Select at least one store type");
//     //   return;
//     // }
//
//     /// ---------- WORKING HOURS ----------
//     if (openingTime == null || closingTime == null) {
//       Fluttertoast.showToast(msg: "Please select store working hours");
//       return;
//     }
//
//     /// ---------- LOCATION ----------
//     if (latitude == null || longitude == null) {
//       Fluttertoast.showToast(msg: "Store location missing");
//       return;
//     }
//
//     submitting = true;
//     notifyListeners();
//
//     try {
//
//       /// ---------- TOKEN ----------
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('api_token');
//
//       if (token == null || token.isEmpty) {
//         Fluttertoast.showToast(msg: "Authentication failed. Login again.");
//         submitting = false;
//         notifyListeners();
//         return;
//       }
//
//       /// ---------- IMAGE SIZE CHECK ----------
//       int logoSize = await File(storeProofImage!.path).length();
//       int bgSize = await File(storeBackgroundImage!.path).length();
//
//       double logoMB = logoSize / (1024 * 1024);
//       double bgMB = bgSize / (1024 * 1024);
//
//       debugPrint("Logo Size: $logoMB MB");
//       debugPrint("Background Size: $bgMB MB");
//
//       if (logoMB > 1 || bgMB > 1) {
//         submitting = false;
//         notifyListeners();
//         Fluttertoast.showToast(msg: "Images must be less than 1MB");
//         return;
//       }
//
//       /// ---------- FILES ----------
//       final Map<String, File> files = {
//         'logo': File(storeProofImage!.path),
//         'store_background_image': File(storeBackgroundImage!.path),
//       };
//
//       /// ---------- FIELDS ----------
//       Map<String, String> fields = {
//         'name': name.trim(),
//         'mobile': mobile.trim(),
//         'country': 'india',
//         'city': city.trim(),
//         'address': address.trim(),
//         'delivery_by_seller': deliveryBySeller ? '1' : '0',
//         'self_pickup': selfPickup ? '1' : '0',
//         'description': description.trim(),
//         'working_hours': _workingHoursString(),
//         'latitude': latitude,
//         'longitude': longitude,
//       };
//
//       /// ---------- STORE TYPES ARRAY ----------
//       for (int i = 0; i < selectedStoreTypes.length; i++) {
//         fields['type[$i]'] = selectedStoreTypes[i];
//       }
//
//       debugPrint("FIELDS: $fields");
//
//       /// ---------- API REQUEST ----------
//       final res = await ApiService.multipart(
//         endpoint: '/vendor/store/create',
//         token: token,
//         fields: fields,
//         files: files,
//       );
//
//       submitting = false;
//       notifyListeners();
//
//       /// ---------- SUCCESS ----------
//       if (res != null &&
//           (res['status'] == true ||
//               res['success'] == true ||
//               res['message'] == "Store created successfully")) {
//
//         Fluttertoast.showToast(
//           msg: "Store created successfully 🎉",
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//         );
//
//         Navigator.of(formKey.currentContext!).pop(true);
//
//       } else {
//
//         Fluttertoast.showToast(
//           msg: res?['message'] ?? "Failed to create store",
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//         );
//       }
//
//     } catch (e) {
//
//       submitting = false;
//       notifyListeners();
//
//       debugPrint("Store create error: $e");
//
//       Fluttertoast.showToast(
//         msg: "Something went wrong. Try again",
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//     }
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../services/api_service.dart';

class AddStoreController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  /// ---------------- Images ----------------
  XFile? storeBackgroundImage;
  XFile? storeProofImage;

  /// ---------------- Store Info ----------------
  bool submitting = false;
  bool sellOffline = false; // Added this to track offline selling

  bool selfPickup = false;
  bool deliveryBySeller = true;

  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  /// ---------------- Time Picker ----------------
  Future<void> pickTime(BuildContext context, bool isOpening) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      if (isOpening) {
        openingTime = picked;
      } else {
        closingTime = picked;
      }
      notifyListeners();
    }
  }

  String _workingHoursString() {
    if (openingTime == null || closingTime == null) return '';

    return '${openingTime!.hour}:${openingTime!.minute.toString().padLeft(2, '0')}'
        ' - '
        '${closingTime!.hour}:${closingTime!.minute.toString().padLeft(2, '0')}';
  }

  /// Get store types based on sellOffline flag
  List<String> getStoreTypes() {
    if (sellOffline) {
      // Both Online and Offline
      return ['2', '4'];
    } else {
      // Only Online
      return ['2'];
    }
  }

  /// ---------------- Image Compression ----------------
  Future<XFile?> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();

      int quality = 80;
      int width = 1000;
      int height = 1000;

      File? compressedFile;

      while (true) {
        final targetPath =
            "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

        final result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: quality,
          minWidth: width,
          minHeight: height,
          format: CompressFormat.jpeg,
        );

        if (result == null) return null;

        compressedFile = File(result.path);

        int size = await compressedFile.length();
        double sizeMB = size / (1024 * 1024);

        debugPrint(
            "Compressed -> ${sizeMB.toStringAsFixed(2)}MB | Q:$quality | W:$width");

        if (sizeMB <= 1) {
          return XFile(compressedFile.path);
        }

        if (quality > 30) {
          quality -= 10;
        } else if (width > 400) {
          width -= 200;
          height -= 200;
        } else {
          return XFile(compressedFile.path);
        }

        file = compressedFile;
      }
    } catch (e) {
      debugPrint("Compression Error: $e");
      return null;
    }
  }

  /// ---------------- Pick Background Image ----------------
  Future<void> pickStoreBackgroundImage() async {
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (img == null) return;

    File file = File(img.path);
    final compressed = await compressImage(file);

    if (compressed == null) return;

    int size = await compressed.length();
    double sizeMB = size / (1024 * 1024);

    if (sizeMB > 1) {
      Fluttertoast.showToast(msg: "Image must be less than 1MB");
      return;
    }

    storeBackgroundImage = XFile(compressed.path);
    notifyListeners();
  }

  void clearStoreBackground() {
    storeBackgroundImage = null;
    notifyListeners();
  }

  /// ---------------- Pick Logo ----------------
  Future<void> pickStoreProofImage() async {
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
      maxWidth: 500,
      maxHeight: 500,
    );

    if (img == null) return;

    File file = File(img.path);
    final compressed = await compressImage(file);

    if (compressed == null) return;

    int size = await compressed.length();
    double sizeMB = size / (1024 * 1024);

    if (sizeMB > 1) {
      Fluttertoast.showToast(msg: "Image must be less than 1MB");
      return;
    }

    storeProofImage = XFile(compressed.path);
    notifyListeners();
  }

  void clearStoreProof() {
    storeProofImage = null;
    notifyListeners();
  }

  /// ---------------- Submit Store ----------------
  Future<void> submitStore({
    required String name,
    required String mobile,
    required String city,
    required String address,
    required String description,
    String? latitude,
    String? longitude,
  }) async {
    /// ---------- FORM VALIDATION ----------
    if (name.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Store name is required");
      return;
    }

    if (mobile.trim().isEmpty || mobile.length != 10) {
      Fluttertoast.showToast(msg: "Enter valid 10 digit mobile number");
      return;
    }

    if (city.trim().isEmpty) {
      Fluttertoast.showToast(msg: "City is required");
      return;
    }

    // if (address.trim().isEmpty) {
    //   Fluttertoast.showToast(msg: "Address is required");
    //   return;
    // }

    /// ---------- IMAGE VALIDATION ----------
    if (storeBackgroundImage == null) {
      Fluttertoast.showToast(msg: "Store background image is required");
      return;
    }

    if (storeProofImage == null) {
      Fluttertoast.showToast(msg: "Store logo is required");
      return;
    }

    /// ---------- WORKING HOURS ----------
    if (openingTime == null || closingTime == null) {
      Fluttertoast.showToast(msg: "Please select store working hours");
      return;
    }

    /// ---------- LOCATION ----------
    // For offline stores, location is required
    // if (sellOffline && (latitude == null || longitude == null)) {
    //   Fluttertoast.showToast(msg: "Store location missing for offline store");
    //   return;
    // }

    submitting = true;
    notifyListeners();

    try {
      /// ---------- TOKEN ----------
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null || token.isEmpty) {
        Fluttertoast.showToast(msg: "Authentication failed. Login again.");
        submitting = false;
        notifyListeners();
        return;
      }

      /// ---------- IMAGE SIZE CHECK ----------
      int logoSize = await File(storeProofImage!.path).length();
      int bgSize = await File(storeBackgroundImage!.path).length();

      double logoMB = logoSize / (1024 * 1024);
      double bgMB = bgSize / (1024 * 1024);

      debugPrint("Logo Size: $logoMB MB");
      debugPrint("Background Size: $bgMB MB");

      if (logoMB > 1 || bgMB > 1) {
        submitting = false;
        notifyListeners();
        Fluttertoast.showToast(msg: "Images must be less than 1MB");
        return;
      }

      /// ---------- FILES ----------
      final Map<String, File> files = {
        'logo': File(storeProofImage!.path),
        'store_background_image': File(storeBackgroundImage!.path),
      };

      /// ---------- FIELDS ----------
      Map<String, String> fields = {
        'name': name.trim(),
        'mobile': mobile.trim(),
        'country': 'india',
        'city': city.trim(),
        'address': address.trim(),
        'delivery_by_seller': deliveryBySeller ? '1' : '0',
        'self_pickup': selfPickup ? '1' : '0',
        'description': description.trim(),
        'working_hours': _workingHoursString(),
      };

      // Add location only for offline stores
      if (sellOffline && latitude != null && longitude != null) {
        fields['latitude'] = latitude;
        fields['longitude'] = longitude;
      }

      /// ---------- STORE TYPES (AUTO GENERATED) ----------
      final storeTypes = getStoreTypes();
      for (int i = 0; i < storeTypes.length; i++) {
        fields['type[$i]'] = storeTypes[i];
      }

      debugPrint("STORE TYPES: $storeTypes");
      debugPrint("FIELDS: $fields");

      /// ---------- API REQUEST ----------
      final res = await ApiService.multipart(
        endpoint: '/vendor/store/create',
        token: token,
        fields: fields,
        files: files,
      );

      submitting = false;
      notifyListeners();

      /// ---------- SUCCESS ----------
      if (res != null &&
          (res['status'] == true ||
              res['success'] == true ||
              res['message'] == "Store created successfully")) {
        Fluttertoast.showToast(
          msg: "Store created successfully 🎉",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.of(formKey.currentContext!).pop(true);
      } else {
        Fluttertoast.showToast(
          msg: res?['message'] ?? "Failed to create store",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      submitting = false;
      notifyListeners();

      debugPrint("Store create error: $e");

      Fluttertoast.showToast(
        msg: "Something went wrong. Try again",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}