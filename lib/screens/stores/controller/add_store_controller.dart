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

  // Dropdown values


  // Images
  final List<XFile> storeImages = [];
  XFile? storeProofImage;
  XFile? registrationCertImage;

  bool submitting = false;
  String? storeType; // will store "1", "2", "3"

  final storeTypes = const [
    {'label': 'Retail', 'value': '1'},
    {'label': 'Online', 'value': '2'},
    {'label': 'Wholesale', 'value': '3'},
  ];
  bool selfPickup = false;
  bool deliveryBySeller = true;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  Future<void> pickTime(
      BuildContext context,
      bool isOpening,
      ) async {
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


  // ---------------- Image Compression ----------------
  Future<XFile?> compressImage(XFile file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
    );
    return compressed != null ? XFile(compressed.path) : null;
  }

  // ---------------- Pick Images ----------------
  Future<void> pickStoreImages() async {
    final images = await picker.pickMultiImage(imageQuality: 90);
    if (images.isEmpty) return;

    for (final img in images) {
      final compressed = await compressImage(img);
      if (compressed != null) storeImages.add(compressed);
    }
    notifyListeners();
  }

  Future<void> replaceStoreImage(int index) async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      final compressed = await compressImage(img);
      if (compressed != null) {
        storeImages[index] = compressed;
        notifyListeners();
      }
    }
  }

  Future<void> pickStoreProofImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      storeProofImage = await compressImage(img);
      notifyListeners();
    }
  }

  Future<void> pickRegistrationCertImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      registrationCertImage = await compressImage(img);
      notifyListeners();
    }
  }

  void removeStoreImage(int index) {
    storeImages.removeAt(index);
    notifyListeners();
  }

  void clearStoreProof() {
    storeProofImage = null;
    notifyListeners();
  }

  void clearRegistrationCert() {
    registrationCertImage = null;
    notifyListeners();
  }

  // ---------------- Submit Store ----------------
  Future<void> submitStore({
    required String name,
    required String mobile,
    required String email,
    required String city,
    required String address,
    required String description,
  }) async {
    if (storeProofImage == null) {
      Fluttertoast.showToast(msg: "Store logo is required");
      return;
    }

    if (registrationCertImage == null) {
      Fluttertoast.showToast(msg: "Government ID is required");
      return;
    }

    submitting = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token == null) {
      Fluttertoast.showToast(msg: "API token missing");
      submitting = false;
      notifyListeners();
      return;
    }

    /// FILES
    final Map<String, File> files = {};

    /// ✅ LOGO
    files['logo'] = File(storeProofImage!.path);

    /// ✅ GOVERNMENT ID (multiple)
    files['government_id[0]'] = File(registrationCertImage!.path);

    /// Optional store images
    for (int i = 0; i < storeImages.length; i++) {
      files['store_images[$i]'] = File(storeImages[i].path);
    }

    final res = await ApiService.multipart(
      endpoint: '/vendor/store/create',
      token: token,
      fields: {
        'name': name,
        'mobile': mobile,
        'email': email,
        'country': 'india',
        'city': city,
        'address': address,
        'type': storeType!,                // "1" / "2" / "3"
        'delivery_by_seller': deliveryBySeller ? '1' : '0',
        'self_pickup': selfPickup ? '1' : '0',
        'description': description,
        'working_hours': _workingHoursString(),
      },
      files: files,
    );

    submitting = false;
    notifyListeners();

    if (res['status'] == true || res['success'] == true) {
      Fluttertoast.showToast(msg: "Store created successfully 🎉");
      Navigator.of(formKey.currentContext!).pop(true);
    } else {
      Fluttertoast.showToast(
        msg: res['message'] ?? "Failed to create store",
      );
    }
  }

}
