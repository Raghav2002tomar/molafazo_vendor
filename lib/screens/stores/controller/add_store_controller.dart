import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class AddStoreController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final ImagePicker picker = ImagePicker();

  // Dropdown values
  String? storeType;
  String? idProofType;

  final storeTypes = ['Retail', 'Wholesale', 'Online'];
  final idProofTypes = ['Aadhaar', 'PAN', 'GST Certificate', 'Passport'];

  // Images
  final List<XFile> storeImages = [];
  XFile? storeProofImage;
  XFile? registrationCertImage;

  // ---------------- Image Compression ----------------

  Future<XFile?> compressImage(XFile file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressed = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 70,
    );

    return compressed != null ? XFile(compressed.path) : null;
  }

  // ---------------- Image Pickers ----------------

  Future<void> pickStoreImages() async {
    final images = await picker.pickMultiImage(imageQuality: 90);
    for (final img in images) {
      final compressed = await compressImage(img);
      if (compressed != null) {
        storeImages.add(compressed);
      }
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

  // ---------------- Submit ----------------

  void submitStore({
    required String name,
    required String mobile,
    required String email,
    required String address,
    required String description,
  }) {
    debugPrint('--------- STORE DATA ---------');
    debugPrint('Name: $name');
    debugPrint('Mobile: $mobile');
    debugPrint('Email: $email');
    debugPrint('Address: $address');
    debugPrint('Store Type: $storeType');
    debugPrint('Description: $description');
    debugPrint('Store Images: ${storeImages.length}');
    debugPrint('Store Proof: ${storeProofImage?.path}');
    debugPrint('Registration Cert: ${registrationCertImage?.path}');
    debugPrint('Status: Pending (Admin Approval)');
    debugPrint('--------------------------------');
  }
}
