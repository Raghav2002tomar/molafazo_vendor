// controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:molafzo_vendor/screens/addproduct/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../products/model/product_model.dart' as product_model;


// API Request Models
class ProductSubmitRequest {
  final int storeId;
  final int categoryId;
  final int subCategoryId;
  final int childCategoryId;
  final String name;
  final String shortDescription;
  final String description;
  final ProductPricing defaultPricing;
  final List<ProductVariant> variants;
  final List<ProductImage> images;
  final String? thumbnailImageId;

  ProductSubmitRequest({
    required this.storeId,
    required this.categoryId,
    required this.subCategoryId,
    required this.childCategoryId,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.defaultPricing,
    required this.variants,
    required this.images,
    this.thumbnailImageId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'store_id': storeId,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'child_category_id': childCategoryId,
      'name': name,
      'short_description': shortDescription,
      'description': description,
      'default_pricing': defaultPricing.toJson(),
      'images': images.map((img) => img.toJson()).toList(),
    };

    if (variants.isNotEmpty) {
      data['variants'] = variants.map((v) => v.toJson()).toList();
    }

    if (thumbnailImageId != null) {
      data['thumbnail_image_id'] = thumbnailImageId;
    }

    return data;
  }
}

class ProductPricing {
  final double price;
  final double? comparePrice;
  final double? discount;
  final int stock;

  ProductPricing({
    required this.price,
    this.comparePrice,
    this.discount,
    required this.stock,
  });

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      if (comparePrice != null && comparePrice! > 0) 'compare_price': comparePrice,
      if (discount != null && discount! > 0) 'discount': discount,
      'stock': stock,
    };
  }
}

class ProductImage {
  final String id;
  final String fileName;
  final int order;
  final bool isThumbnail;

  ProductImage({
    required this.id,
    required this.fileName,
    required this.order,
    this.isThumbnail = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'order': order,
      'is_thumbnail': isThumbnail,
    };
  }
}

class ProductVariant {
  final String id;
  final Map<String, VariantAttributeData> attributes;
  final ProductPricing pricing;
  final String? sku;
  final List<String> imageIds;

  ProductVariant({
    required this.id,
    required this.attributes,
    required this.pricing,
    this.sku,
    required this.imageIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributes': attributes.map((key, value) => MapEntry(key, value.toJson())),
      'pricing': pricing.toJson(),
      'image_ids': imageIds,
      if (sku != null && sku!.isNotEmpty) 'sku': sku,
    };
  }
}

class VariantAttributeData {
  final String value;
  final bool isCustom;
  final int? attributeId;
  final int? valueId;

  VariantAttributeData({
    required this.value,
    required this.isCustom,
    this.attributeId,
    this.valueId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'value': value,
      'is_custom': isCustom,
    };

    if (attributeId != null && !isCustom) {
      data['attribute_id'] = attributeId;
    }

    if (valueId != null && !isCustom) {
      data['value_id'] = valueId;
    }

    return data;
  }
}

class AddProductControllernew extends ChangeNotifier {
  // Form Keys
  final formKeyBasic = GlobalKey<FormState>();

  // Image Picker
  final picker = ImagePicker();

  // Store Selection
  List<StoreModel> stores = [];
  StoreModel? selectedStore;
  bool loadingStores = false;
  bool isLoading = false;

  // Category Selection
  Category? selectedCategory;
  SubCategory? selectedSubCategory;
  ChildCategory? selectedChildCategory;

  List<Category> categories = [];
  List<SubCategory> subCategories = [];
  List<ChildCategory> childCategories = [];

  bool loadingCategory = false;
  bool loadingSubCategory = false;
  bool loadingChildCategory = false;

  // Attributes/Variants
  List<AttributeModel> attributes = [];
  List<SelectedVariant> selectedVariants = [];
  bool loadingAttributes = false;

  // Variant Combinations
  List<VariantCombination> combinations = [];

  // Product Images
  final List<XFile> productImages = [];
  int? thumbnailIndex;
  bool isSubmitting = false;
  int? editingProductId;
  bool isEditMode = false;

  // Text Controllers - Basic Info
  final titleController = TextEditingController();
  final shortDescController = TextEditingController();
  final longDescController = TextEditingController();

  // Default Price Fields
  final defaultPriceController = TextEditingController();
  final defaultComparePriceController = TextEditingController();
  final defaultDiscountController = TextEditingController();
  final defaultStockController = TextEditingController();

  static const int MAX_IMAGES = 10;
  static const int MAX_IMAGE_SIZE_MB = 1;
  static const int MAX_IMAGE_SIZE_BYTES = MAX_IMAGE_SIZE_MB * 1024 * 1024;

  // Add this method to AddProductControllernew class
  Future<void> loadProductForCopy(Map<String, dynamic> product, {bool isCopyMode = true}) async {
    debugPrint('Loading product for copy: ${product['name']}');

    isLoading = true;
    isEditMode = true;
    editingProductId = null; // New product, no ID yet
    notifyListeners();

    try {
      // Set basic info
      titleController.text = product['name'] ?? '';
      shortDescController.text = product['description'] ?? '';
      longDescController.text = product['description'] ?? '';

      // Pricing
      defaultPriceController.text = product['price']?.toString() ?? '';
      if (product['discount_price'] != null &&
          double.parse(product['discount_price'].toString()) > 0) {
        defaultComparePriceController.text = product['discount_price'].toString();
      }
      defaultStockController.text = product['available_quantity']?.toString() ?? '';

      // Set the selected store from the product
      if (product['store_id'] != null) {
        selectedStore = StoreModel(
          id: product['store_id'],
          name: 'Store ${product['store_id']}',
        );
      }

      // Category selection
      if (product['category'] != null) {
        selectedCategory = Category(
          id: product['category']['id'],
          name: product['category']['name'],
        );
      }

      if (product['sub_category'] != null) {
        selectedSubCategory = SubCategory(
          id: product['sub_category']['id'],
          name: product['sub_category']['name'],
        );
      }

      if (product['child_category'] != null) {
        selectedChildCategory = ChildCategory(
          id: product['child_category']['id'],
          name: product['child_category']['name'],
        );
      }

      // Load images
      await _loadProductImagesForCopy(product);

      // Load attributes
      if (product['attributes_json'] != null &&
          (product['attributes_json'] as Map).isNotEmpty) {
        await _loadAttributesFromCopy(product['attributes_json']);
      }

      // Load combinations
      if (product['combinations'] != null &&
          (product['combinations'] as List).isNotEmpty) {
        await _loadCombinationsFromCopy(product['combinations']);
      }

      isLoading = false;
      notifyListeners();

      debugPrint('Product loaded successfully for copying');
    } catch (e, stackTrace) {
      debugPrint('Error loading product for copy: $e');
      debugPrint('Stack trace: $stackTrace');
      isLoading = false;
      notifyListeners();
    }
  }


// New method to load images for copy
  Future<void> _loadProductImagesForCopy(Map<String, dynamic> product) async {
    List<dynamic> imagesList;

    // Handle different image formats
    if (product['images'] != null && (product['images'] as List).isNotEmpty) {
      imagesList = product['images'] as List;
    } else if (product['primaryimage'] != null) {
      // If only primaryimage is available, create a single image list
      imagesList = [{'image': product['primaryimage'], 'is_primary': true}];
    } else {
      imagesList = [];
    }

    productImages.clear();
    debugPrint('Loading ${imagesList.length} images for copy');

    for (int i = 0; i < imagesList.length; i++) {
      final img = imagesList[i];
      final imageUrl = img is Map ? img['image'] : img.toString();
      final isPrimary = img is Map ? (img['is_primary'] == 1 || img['is_primary'] == true) : (i == 0);

      try {
        final fullImageUrl = "${ApiService.ImagebaseUrl}${ApiService.product_images_URL}$imageUrl";
        final response = await http.get(Uri.parse(fullImageUrl));

        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$imageUrl';
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);

          final xFile = XFile(file.path);
          productImages.add(xFile);

          if (isPrimary) {
            thumbnailIndex = productImages.length - 1;
          }

          debugPrint('Loaded image ${i + 1}/${imagesList.length}');
        }
      } catch (e) {
        debugPrint('Error loading image: $e');
      }
    }

    debugPrint('Loaded ${productImages.length} images successfully');
    notifyListeners();
  }


