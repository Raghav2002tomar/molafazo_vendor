import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_service.dart';
import '../../profile/screens/store_list_screen.dart';
import '../model/attribute_model.dart';
import '../model/category_model.dart';

class AddProductController extends ChangeNotifier {
  final formKeyBasic = GlobalKey<FormState>();
  final formKeyMedia = GlobalKey<FormState>();
  final picker = ImagePicker();
  List<StoreModel> stores = [];
  StoreModel? selectedStore;
  List<AttributeModel> attributes = [];
  Map<String, String?> selectedAttributes = {};
  bool loadingAttributes = false;

  bool loadingStores = false;
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  ChildCategory? selectedChildCategory;

  /// Lists
  List<Category> categories = [];
  List<SubCategory> subCategories = [];
  List<ChildCategory> childCategories = [];

  bool loadingCategory = false;
  bool loadingSubCategory = false;
  bool loadingChildCategory = false;

  /// Page 1: Basic Info
  String? category;
  String? subCategory;
  String? childCategory;
  String? brand;
  String? color;
  String? size;

  final approvedStores = ['Store A', 'Store B'];
  // final categories = ['Electronics', 'Fashion'];
  // final subCategories = ['Mobiles', 'Clothing'];
  // final childCategories = ['Smartphones', 'T-Shirts'];
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
  Future<void> fetchAttributes(int childCategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    loadingAttributes = true;
    attributes.clear();
    selectedAttributes.clear();
    notifyListeners();

    try {
      final res = await ApiService.get(
        endpoint: '/vendor/attributes/$childCategoryId',
        token: token,
      );

      attributes = (res['data'] as List)
          .map((e) => AttributeModel.fromJson(e))
          .toList();

      // 👇 initialize selection map (IMPORTANT)
      for (final attr in attributes) {
        selectedAttributes[attr.name] = null;
      }
    } catch (e) {
      debugPrint('Attribute error: $e');
    }

    loadingAttributes = false;
    notifyListeners(); // 🔥 REQUIRED
  }

  Future<void> fetchStores() async {
    loadingStores = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token == null) {
      loadingStores = false;
      notifyListeners();
      return;
    }

    final res = await ApiService.get(
      endpoint: '/vendor/store/list',
      token: token,
    );

    if (res['success'] == true) {
      stores = (res['data'] as List)
          .map((e) => StoreModel.fromJson(e))
          .toList();
    } else {
      stores = [];
    }

    loadingStores = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    loadingCategory = true;
    notifyListeners();

    final res = await ApiService.get(
      endpoint: "/vendor/categories",
      token: token,
    );

    if (res["success"]) {
      categories = (res["data"] as List)
          .map((e) => Category.fromJson(e))
          .toList();
    }

    loadingCategory = false;
    notifyListeners();
  }

  Future<void> fetchSubCategories(int categoryId, ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    loadingSubCategory = true;
    subCategories.clear();
    childCategories.clear();
    selectedSubCategory = null;
    selectedChildCategory = null;
    notifyListeners();

    final res = await ApiService.get(
      endpoint: "/vendor/subcategories/$categoryId",
      token: token,
    );

    if (res["success"]) {
      subCategories = (res["data"] as List)
          .map((e) => SubCategory.fromJson(e))
          .toList();
    }

    loadingSubCategory = false;
    notifyListeners();
  }

  Future<void> fetchChildCategories(int subCategoryId, ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    loadingChildCategory = true;
    childCategories.clear();
    selectedChildCategory = null;
    notifyListeners();

    final res = await ApiService.get(
      endpoint: "/vendor/child-categories/$subCategoryId",
      token: token,
    );

    if (res["success"]) {
      childCategories = (res["data"] as List)
          .map((e) => ChildCategory.fromJson(e))
          .toList();
    }

    loadingChildCategory = false;
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
  Future<ApiResult> submitProduct() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null) {
        return ApiResult(
          success: false,
          message: "Authentication token missing",
        );
      }

      final Map<String, String> fields = {
        "store_id": selectedStore!.id.toString(),
        "category_id": selectedCategory!.id.toString(),
        "sub_category_id": selectedSubCategory!.id.toString(),
        "name": nameController.text.trim(),
        "description": descController.text.trim(),
        "price": priceController.text.trim(),
        "discount_price": discountController.text.trim(),
        "available_quantity": qtyController.text.trim(),
        "delivery_available": "1",
        "delivery_price": "10",
        "delivery_time": "2-3 Days",
      };

      /// Tags
      for (final tag in tagsController.text.split(',')) {
        if (tag.trim().isNotEmpty) {
          fields["tags[]"] = tag.trim();
        }
      }

      /// Attributes
      selectedAttributes.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          fields["attributes_json[$key][]"] = value;
        }
      });

      /// Images
      final Map<String, File> files = {};
      for (int i = 0; i < productImages.length; i++) {
        files["images[$i]"] = File(productImages[i].path);
      }

      final response = await ApiService.multipart(
        endpoint: "/vendor/product/create",
        fields: fields,
        files: files,
        token: token,
      );

      if (response["success"] == true) {
        return ApiResult(
          success: true,
          message: response["message"] ?? "Product added successfully",
        );
      } else {
        return ApiResult(
          success: false,
          message: response["message"] ?? "Something went wrong",
        );
      }
    } catch (e) {
      return ApiResult(
        success: false,
        message: "Error: ${e.toString()}",
      );
    }
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
class ApiResult {
  final bool success;
  final String message;

  ApiResult({required this.success, required this.message});
}
