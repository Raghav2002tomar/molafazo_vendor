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
  String? storeType;
  final storeTypes = ['Retail', 'Wholesale', 'Online'];

  // Images
  final List<XFile> storeImages = [];
  XFile? storeProofImage;
  XFile? registrationCertImage;

  bool submitting = false;

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
      Fluttertoast.showToast(msg: "Store proof image is required");
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

    // Prepare files for upload
    Map<String, File> files = {};
    if (storeProofImage != null) files['logi'] = File(storeProofImage!.path);
    if (registrationCertImage != null) files['registration_certificate'] = File(registrationCertImage!.path);
    // Optional: Upload multiple store images
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
        'type': storeType ?? '1',
        'delivery_by_seller': '1',
        'self_pickup': '0',
        'description': description,
        'working_hours': '9 AM - 6 PM',
      },
      files: files,
    );

    submitting = false;
    notifyListeners();

    if (res['success'] == true || res['status'] == true) {
      Fluttertoast.showToast(msg: "Store created successfully 🎉");
    } else {
      Fluttertoast.showToast(msg: res['message'] ?? "Failed to create store");
    }
  }
}