// Add this method to AddProductControllernew class
  Future<ApiResult> copyProduct(BuildContext context, int originalProductId) async {
    if (isSubmitting) {
      return ApiResult(success: false, message: "Please wait...");
    }

    try {
      isSubmitting = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null) {
        isSubmitting = false;
        notifyListeners();
        return ApiResult(success: false, message: "Authentication token missing");
      }

      final requestData = prepareSubmitData();
      if (requestData == null) {
        isSubmitting = false;
        notifyListeners();
        return ApiResult(success: false, message: "Please fill all required fields");
      }

      // Prepare form fields for API
      final Map<String, String> fields = {};

      // Required fields
      fields['store_id'] = requestData.storeId.toString();
      fields['name'] = requestData.name;
      fields['price'] = requestData.defaultPricing.price.toString();
      fields['available_quantity'] = requestData.defaultPricing.stock.toString();

      if (requestData.description.isNotEmpty) {
        fields['description'] = requestData.description;
      }
      if (requestData.defaultPricing.comparePrice != null && requestData.defaultPricing.comparePrice! > 0) {
        fields['discount_price'] = requestData.defaultPricing.comparePrice.toString();
      }

      // Prepare images
      final Map<String, File> files = {};

      for (int i = 0; i < productImages.length; i++) {
        final imageFile = File(productImages[i].path);
        if (await imageFile.exists()) {
          files['images[$i]'] = imageFile;
          final imageId = requestData.images[i].id;
          fields['images_meta[$i][id]'] = imageId;
        }
      }

      // Handle variants
      if (requestData.variants.isNotEmpty) {
        final Map<String, List<String>> attributesJson = {};

        for (var variant in requestData.variants) {
          variant.attributes.forEach((key, attr) {
            if (!attributesJson.containsKey(key)) {
              attributesJson[key] = [];
            }
            if (!attributesJson[key]!.contains(attr.value)) {
              attributesJson[key]!.add(attr.value);
            }
          });
        }

        attributesJson.forEach((key, values) {
          for (int i = 0; i < values.length; i++) {
            fields['attributes_json[$key][$i]'] = values[i];
          }
        });

        for (int comboIndex = 0; comboIndex < requestData.variants.length; comboIndex++) {
          final variant = requestData.variants[comboIndex];

          fields['combinations[$comboIndex][price]'] = variant.pricing.price.toString();
          fields['combinations[$comboIndex][stock]'] = variant.pricing.stock.toString();

          variant.attributes.forEach((key, attr) {
            fields['combinations[$comboIndex][combination][$key]'] = attr.value;
          });

          for (int imgIndex = 0; imgIndex < variant.imageIds.length; imgIndex++) {
            fields['combinations[$comboIndex][image_ids][$imgIndex]'] = variant.imageIds[imgIndex];
          }
        }
      }

      debugPrint('\n🚀 COPYING PRODUCT ==================');
      debugPrint('Endpoint: /vendor/product/copy/$originalProductId');
      debugPrint('Fields:');
      fields.forEach((key, value) {
        debugPrint('  $key: $value');
      });
      debugPrint('Files count: ${files.length}');

      // Make the copy API call with the original product ID
      final response = await ApiService.multipart(
        endpoint: "/vendor/product/copy/$originalProductId",
        fields: fields,
        files: files,
        token: token,
      );

      debugPrint('\n📥 API RESPONSE ==================');
      debugPrint('Response: $response');

      if (context.mounted) {
        if (response["status"] == true || response["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response["message"] ?? "Product copied successfully"),
              backgroundColor: Colors.green,
            ),
          );

          clearForm();
          isEditMode = false;
          editingProductId = null;

          if (context.mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/dashboard',
                      (route) => false,
                );
              }
            });
          }

          isSubmitting = false;
          notifyListeners();

          return ApiResult(
            success: true,
            message: response["message"] ?? "Product copied successfully",
            data: response["data"],
          );
        } else {
          String errorMessage = response["message"] ?? "Failed to copy product";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );

          isSubmitting = false;
          notifyListeners();

          return ApiResult(success: false, message: errorMessage);
        }
      }

      isSubmitting = false;
      notifyListeners();
      return ApiResult(success: false, message: "Something went wrong");
    } catch (e) {
      debugPrint('❌ Error copying product: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
      isSubmitting = false;
      notifyListeners();
      return ApiResult(success: false, message: "Error: ${e.toString()}");
    }
  }


  // Add this method to AddProductControllernew class
  Future<void> loadProductFromCopy(Map<String, dynamic> product) async {
    debugPrint('Loading product from copy: ${product['name']}');

    isLoading = true;
    isEditMode = true;
    editingProductId = product['id'];
    notifyListeners();

    try {
      // Set basic info
      titleController.text = product['name'] ?? '';
      shortDescController.text = product['description'] ?? '';
      longDescController.text = product['description'] ?? '';

      // Pricing
      defaultPriceController.text = product['price']?.toString() ?? '';
      if (product['discount_price'] != null &&
          double.parse(product['discount_price'].toString()) > 0) {
        defaultComparePriceController.text = product['discount_price'].toString();
      }
      defaultStockController.text = product['available_quantity']?.toString() ?? '';

      // Store - will be selected by user before copying
      // Category selection
      if (product['category'] != null) {
        selectedCategory = Category(
          id: product['category']['id'],
          name: product['category']['name'],
        );
      }

      if (product['sub_category'] != null) {
        selectedSubCategory = SubCategory(
          id: product['sub_category']['id'],
          name: product['sub_category']['name'],
        );
      }

      if (product['child_category'] != null) {
        selectedChildCategory = ChildCategory(
          id: product['child_category']['id'],
          name: product['child_category']['name'],
        );
      }

      // Load images
      await _loadProductImagesFromCopy(product);

      // Load attributes
      if (product['attributes_json'] != null &&
          (product['attributes_json'] as Map).isNotEmpty) {
        await _loadAttributesFromCopy(product['attributes_json']);
      }

      // Load combinations
      if (product['combinations'] != null &&
          (product['combinations'] as List).isNotEmpty) {
        await _loadCombinationsFromCopy(product['combinations']);
      }

      isLoading = false;
      notifyListeners();

      debugPrint('Product loaded successfully for editing');
    } catch (e, stackTrace) {
      debugPrint('Error loading product from copy: $e');
      debugPrint('Stack trace: $stackTrace');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProductImagesFromCopy(Map<String, dynamic> product) async {
    final imagesList = product['images'] as List;
    productImages.clear();
    debugPrint('Loading ${imagesList.length} images from copy');

    for (int i = 0; i < imagesList.length; i++) {
      final img = imagesList[i];
      final imageUrl = img['image'];
      final isPrimary = img['is_primary'] == 1;

      try {
        final fullImageUrl = "${ApiService.ImagebaseUrl}${ApiService.product_images_URL}$imageUrl";
        final response = await http.get(Uri.parse(fullImageUrl));

        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$imageUrl';
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);

          final xFile = XFile(file.path);
          productImages.add(xFile);

          if (isPrimary) {
            thumbnailIndex = productImages.length - 1;
          }

          debugPrint('Loaded image ${i + 1}/${imagesList.length}');
        }
      } catch (e) {
        debugPrint('Error loading image: $e');
      }
    }

    debugPrint('Loaded ${productImages.length} images successfully');
    notifyListeners();
  }

  Future<void> _loadAttributesFromCopy(Map<String, dynamic> attributesJson) async {
    selectedVariants.clear();

    attributesJson.forEach((attrName, values) {
      final valuesList = values as List;
      final variantValues = valuesList.map((v) {
        return VariantValue.preset(v.toString(), 0);
      }).toList();

      selectedVariants.add(SelectedVariant(
        attributeName: attrName,
        values: variantValues,
        isCustomAttribute: false,
      ));
    });

    debugPrint('Loaded ${selectedVariants.length} attributes');
    autoGenerateCombinations();
  }

  Future<void> _loadCombinationsFromCopy(List<dynamic> combos) async {
    combinations.clear();

    for (var combo in combos) {
      // Parse combination JSON string if needed
      Map<String, dynamic> variant;
      if (combo['combination'] is String) {
        variant = jsonDecode(combo['combination']);
      } else {
        variant = combo['combination'];
      }

      final variantMap = Map<String, String>.from(variant);

      // Parse images
      List<String> imagePaths = [];
      if (combo['images'] is String) {
        imagePaths = List<String>.from(jsonDecode(combo['images']));
      } else {
        imagePaths = List<String>.from(combo['images']);
      }

      // Find images for this combination
      final tempImages = <XFile>[];
      for (var imgPath in imagePaths) {
        final matchingImage = productImages.firstWhere(
              (img) => img.path.contains(imgPath),
          orElse: () => XFile(''),
        );
        if (matchingImage.path.isNotEmpty) {
          tempImages.add(matchingImage);
        }
      }

      combinations.add(VariantCombination(
        attributes: variantMap,
        price: double.parse(combo['price'].toString()),
        comparePrice: combo['price_before_discount'] != null
            ? double.parse(combo['price_before_discount'].toString())
            : 0,
        discount: 0,
        stock: combo['stock'],
        sku: combo['sku']?.toString() ?? '',
        images: tempImages,
      ));
    }

    debugPrint('Loaded ${combinations.length} combinations');
    notifyListeners();
  }

