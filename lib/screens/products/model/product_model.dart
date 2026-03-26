
import '../../../services/api_service.dart';

class ProductModel {
  final int id;
  final int storeId;
  final String name;
  final double price;
  final double? discountPrice;
  final int availableQuantity;
  final bool deliveryAvailable;
  final double deliveryPrice;
  final String deliveryTime;
  final String description;
  final List<String> tags;
  final int statusId;
  final Map<String, dynamic>? attributesJson;
  final List<ProductImage> images;
  final List<Bank> banks;
  final List<ProductCombination>? combinations;
  final Category category;
  final SubCategory subCategory;
  final ChildCategory? childCategory;
  final String createdAt;
  final String updatedAt;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    this.discountPrice,
    required this.availableQuantity,
    required this.deliveryAvailable,
    required this.deliveryPrice,
    required this.deliveryTime,
    required this.description,
    required this.tags,
    required this.statusId,
    this.attributesJson,
    required this.images,
    required this.banks,
    this.combinations,
    required this.category,
    required this.subCategory,
    this.childCategory,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  String get primaryImage => images.firstWhere(
        (img) => img.isPrimary,
    orElse: () => images.first,
  ).imageUrl;

  double get finalPrice => discountPrice ?? price;

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  bool get inStock => availableQuantity > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse images
      List<ProductImage> images = [];
      if (json['images'] != null) {
        images = (json['images'] as List)
            .map((img) => ProductImage.fromJson(img))
            .toList();
      }

      // Parse banks
      List<Bank> banks = [];
      if (json['banks'] != null) {
        banks = (json['banks'] as List)
            .map((bank) => Bank.fromJson(bank))
            .toList();
      }

      // Parse combinations
      List<ProductCombination>? combinations;
      if (json['combinations'] != null && (json['combinations'] as List).isNotEmpty) {
        combinations = (json['combinations'] as List)
            .map((combo) => ProductCombination.fromJson(combo))
            .toList();
      }

      // Parse tags
      List<String> tags = [];
      if (json['tags'] != null) {
        if (json['tags'] is List) {
          tags = List<String>.from(json['tags']);
        } else if (json['tags'] is String) {
          tags = [json['tags']];
        }
      }

      return ProductModel(
        id: _parseId(json['id']),
        storeId: _parseId(json['store_id']),
        name: json['name']?.toString() ?? 'Unknown Product',
        price: _parseDouble(json['price']),
        discountPrice: json['discount_price'] != null
            ? _parseDouble(json['discount_price'])
            : null,
        availableQuantity: _parseInt(json['available_quantity']),
        deliveryAvailable: json['delivery_available'] == true,
        deliveryPrice: _parseDouble(json['delivery_price']),
        deliveryTime: json['delivery_time']?.toString() ?? 'N/A',
        description: json['description']?.toString() ?? '',
        tags: tags,
        statusId: _parseInt(json['status_id']),
        attributesJson: json['attributes_json'] as Map<String, dynamic>?,
        images: images,
        banks: banks,
        combinations: combinations,
        category: Category.fromJson(json['category']),
        subCategory: SubCategory.fromJson(json['sub_category']),
        childCategory: json['child_category'] != null
            ? ChildCategory.fromJson(json['child_category'])
            : null,
        createdAt: json['created_at']?.toString() ?? '',
        updatedAt: json['updated_at']?.toString() ?? '',
      );
    } catch (e) {
      print('❌ ProductModel parsing error: $e');
      print('❌ JSON: $json');
      rethrow;
    }
  }

  static int _parseId(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// Supporting Models
class ProductImage {
  final int id;
  final String image;
  final String? color;
  final bool isPrimary;

  ProductImage({
    required this.id,
    required this.image,
    this.color,
    required this.isPrimary,
  });

  String get imageUrl => "${ApiService.ImagebaseUrl}${ApiService.product_images_URL}$image";

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      image: json['image'],
      color: json['color'],
      isPrimary: json['is_primary'] ?? false,
    );
  }
}

class Bank {
  final int id;
  final int bankId;
  final String bankName;
  final String logo;
  final String accountHolderName;
  final String accountNumber;
  final String? ifscCode;
  final String? phoneNumber;

  Bank({
    required this.id,
    required this.bankId,
    required this.bankName,
    required this.logo,
    required this.accountHolderName,
    required this.accountNumber,
    this.ifscCode,
    this.phoneNumber,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      bankId: json['bank_id'],
      bankName: json['bank_name'],
      logo: json['logo'],
      accountHolderName: json['account_holder_name'],
      accountNumber: json['account_number'],
      ifscCode: json['ifsc_code'],
      phoneNumber: json['phone_number'],
    );
  }
}

class ProductCombination {
  final int id;
  final Map<String, dynamic> variant;
  final double price;
  final double? priceBeforeDiscount;
  final double? costPrice;
  final String? description;
  final int stock;
  final List<String> images;

  ProductCombination({
    required this.id,
    required this.variant,
    required this.price,
    this.priceBeforeDiscount,
    this.costPrice,
    this.description,
    required this.stock,
    required this.images,
  });

  factory ProductCombination.fromJson(Map<String, dynamic> json) {
    return ProductCombination(
      id: json['id'],
      variant: json['variant'] as Map<String, dynamic>,
      price: _parseDouble(json['price']),
      priceBeforeDiscount: json['price_before_discount'] != null
          ? _parseDouble(json['price_before_discount'])
          : null,
      costPrice: json['cost_price'] != null
          ? _parseDouble(json['cost_price'])
          : null,
      description: json['description'],
      stock: json['stock'],
      images: List<String>.from(json['images'] ?? []),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class SubCategory {
  final int id;
  final String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ChildCategory {
  final int id;
  final String name;

  ChildCategory({required this.id, required this.name});

  factory ChildCategory.fromJson(Map<String, dynamic> json) {
    return ChildCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}