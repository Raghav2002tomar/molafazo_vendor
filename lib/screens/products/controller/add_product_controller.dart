import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class AddProductController extends ChangeNotifier {
  final formKeyBasic = GlobalKey<FormState>();
  final formKeyMedia = GlobalKey<FormState>();
  final picker = ImagePicker();

  /// Page 1: Basic Info
  String? selectedStore;
  String? category;
  String? subCategory;
  String? childCategory;
  String? brand;
  String? color;
  String? size;

  final approvedStores = ['Store A', 'Store B'];
  final categories = ['Electronics', 'Fashion'];
  final subCategories = ['Mobiles', 'Clothing'];
  final childCategories = ['Smartphones', 'T-Shirts'];
  final brands = ['Brand X', 'Brand Y'];
  final colors = ['Red', 'Blue', 'Black'];
  final sizes = ['S', 'M', 'L', 'XL'];

  // Text Controllers
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final priceController = TextEditingController();
  final qtyController = TextEditingController();
  final discountController = TextEditingController();
  final descController = TextEditingController();
  final tagsController = TextEditingController();
  final weightController = TextEditingController();
  final dimensionsController = TextEditingController();
  final warrantyController = TextEditingController();
  final seoController = TextEditingController();

  /// Page 2: Media & Additional Info
  final List<XFile> productImages = [];
  int? thumbnailIndex;
  XFile? thumbnailImage;

  /// Pick thumbnail image
  Future<void> pickThumbnailImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final compressed = await compress(image);
    if (compressed != null) {
      thumbnailImage = compressed;
      notifyListeners();
    }
  }
  /// Pick Multiple Images with Compression
  Future<void> pickProductImages() async {
    final images = await picker.pickMultiImage(imageQuality: 90);
    if (images.isEmpty) return;

    for (final img in images) {
      final compressed = await compress(img);
      if (compressed != null) productImages.add(compressed);
    }
    notifyListeners();
  }

  /// Compress image
  Future<XFile?> compress(XFile file) async {
    final dir = await getTemporaryDirectory();
    final target =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      target,
      quality: 70,
    );

    return result != null ? XFile(result.path) : null;
  }

  void removeImage(int index) {
    if (thumbnailIndex == index) thumbnailIndex = null;
    if (thumbnailIndex != null && thumbnailIndex! > index) thumbnailIndex = thumbnailIndex! - 1;
    productImages.removeAt(index);
    notifyListeners();
  }

  void setThumbnail(int index) {
    thumbnailIndex = index;
    notifyListeners();
  }

  /// Submit: Print all data
  void submitProduct() {
    debugPrint('---------- PRODUCT DATA ----------');
    debugPrint('Store: $selectedStore');
    debugPrint('Category: $category > $subCategory > $childCategory');
    debugPrint('Brand: $brand');
    debugPrint('Color: $color');
    debugPrint('Size: $size');
    debugPrint('Name: ${nameController.text}');
    debugPrint('SKU: ${skuController.text}');
    debugPrint('Price: ${priceController.text}');
    debugPrint('Discount: ${discountController.text}');
    debugPrint('Quantity: ${qtyController.text}');
    debugPrint('Description: ${descController.text}');
    debugPrint('Tags: ${tagsController.text}');
    debugPrint('Weight: ${weightController.text}');
    debugPrint('Dimensions: ${dimensionsController.text}');
    debugPrint('Warranty: ${warrantyController.text}');
    debugPrint('SEO Meta: ${seoController.text}');
    debugPrint('Images Count: ${productImages.length}');
    if (thumbnailIndex != null) debugPrint('Thumbnail Image: ${productImages[thumbnailIndex!].path}');
    debugPrint('Status: Pending (Admin Approval)');
    debugPrint('----------------------------------');
    debugPrint(
        'Thumbnail Image: ${thumbnailImage?.path ?? "Not selected"}'
    );
  }

  void disposeAll() {
    nameController.dispose();
    skuController.dispose();
    priceController.dispose();
    qtyController.dispose();
    discountController.dispose();
    descController.dispose();
    tagsController.dispose();
    weightController.dispose();
    dimensionsController.dispose();
    warrantyController.dispose();
    seoController.dispose();
  }
}