// In AddProductControllernew class
// This method already exists in your controller, but let's make sure it's correct
// In AddProductControllernew class
// In AddProductControllernew class
  Future<void> loadProductFromModel(product_model.ProductModel product) async {
    debugPrint('Loading product from model: ${product.name}');

    isLoading = true;
    isEditMode = true;
    editingProductId = product.id;
    notifyListeners();

    try {
      // Set basic info
      titleController.text = product.name;
      shortDescController.text = product.description;
      longDescController.text = product.description;

      // Pricing
      defaultPriceController.text = product.price.toString();
      if (product.discountPrice != null && product.discountPrice! > 0) {
        defaultComparePriceController.text = product.discountPrice.toString();
      }
      defaultStockController.text = product.availableQuantity.toString();

      // Set the store using storeId - fetch store name if available
      // Since we only have storeId, we need to get the store name from the stores list
      // But in edit/copy mode, we don't have the stores list in this controller
      // So we'll create a StoreModel with just the ID and a placeholder name
      // The actual name will be displayed from the product data if available
      selectedStore = StoreModel(
        id: product.storeId,
        name: 'Store ${product.storeId}', // Placeholder name
      );

      // Category selection
      selectedCategory = Category(
        id: product.category.id,
        name: product.category.name,
      );

      selectedSubCategory = SubCategory(
        id: product.subCategory.id,
        name: product.subCategory.name,
      );

      if (product.childCategory != null) {
        selectedChildCategory = ChildCategory(
          id: product.childCategory!.id,
          name: product.childCategory!.name,
        );
      }

      // Load images - download from URLs
      await _loadProductImagesFromModel(product.images);

      // Load attributes_json if exists
      if (product.attributesJson != null && product.attributesJson!.isNotEmpty) {
        await _loadAttributesFromModel(product.attributesJson!);
      }

      // Load combinations
      if (product.combinations != null && product.combinations!.isNotEmpty) {
        await _loadCombinationsFromModel(product.combinations!);
      }

      isLoading = false;
      notifyListeners();

      debugPrint('Product loaded successfully for editing');
    } catch (e, stackTrace) {
      debugPrint('Error loading product from model: $e');
      debugPrint('Stack trace: $stackTrace');
      isLoading = false;
      notifyListeners();
    }
  }
// Add this method to fetch store details
  Future<String> _fetchStoreName(int storeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      final response = await ApiService.get(
        endpoint: "/vendor/store/$storeId",
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data']['name'] ?? 'Store $storeId';
      }
      return 'Store $storeId';
    } catch (e) {
      debugPrint('Error fetching store name: $e');
      return 'Store $storeId';
    }
  }

// Then update loadProductFromModel to use this
//   Future<void> loadProductFromModel(product_model.ProductModel product) async {
//     debugPrint('Loading product from model: ${product.name}');
//
//     isLoading = true;
//     isEditMode = true;
//     editingProductId = product.id;
//     notifyListeners();
//
//     try {
//       // Set basic info
//       titleController.text = product.name;
//       shortDescController.text = product.description;
//       longDescController.text = product.description;
//
//       // Pricing
//       defaultPriceController.text = product.price.toString();
//       if (product.discountPrice != null && product.discountPrice! > 0) {
//         defaultComparePriceController.text = product.discountPrice.toString();
//       }
//       defaultStockController.text = product.availableQuantity.toString();
//
//       // Fetch store name
//       final storeName = await _fetchStoreName(product.storeId);
//       selectedStore = StoreModel(
//         id: product.storeId,
//         name: storeName,
//       );
//
//       // Category selection
//       selectedCategory = Category(
//         id: product.category.id,
//         name: product.category.name,
//       );
//
//       selectedSubCategory = SubCategory(
//         id: product.subCategory.id,
//         name: product.subCategory.name,
//       );
//
//       if (product.childCategory != null) {
//         selectedChildCategory = ChildCategory(
//           id: product.childCategory!.id,
//           name: product.childCategory!.name,
//         );
//       }
//
//       // Load images - download from URLs
//       await _loadProductImagesFromModel(product.images);
//
//       // Load attributes_json if exists
//       if (product.attributesJson != null && product.attributesJson!.isNotEmpty) {
//         await _loadAttributesFromModel(product.attributesJson!);
//       }
//
//       // Load combinations
//       if (product.combinations != null && product.combinations!.isNotEmpty) {
//         await _loadCombinationsFromModel(product.combinations!);
//       }
//
//       isLoading = false;
//       notifyListeners();
//
//       debugPrint('Product loaded successfully for editing');
//     } catch (e, stackTrace) {
//       debugPrint('Error loading product from model: $e');
//       debugPrint('Stack trace: $stackTrace');
//       isLoading = false;
//       notifyListeners();
//     }
//   }
  // Update the method signature for _loadProductImagesFromModel
  Future<void> _loadProductImagesFromModel(List<product_model.ProductImage> images) async {
    productImages.clear();
    debugPrint('Loading ${images.length} images from model');

    for (int i = 0; i < images.length; i++) {
      final img = images[i];
      final imageUrl = img.imageUrl;

      try {
        // Download image
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          // Save to temporary file
          final tempDir = await getTemporaryDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${img.id}.jpg';
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);

          // Create XFile from the downloaded file
          final xFile = XFile(file.path);
          productImages.add(xFile);

          if (img.isPrimary) {
            thumbnailIndex = productImages.length - 1;
          }

          debugPrint('Loaded image ${i + 1}/${images.length}');
        }
      } catch (e) {
        debugPrint('Error loading image: $e');
      }
    }

    debugPrint('Loaded ${productImages.length} images successfully');
    notifyListeners();
  }

// Update _loadCombinationsFromModel
  Future<void> _loadCombinationsFromModel(List<product_model.ProductCombination> combos) async {
    combinations.clear();

    for (var combo in combos) {
      // Convert variant map to Map<String, String>
      final variantMap = Map<String, String>.from(combo.variant);

      // Find images for this combination
      final tempImages = <XFile>[];
      for (var imgPath in combo.images) {
        // Find the matching image in productImages
        final matchingImage = productImages.firstWhere(
              (img) => img.path.contains(imgPath),
          orElse: () => XFile(''),
        );
        if (matchingImage.path.isNotEmpty) {
          tempImages.add(matchingImage);
        }
      }

      combinations.add(VariantCombination(
        attributes: variantMap,
        price: combo.price,
        comparePrice: combo.priceBeforeDiscount ?? 0,
        discount: 0,
        stock: combo.stock,
        sku: '',
        images: tempImages,
      ));
    }

    debugPrint('Loaded ${combinations.length} combinations');
    notifyListeners();
  }

  Future<void> _loadAttributesFromModel(Map<String, dynamic> attributesJson) async {
    selectedVariants.clear();

    attributesJson.forEach((attrName, values) {
      final valuesList = values as List;
      final variantValues = valuesList.map((v) {
        return VariantValue.preset(v.toString(), 0);
      }).toList();

      selectedVariants.add(SelectedVariant(
        attributeName: attrName,
        values: variantValues,
        isCustomAttribute: false,
      ));
    });

    debugPrint('Loaded ${selectedVariants.length} attributes');

    // Auto generate combinations based on selected variants
    autoGenerateCombinations();
  }

  Future<void> loadProductForEdit(int productId) async {
    debugPrint('🔵 Starting loadProductForEdit for product ID: $productId');
    isLoading = true;
    isEditMode = true;
    editingProductId = productId;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null) {
        debugPrint('❌ No token found');
        isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint('🔵 Fetching product data from API');
      final response = await ApiService.get(
        endpoint: "/vendor/product/$productId",
        token: token,
      );

      debugPrint('🔵 API Response: ${response.toString().substring(0, 500)}...');

      if (response["status"] == true || response["success"] == true) {
        final product = response["data"];
        debugPrint('🔵 Product data received: ${product['name']}');

        // Fetch categories
        debugPrint('🔵 Fetching categories');
        await fetchCategories();
        debugPrint('🔵 Categories fetched: ${categories.length}');

        // Set category IDs
        final categoryId = product['category']['id'];
        final subCategoryId = product['sub_category']['id'];
        final childCategoryId = product['child_category']['id'];

        debugPrint('🔵 Category IDs: $categoryId, $subCategoryId, $childCategoryId');

        // Find selected category
        selectedCategory = categories.firstWhere(
              (cat) => cat.id == categoryId,
          orElse: () => Category(id: categoryId, name: product['category']['name']),
        );
        debugPrint('🔵 Selected category: ${selectedCategory?.name}');

        // Fetch subcategories
        debugPrint('🔵 Fetching subcategories for category: $categoryId');
        await fetchSubCategories(categoryId);
        selectedSubCategory = subCategories.firstWhere(
              (sub) => sub.id == subCategoryId,
          orElse: () => SubCategory(id: subCategoryId, name: product['sub_category']['name']),
        );
        debugPrint('🔵 Selected subcategory: ${selectedSubCategory?.name}');

        // Fetch child categories
        debugPrint('🔵 Fetching child categories for subcategory: $subCategoryId');
        await fetchChildCategories(subCategoryId);
        selectedChildCategory = childCategories.firstWhere(
              (child) => child.id == childCategoryId,
          orElse: () => ChildCategory(id: childCategoryId, name: product['child_category']['name']),
        );
        debugPrint('🔵 Selected child category: ${selectedChildCategory?.name}');

        // Fetch attributes
        debugPrint('🔵 Fetching attributes for child category: $childCategoryId');
        await fetchAttributes(childCategoryId);
        debugPrint('🔵 Attributes fetched: ${attributes.length}');

        // Populate form data
        debugPrint('🔵 Populating form data');
        await _populateFormData(product);
        debugPrint('🔵 Form data populated');
        debugPrint('🔵 Title after population: ${titleController.text}');
        debugPrint('🔵 Price after population: ${defaultPriceController.text}');
        debugPrint('🔵 Images after population: ${productImages.length}');

        isLoading = false;
        notifyListeners();
        debugPrint('🔵 UI update triggered with notifyListeners');

        // Force another update after a short delay
        Future.delayed(const Duration(milliseconds: 200), () {
          notifyListeners();
          debugPrint('🔵 Second notifyListeners triggered');
        });
      } else {
        debugPrint('❌ API response failed: $response');
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading product: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _populateFormData(Map<String, dynamic> product) async {
    debugPrint('Populating form data with: $product');

    // Basic info
    titleController.text = product['name'] ?? '';
    shortDescController.text = product['short_description'] ?? '';
    longDescController.text = product['description'] ?? '';

    debugPrint('Title set to: ${titleController.text}');

    // Pricing
    defaultPriceController.text = product['price']?.toString() ?? '';
    if (product['discount_price'] != null && product['discount_price'] > 0) {
      defaultComparePriceController.text = product['discount_price'].toString();
    }
    defaultStockController.text = product['available_quantity']?.toString() ?? '';

    // Store (can't be edited)
    selectedStore = StoreModel(
      id: product['store_id'],
      name: 'Store ${product['store_id']}',
    );

    // Load images
    await _loadProductImages(product);

    // Load variants and combinations
    if (product['combinations'] != null && product['combinations'].isNotEmpty) {
      await _loadVariantsFromProduct(product);
    }

    // Force multiple notifications to ensure UI updates
    notifyListeners();

    // Add a small delay to ensure everything is processed
    await Future.delayed(const Duration(milliseconds: 100));

    // Notify again to ensure UI refreshes
    notifyListeners();

    debugPrint('Form population completed');
  }

  Future<void> _loadVariantsFromProduct(Map<String, dynamic> product) async {
    // Clear existing
    selectedVariants.clear();
    combinations.clear();

    // Get attributes_json
    final attributesJson = product['attributes_json'] as Map<String, dynamic>?;
    if (attributesJson != null) {
      // For each attribute, create SelectedVariant
      attributesJson.forEach((attrName, values) {
        final valuesList = values as List;
        final variantValues = valuesList.map((v) {
          final valueStr = v.toString();

          // Try to find if this value exists in attributes
          final existingAttr = attributes.firstWhere(
                (attr) => attr.name == attrName,
            orElse: () => AttributeModel(id: 0, name: attrName, values: []),
          );

          // Check if this value is in the predefined values
          final predefinedValue = existingAttr.values.firstWhere(
                (val) => val.value == valueStr,
            orElse: () => AttributeValue(id: 0, value: valueStr),
          );

          return VariantValue.preset(valueStr, predefinedValue.id);
        }).toList();

        selectedVariants.add(SelectedVariant(
          attributeName: attrName,
          values: variantValues,
          isCustomAttribute: false,
          attributeId: attributes.firstWhere(
                (attr) => attr.name == attrName,
            orElse: () => AttributeModel(id: 0, name: attrName, values: []),
          ).id,
        ));
      });
    }

    // Load combinations
    final combinationsList = product['combinations'] as List;
    for (var combo in combinationsList) {
      final variant = combo['variant'] as Map<String, dynamic>;
      final imagePaths = combo['images'] as List;

      // Find image XFiles that match these image paths
      final tempImages = <XFile>[];
      for (var imgPath in imagePaths) {
        // Find the corresponding XFile in productImages by checking file names
        final matchingImage = productImages.firstWhere(
              (img) => img.path.contains(imgPath),
          orElse: () => XFile(''),
        );
        if (matchingImage.path.isNotEmpty) {
          tempImages.add(matchingImage);
        }
      }

      combinations.add(VariantCombination(
        attributes: Map<String, String>.from(variant),
        price: double.parse(combo['price'].toString()),
        comparePrice: combo['price_before_discount'] != null
            ? double.parse(combo['price_before_discount'].toString())
            : 0,
        discount: 0,
        stock: combo['stock'],
        sku: combo['sku']?.toString() ?? '',
        images: tempImages,
      ));
    }

    notifyListeners();
  }

  // Method to load product images from URLs
  Future<void> _loadProductImages(Map<String, dynamic> product) async {
    final imagesList = product['images'] as List;
    productImages.clear(); // Clear only when we're loading new images

    debugPrint('Loading ${imagesList.length} images');

    for (var imgData in imagesList) {
      final imageUrl = imgData['image'];
      final isPrimary = imgData['is_primary'] ?? false;

      try {
        // Construct full image URL
        final fullImageUrl = "${ApiService.ImagebaseUrl}${ApiService.product_images_URL}$imageUrl";
        debugPrint('Loading image from: $fullImageUrl');

        // Download image
        final response = await http.get(Uri.parse(fullImageUrl));
        if (response.statusCode == 200) {
          // Save to temporary file
          final tempDir = await getTemporaryDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$imageUrl';
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);

          // Create XFile from the downloaded file
          final xFile = XFile(file.path);
          productImages.add(xFile);

          if (isPrimary) {
            thumbnailIndex = productImages.length - 1;
            debugPrint('Set thumbnail to index: $thumbnailIndex');
          }
        } else {
          debugPrint('Failed to load image: $imageUrl, status: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error loading image: $e');
      }
    }

    debugPrint('Loaded ${productImages.length} images successfully');
    notifyListeners();
  }

  // Method to update product
  Future<ApiResult> updateProduct(BuildContext context) async {
    if (isSubmitting) {
      return ApiResult(success: false, message: "Please wait...");
    }

    try {
      isSubmitting = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null) {
        isSubmitting = false;
        notifyListeners();
        return ApiResult(success: false, message: "Authentication token missing");
      }

      final requestData = prepareSubmitData();
      if (requestData == null) {
        isSubmitting = false;
        notifyListeners();
        return ApiResult(success: false, message: "Please fill all required fields");
      }

      // Prepare form fields for API
      final Map<String, String> fields = {};

      // Only include fields that can be edited
      fields['name'] = requestData.name;
      fields['price'] = requestData.defaultPricing.price.toString();
      fields['available_quantity'] = requestData.defaultPricing.stock.toString();

      if (requestData.description.isNotEmpty) {
        fields['description'] = requestData.description;
      }
      if (requestData.defaultPricing.comparePrice != null && requestData.defaultPricing.comparePrice! > 0) {
        fields['discount_price'] = requestData.defaultPricing.comparePrice.toString();
        fields['price_before_discount'] = requestData.defaultPricing.price.toString();
      }

      // Prepare images
      final Map<String, File> files = {};

      // Add new images (you'll need to track which are new vs existing)
      for (int i = 0; i < productImages.length; i++) {
        final imageFile = File(productImages[i].path);
        if (await imageFile.exists()) {
          files['images[$i]'] = imageFile;
          final imageId = requestData.images[i].id;
          fields['images_meta[$i][id]'] = imageId;
        }
      }

      // Handle variants
      if (requestData.variants.isNotEmpty) {
        final Map<String, List<String>> attributesJson = {};

        for (var variant in requestData.variants) {
          variant.attributes.forEach((key, attr) {
            if (!attributesJson.containsKey(key)) {
              attributesJson[key] = [];
            }
            if (!attributesJson[key]!.contains(attr.value)) {
              attributesJson[key]!.add(attr.value);
            }
          });
        }

        attributesJson.forEach((key, values) {
          for (int i = 0; i < values.length; i++) {
            fields['attributes_json[$key][$i]'] = values[i];
          }
        });

        for (int comboIndex = 0; comboIndex < requestData.variants.length; comboIndex++) {
          final variant = requestData.variants[comboIndex];

          fields['combinations[$comboIndex][price]'] = variant.pricing.price.toString();
          fields['combinations[$comboIndex][stock]'] = variant.pricing.stock.toString();

          variant.attributes.forEach((key, attr) {
            fields['combinations[$comboIndex][combination][$key]'] = attr.value;
          });

          for (int imgIndex = 0; imgIndex < variant.imageIds.length; imgIndex++) {
            fields['combinations[$comboIndex][image_ids][$imgIndex]'] = variant.imageIds[imgIndex];
          }
        }
      }

      debugPrint('\n🚀 UPDATING PRODUCT ==================');
      debugPrint('Endpoint: /vendor/product/edit/${editingProductId}');

      // Make the API call
      final response = await ApiService.multipart(
        endpoint: "/vendor/product/edit/${editingProductId}",
        fields: fields,
        files: files,
        token: token,
      );

      debugPrint('\n📥 API RESPONSE ==================');
      debugPrint('Response: $response');

      if (response["status"] == true || response["success"] == true) {
        clearForm();
        isEditMode = false;
        editingProductId = null;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response["message"] ?? "Product updated successfully"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        if (context.mounted) {
          Future.delayed(Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard',
                    (route) => false,
              );
            }
          });
        }

        isSubmitting = false;
        notifyListeners();

        return ApiResult(
          success: true,
          message: response["message"] ?? "Product updated successfully",
          data: response["data"],
        );
      } else {
        String errorMessage = response["message"] ?? "Something went wrong";

        if (response["errors"] != null) {
          final errors = response["errors"] as Map;
          errorMessage = errors.values.map((e) => e.toString()).join('\n');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

        isSubmitting = false;
        notifyListeners();

        return ApiResult(success: false, message: errorMessage);
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }

      isSubmitting = false;
      notifyListeners();

      return ApiResult(success: false, message: "Error: ${e.toString()}");
    }
  }

  // ==================== STORE METHODS ====================
  Future<void> fetchStores() async {
    loadingStores = true;
    notifyListeners();

    try {
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

      if (res['success'] == true || res['status'] == true) {
        if (res['data'] != null) {
          if (res['data'] is List) {
            stores = (res['data'] as List)
                .map((e) => StoreModel.fromJson(e))
                .toList();
          }
        } else if (res['stores'] != null) {
          stores = (res['stores'] as List)
              .map((e) => StoreModel.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching stores: $e');
      stores = [];
    }

    loadingStores = false;
    notifyListeners();
  }

  // ==================== CATEGORY METHODS ====================
  Future<void> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    loadingCategory = true;
    notifyListeners();

    try {
      final res = await ApiService.get(
        endpoint: "/vendor/categories",
        token: token,
      );

      if (res["success"] == true) {
        categories = (res["data"] as List)
            .map((e) => Category.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }

    loadingCategory = false;
    notifyListeners();
  }

  Future<void> fetchSubCategories(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    loadingSubCategory = true;
    subCategories.clear();
    childCategories.clear();
    selectedSubCategory = null;
    selectedChildCategory = null;
    notifyListeners();

    try {
      final res = await ApiService.get(
        endpoint: "/vendor/subcategories/$categoryId",
        token: token,
      );

      if (res["success"] == true || res["status"] == true) {
        if (res["data"] != null && res["data"] is List) {
          subCategories = (res["data"] as List)
              .map((e) => SubCategory.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
    }

    loadingSubCategory = false;
    notifyListeners();
  }

  Future<void> fetchChildCategories(int subCategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    loadingChildCategory = true;
    childCategories.clear();
    selectedChildCategory = null;
    notifyListeners();

    try {
      final res = await ApiService.get(
        endpoint: "/vendor/child-categories/$subCategoryId",
        token: token,
      );

      if (res["success"] == true || res["status"] == true) {
        if (res["data"] != null && res["data"] is List) {
          childCategories = (res["data"] as List)
              .map((e) => ChildCategory.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching child categories: $e');
    }

    loadingChildCategory = false;
    notifyListeners();
  }

  // ==================== ATTRIBUTE/VARIANT METHODS ====================
  Future<void> fetchAttributes(int childCategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');
    loadingAttributes = true;
    attributes.clear();
    selectedVariants.clear();
    combinations.clear();
    notifyListeners();

    try {
      final res = await ApiService.get(
        endpoint: '/vendor/attributes/$childCategoryId',
        token: token,
      );

      if (res["success"] == true || res["status"] == true) {
        if (res['data'] != null) {
          attributes = (res['data'] as List)
              .map((e) => AttributeModel.fromJson(e))
              .toList();

          for (final attr in attributes) {
            selectedVariants.add(SelectedVariant(
              attributeName: attr.name,
              values: [],
              isCustomAttribute: false,
              attributeId: attr.id,
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Attribute error: $e');
    }

    loadingAttributes = false;
    notifyListeners();
  }

  void toggleVariantValue(
      String attributeName,
      String value, {
        bool isCustom = false,
        int? attributeId,
        int? valueId,
      }) {
    final index = selectedVariants.indexWhere(
            (v) => v.attributeName == attributeName
    );

    final variantValue = isCustom
        ? VariantValue.custom(value)
        : VariantValue.preset(value, valueId ?? 0);

    if (index != -1) {
      final valueIndex = selectedVariants[index].values
          .indexWhere((v) => v.value == value);

      if (valueIndex != -1) {
        selectedVariants[index].values.removeAt(valueIndex);
      } else {
        selectedVariants[index].values.add(variantValue);
      }

      if (selectedVariants[index].values.isEmpty) {
        selectedVariants.removeAt(index);
      }

      autoGenerateCombinations();
      notifyListeners();
    } else {
      final attribute = attributes.firstWhere(
            (attr) => attr.name == attributeName,
        orElse: () => AttributeModel(id: 0, name: attributeName, values: []),
      );

      selectedVariants.add(SelectedVariant(
        attributeName: attributeName,
        values: [variantValue],
        isCustomAttribute: isCustom || attribute.id == 0,
        attributeId: attribute.id != 0 ? attribute.id : null,
      ));
      autoGenerateCombinations();
      notifyListeners();
    }
  }

  void removeVariant(String attributeName) {
    selectedVariants.removeWhere((v) => v.attributeName == attributeName);
    autoGenerateCombinations();
    notifyListeners();
  }

  void autoGenerateCombinations() {
    final activeVariants = selectedVariants
        .where((v) => v.values.isNotEmpty)
        .toList();

    if (activeVariants.isEmpty) {
      combinations.clear();
      notifyListeners();
      return;
    }

    List<Map<String, String>> combinationsList = [];

    void generate(List<SelectedVariant> variants, int index,
        Map<String, String> currentCombination) {
      if (index == variants.length) {
        combinationsList.add(Map.from(currentCombination));
        return;
      }

      final variant = variants[index];
      for (VariantValue variantValue in variant.values) {
        currentCombination[variant.attributeName] = variantValue.value;
        generate(variants, index + 1, currentCombination);
      }
    }

    generate(activeVariants, 0, {});

    combinations = combinationsList.map((combo) {
      return VariantCombination(
        attributes: combo,
        price: double.tryParse(defaultPriceController.text) ?? 0.0,
        comparePrice: double.tryParse(defaultComparePriceController.text) ?? 0.0,
        discount: double.tryParse(defaultDiscountController.text) ?? 0.0,
        stock: int.tryParse(defaultStockController.text) ?? 0,
        sku: '',
        // Set ALL images as default for each combination
        images: List.from(productImages), // This makes all images selected by default
      );
    }).toList();

    notifyListeners();
  }


  void updateCombination(int index, VariantCombination updatedCombo) {
    if (index >= 0 && index < combinations.length) {
      combinations[index] = updatedCombo;
      notifyListeners();
    }
  }

  void removeCombination(int index) {
    if (index >= 0 && index < combinations.length) {
      combinations.removeAt(index);
      notifyListeners();
    }
  }

  // ==================== IMAGE METHODS ====================
// First, add these imports at the top of your controller file if not already present

// Then update the pickProductImages method
  Future<void> pickProductImages() async {
    // Check if already at max limit
    if (productImages.length >= MAX_IMAGES) {
      _showErrorToast('Maximum $MAX_IMAGES images already added');
      return;
    }

    final images = await picker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;

    int remainingSlots = MAX_IMAGES - productImages.length;
    if (images.length > remainingSlots) {
      _showErrorToast('You can only add $remainingSlots more image${remainingSlots > 1 ? 's' : ''} (Maximum $MAX_IMAGES total)');
      return;
    }

    int successCount = 0;
    int failedCount = 0;

    for (final img in images) {
      // Check file size before compression
      final File originalFile = File(img.path);
      final int originalSize = await originalFile.length();
      final double originalSizeMB = originalSize / (1024 * 1024);

      debugPrint('Original image size: ${originalSizeMB.toStringAsFixed(2)} MB');

      if (originalSizeMB > MAX_IMAGE_SIZE_MB) {
        _showInfoToast('Compressing large image (${originalSizeMB.toStringAsFixed(1)}MB)...');
      }

      final compressed = await compressWithSizeLimit(img);

      if (compressed != null) {
        // Verify compressed file size
        final File compressedFile = File(compressed.path);
        final int compressedSize = await compressedFile.length();
        final double compressedSizeMB = compressedSize / (1024 * 1024);

        debugPrint('Compressed image size: ${compressedSizeMB.toStringAsFixed(2)} MB');

        if (compressedSizeMB <= MAX_IMAGE_SIZE_MB) {
          productImages.add(compressed);
          successCount++;
        } else {
          debugPrint('Failed to compress below ${MAX_IMAGE_SIZE_MB}MB');
          failedCount++;
        }
      } else {
        failedCount++;
      }
    }

    if (successCount > 0) {
      _showSuccessToast('$successCount image${successCount > 1 ? 's' : ''} added successfully');
    }

    if (failedCount > 0) {
      _showErrorToast('$failedCount image${failedCount > 1 ? 's' : ''} exceed ${MAX_IMAGE_SIZE_MB}MB limit');
    }

    notifyListeners();
  }

// Update pickCameraImage method
  Future<void> pickCameraImage() async {
    // Check if already at max limit
    if (productImages.length >= MAX_IMAGES) {
      _showErrorToast('Maximum $MAX_IMAGES images already added');
      return;
    }

    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (image == null) return;

    // Check file size
    final File originalFile = File(image.path);
    final int originalSize = await originalFile.length();
    final double originalSizeMB = originalSize / (1024 * 1024);

    debugPrint('Original camera image size: ${originalSizeMB.toStringAsFixed(2)} MB');

    if (originalSizeMB > MAX_IMAGE_SIZE_MB) {
      _showInfoToast('Compressing image...');
    }

    final compressed = await compressWithSizeLimit(image);

    if (compressed != null) {
      // Verify compressed file size
      final File compressedFile = File(compressed.path);
      final int compressedSize = await compressedFile.length();
      final double compressedSizeMB = compressedSize / (1024 * 1024);

      debugPrint('Compressed camera image size: ${compressedSizeMB.toStringAsFixed(2)} MB');

      if (compressedSizeMB <= MAX_IMAGE_SIZE_MB) {
        productImages.add(compressed);
        _showSuccessToast('Image added successfully');
      } else {
        _showErrorToast('Image exceeds ${MAX_IMAGE_SIZE_MB}MB limit even after compression');
      }
    } else {
      _showErrorToast('Failed to process image');
    }

    notifyListeners();
  }

// Update the toast helper methods
  void _showErrorToast(String message) {
    // Use Fluttertoast to show toast message
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _showInfoToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

// New compression method with size limit
  Future<XFile?> compressWithSizeLimit(XFile file) async {
    try {
      final dir = await getTemporaryDirectory();
      final target = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      int quality = 85;
      int width = 1200;
      int height = 1200;

      XFile? result;
      double currentSizeMB = double.infinity;
      int attempts = 0;
      const maxAttempts = 10;

      while (currentSizeMB > MAX_IMAGE_SIZE_MB && attempts < maxAttempts) {
        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.path,
          target,
          quality: quality,
          minWidth: width,
          minHeight: height,
          format: CompressFormat.jpeg,
        );

        if (compressed == null) {
          debugPrint('Compression failed at attempt ${attempts + 1}');
          return null;
        }

        result = XFile(compressed.path);
        final compressedFile = File(result.path);
        final compressedSize = await compressedFile.length();
        currentSizeMB = compressedSize / (1024 * 1024);

        debugPrint('Attempt ${attempts + 1}: Q=$quality, W=$width, Size=${currentSizeMB.toStringAsFixed(2)}MB');

        if (currentSizeMB <= MAX_IMAGE_SIZE_MB) {
          debugPrint('Successfully compressed to ${currentSizeMB.toStringAsFixed(2)}MB');
          return result;
        }

        // Adjust compression parameters for next attempt
        if (quality > 40) {
          quality -= 15;
        } else if (width > 600) {
          width -= 200;
          height -= 200;
        } else if (width > 400) {
          width -= 100;
          height -= 100;
        } else {
          debugPrint('Cannot compress further, giving up');
          break;
        }

        attempts++;

        // Small delay to prevent overwhelming the system
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // If we still have a result, check if it's within limit
      if (result != null) {
        final File resultFile = File(result!.path);
        final int finalSize = await resultFile.length();
        final double finalSizeMB = finalSize / (1024 * 1024);

        if (finalSizeMB <= MAX_IMAGE_SIZE_MB) {
          debugPrint('Final compressed size: ${finalSizeMB.toStringAsFixed(2)}MB');
          return result;
        } else {
          debugPrint('Final size still exceeds limit: ${finalSizeMB.toStringAsFixed(2)}MB');
          return null;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Compression error: $e');
      return null;
    }
  }


  Future<XFile?> compress(XFile file) async {
    try {
      final dir = await getTemporaryDirectory();
      final target = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        target,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      return result != null ? XFile(result.path) : null;
    } catch (e) {
      debugPrint('Compression error: $e');
      return null;
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < productImages.length) {
      if (thumbnailIndex == index) thumbnailIndex = null;
      if (thumbnailIndex != null && thumbnailIndex! > index) {
        thumbnailIndex = thumbnailIndex! - 1;
      }
      productImages.removeAt(index);
      notifyListeners();
    }
  }

  void setThumbnail(int index) {
    if (index >= 0 && index < productImages.length) {
      thumbnailIndex = index;
      notifyListeners();
    }
  }


  // ==================== DATA PREPARATION ====================
  ProductSubmitRequest? prepareSubmitData() {
    if (!validateAll()) return null;

    try {
      final defaultPricing = ProductPricing(
        price: double.parse(defaultPriceController.text),
        comparePrice: defaultComparePriceController.text.isNotEmpty
            ? double.parse(defaultComparePriceController.text)
            : null,
        discount: defaultDiscountController.text.isNotEmpty
            ? double.parse(defaultDiscountController.text)
            : null,
        stock: int.parse(defaultStockController.text),
      );

      final List<ProductImage> images = [];
      for (int i = 0; i < productImages.length; i++) {
        final image = productImages[i];
        final imageId = generateUniqueId('img');
        images.add(ProductImage(
          id: imageId,
          fileName: image.path.split('/').last,
          order: i,
          isThumbnail: thumbnailIndex == i,
        ));
      }

      final thumbnailImageId = thumbnailIndex != null
          ? images[thumbnailIndex!].id
          : images.isNotEmpty ? images.first.id : null;

      List<ProductVariant> variants = [];

      if (combinations.isNotEmpty) {
        for (var combo in combinations) {
          final imageIds = combo.images.map((img) {
            final index = productImages.indexOf(img);
            return index >= 0 ? images[index].id : null;
          }).where((id) => id != null).cast<String>().toList();

          final comboId = combo.attributes.values.join('-').toLowerCase()
              .replaceAll(' ', '-')
              .replaceAll(RegExp(r'[^a-z0-9-]'), '');

          final Map<String, VariantAttributeData> attributeMap = {};

          combo.attributes.forEach((key, value) {
            final variant = selectedVariants.firstWhere(
                  (v) => v.attributeName == key,
              orElse: () => SelectedVariant(
                attributeName: key,
                values: [],
                isCustomAttribute: false,
              ),
            );

            final valueObj = variant.values.firstWhere(
                  (v) => v.value == value,
              orElse: () => VariantValue.preset(value, 0),
            );

            final isAttributeCustom = variant.isCustomAttribute ||
                (variant.attributeId == null && !variant.values.any((v) => !v.isCustom));

            attributeMap[key] = VariantAttributeData(
              value: value,
              isCustom: valueObj.isCustom || isAttributeCustom,
              attributeId: isAttributeCustom ? null : variant.attributeId,
              valueId: valueObj.isCustom ? null : valueObj.valueId,
            );
          });

          variants.add(ProductVariant(
            id: comboId,
            attributes: attributeMap,
            pricing: ProductPricing(
              price: combo.price,
              comparePrice: combo.comparePrice > 0 ? combo.comparePrice : null,
              discount: combo.discount > 0 ? combo.discount : null,
              stock: combo.stock,
            ),
            sku: combo.sku.isNotEmpty ? combo.sku : null,
            imageIds: imageIds,
          ));
        }
      }

      return ProductSubmitRequest(
        storeId: selectedStore!.id,
        categoryId: selectedCategory!.id,
        subCategoryId: selectedSubCategory!.id,
        childCategoryId: selectedChildCategory!.id,
        name: titleController.text.trim(),
        shortDescription: shortDescController.text.trim(),
        description: longDescController.text.trim(),
        defaultPricing: defaultPricing,
        variants: variants,
        images: images,
        thumbnailImageId: thumbnailImageId,
      );
    } catch (e) {
      debugPrint('Error preparing data: $e');
      return null;
    }
  }

  bool validateAll() {
    if (productImages.isEmpty) return false;
    if (titleController.text.isEmpty) return false;
    if (selectedStore == null) return false;
    if (selectedChildCategory == null) return false;
    if (defaultPriceController.text.isEmpty) return false;
    if (defaultStockController.text.isEmpty) return false;
    return true;
  }




  Future<ApiResult> submitProduct(BuildContext context) async {
    // Prevent multiple submissions
    if (isSubmitting) {
      return ApiResult(success: false, message: "Please wait, product is being added...");
    }

    try {
      isSubmitting = true;
      notifyListeners(); // Update UI to show loading

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null) {
        isSubmitting = false;
        notifyListeners();
        return ApiResult(success: false, message: "Authentication token missing");
      }

      final requestData = prepareSubmitData();
      if (requestData == null) {
        isSubmitting = false;
        notifyListeners();
        return ApiResult(success: false, message: "Please fill all required fields");
      }

      // Prepare form fields for API
      final Map<String, String> fields = {};

      // Required fields
      fields['store_id'] = requestData.storeId.toString();
      fields['name'] = requestData.name;
      fields['price'] = requestData.defaultPricing.price.toString();
      fields['available_quantity'] = requestData.defaultPricing.stock.toString();

      // Optional fields
      if (requestData.categoryId > 0) {
        fields['category_id'] = requestData.categoryId.toString();
      }
      if (requestData.subCategoryId > 0) {
        fields['sub_category_id'] = requestData.subCategoryId.toString();
      }
      if (requestData.childCategoryId > 0) {
        fields['child_category_id'] = requestData.childCategoryId.toString();
      }
      if (requestData.shortDescription.isNotEmpty) {
        fields['short_description'] = requestData.shortDescription;
      }
      if (requestData.description.isNotEmpty) {
        fields['description'] = requestData.description;
      }
      if (requestData.defaultPricing.comparePrice != null && requestData.defaultPricing.comparePrice! > 0) {
        fields['discount_price'] = requestData.defaultPricing.comparePrice.toString();
        fields['price_before_discount'] = requestData.defaultPricing.price.toString();
      }
      if (requestData.defaultPricing.discount != null && requestData.defaultPricing.discount! > 0) {
        fields['discount'] = requestData.defaultPricing.discount.toString();
      }

      // Additional fields
      fields['delivery_available'] = "1";
      fields['delivery_price'] = "0";
      fields['delivery_time'] = "2-3 Days";
      fields['cost_price'] = requestData.defaultPricing.price.toString();

      // Prepare images - main product images
      final Map<String, File> files = {};

      // Add main product images and their metadata
      for (int i = 0; i < productImages.length; i++) {
        final imageFile = File(productImages[i].path);
        if (await imageFile.exists()) {
          files['images[$i]'] = imageFile;
          final imageId = requestData.images[i].id;
          fields['images_meta[$i][id]'] = imageId;
        }
      }

      // Handle variants and combinations
      if (requestData.variants.isNotEmpty) {
        // Build attributes_json (unique attributes and their values)
        final Map<String, List<String>> attributesJson = {};

        // Collect all unique attributes and their values from variants
        for (var variant in requestData.variants) {
          variant.attributes.forEach((key, attr) {
            if (!attributesJson.containsKey(key)) {
              attributesJson[key] = [];
            }
            if (!attributesJson[key]!.contains(attr.value)) {
              attributesJson[key]!.add(attr.value);
            }
          });
        }

        // Add attributes_json to fields (flattened format)
        attributesJson.forEach((key, values) {
          for (int i = 0; i < values.length; i++) {
            fields['attributes_json[$key][$i]'] = values[i];
          }
        });

        // Build combinations with image_ids (NO files in combinations)
        for (int comboIndex = 0; comboIndex < requestData.variants.length; comboIndex++) {
          final variant = requestData.variants[comboIndex];

          fields['combinations[$comboIndex][price]'] = variant.pricing.price.toString();
          fields['combinations[$comboIndex][stock]'] = variant.pricing.stock.toString();

          variant.attributes.forEach((key, attr) {
            fields['combinations[$comboIndex][combination][$key]'] = attr.value;
          });

          for (int imgIndex = 0; imgIndex < variant.imageIds.length; imgIndex++) {
            fields['combinations[$comboIndex][image_ids][$imgIndex]'] = variant.imageIds[imgIndex];
          }
        }
      }

      debugPrint('\n🚀 SENDING TO API ==================');
      debugPrint('Endpoint: /vendor/product/create');
      debugPrint('Fields:');
      fields.forEach((key, value) {
        debugPrint('  $key: $value');
      });
      debugPrint('Files count: ${files.length}');

      // Make the API call
      final response = await ApiService.multipart(
        endpoint: "/vendor/product/create",
        fields: fields,
        files: files,
        token: token,
      );

      debugPrint('\n📥 API RESPONSE ==================');
      debugPrint('Response: $response');

      // Handle response
      if (response["status"] == true || response["success"] == true) {
        // Clear form data first
        clearForm();

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response["message"] ?? "Product added successfully"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Navigate to dashboard after a short delay
        if (context.mounted) {
          Future.delayed(Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard',
                    (route) => false,
              );
            }
          });
        }

        isSubmitting = false;
        notifyListeners();

        return ApiResult(
          success: true,
          message: response["message"] ?? "Product added successfully",
          data: response["data"],
        );
      } else {
        String errorMessage = response["message"] ?? response["error"] ?? "Something went wrong";

        if (response["errors"] != null) {
          final errors = response["errors"] as Map;
          debugPrint('Validation Errors: $errors');
          errorMessage = errors.values.map((e) => e.toString()).join('\n');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }

        isSubmitting = false;
        notifyListeners();

        return ApiResult(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }

      isSubmitting = false;
      notifyListeners();

      return ApiResult(
          success: false,
          message: "Error: ${e.toString()}"
      );
    }
  }



// Add this method to clear form data after successful submission
  void clearForm() {
    // Clear text controllers
    titleController.clear();
    shortDescController.clear();
    longDescController.clear();
    defaultPriceController.clear();
    defaultComparePriceController.clear();
    defaultDiscountController.clear();
    defaultStockController.clear();

    // Clear images
    productImages.clear();
    thumbnailIndex = null;

    // Clear variants
    selectedVariants.clear();
    combinations.clear();
    attributes.clear();

    // Clear selections
    selectedStore = null;
    selectedCategory = null;
    selectedSubCategory = null;
    selectedChildCategory = null;

    // Notify listeners
    notifyListeners();
  }


  String generateUniqueId(String prefix) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecondsSinceEpoch % 9000)).toString().substring(0, 4)}';
  }

  void disposeAll() {
    titleController.dispose();
    shortDescController.dispose();
    longDescController.dispose();
    defaultPriceController.dispose();
    defaultComparePriceController.dispose();
    defaultDiscountController.dispose();
    defaultStockController.dispose();
  }
}