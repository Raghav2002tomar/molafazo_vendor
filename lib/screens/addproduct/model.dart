// attribute_model.dart
import 'package:flutter_image_compress/flutter_image_compress.dart';

// attribute_model.dart
class AttributeModel {
  final int id;
  final String name;
  final List<AttributeValue> values;

  AttributeModel({
    required this.id,
    required this.name,
    required this.values,
  });

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    // Handle different API response formats
    if (json['values'] != null && json['values'] is List) {
      final valuesList = json['values'] as List;

      // Check if values are objects with id or just strings
      if (valuesList.isNotEmpty && valuesList.first is Map) {
        // Values are objects with id
        return AttributeModel(
          id: json['id'] ?? 0,
          name: json['name'] ?? '',
          values: valuesList.map((v) => AttributeValue.fromJson(v)).toList(),
        );
      } else {
        // Values are simple strings
        return AttributeModel(
          id: json['id'] ?? 0,
          name: json['name'] ?? '',
          values: valuesList.map((v) => AttributeValue(id: 0, value: v.toString())).toList(),
        );
      }
    }

    return AttributeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      values: [],
    );
  }
}

class AttributeValue {
  final int id;
  final String value;

  AttributeValue({
    required this.id,
    required this.value,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      id: json['id'] ?? 0,
      value: json['value'] ?? json['name'] ?? '',
    );
  }
}
// category_model.dart
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class SubCategory {
  final int id;
  final String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ChildCategory {
  final int id;
  final String name;

  ChildCategory({required this.id, required this.name});

  factory ChildCategory.fromJson(Map<String, dynamic> json) {
    return ChildCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

// store_model.dart
// store_model.dart
class StoreModel {
  final int id;
  final String name;
  final String? address;

  StoreModel({required this.id, required this.name, this.address});

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
    );
  }
}

// variant_model.dart

class SelectedVariant {
  final String attributeName;
  List<VariantValue> values;
  final bool isCustomAttribute;
  final int? attributeId;

  SelectedVariant({
    required this.attributeName,
    required this.values,
    this.isCustomAttribute = false,
    this.attributeId,
  });

  List<String> get valueStrings => values.map((v) => v.value).toList();

  SelectedVariant copyWith({
    String? attributeName,
    List<VariantValue>? values,
    bool? isCustomAttribute,
    int? attributeId,
  }) {
    return SelectedVariant(
      attributeName: attributeName ?? this.attributeName,
      values: values ?? this.values,
      isCustomAttribute: isCustomAttribute ?? this.isCustomAttribute,
      attributeId: attributeId ?? this.attributeId,
    );
  }
}

class VariantValue {
  final String value;
  final bool isCustom;
  final int? valueId;

  VariantValue({
    required this.value,
    this.isCustom = false,
    this.valueId,
  });

  factory VariantValue.custom(String value) {
    return VariantValue(value: value, isCustom: true);
  }

  factory VariantValue.preset(String value, int id) {
    return VariantValue(value: value, isCustom: false, valueId: id);
  }

  VariantValue copyWith({
    String? value,
    bool? isCustom,
    int? valueId,
  }) {
    return VariantValue(
      value: value ?? this.value,
      isCustom: isCustom ?? this.isCustom,
      valueId: valueId ?? this.valueId,
    );
  }
}

class VariantCombination {
  String id;
  Map<String, String> attributes;
  double price;
  double comparePrice;
  double discount;
  int stock;
  String sku;
  List<XFile> images;

  VariantCombination({
    required this.attributes,
    required this.price,
    required this.comparePrice,
    required this.discount,
    required this.stock,
    required this.sku,
    required this.images,
  }) : id = _generateId(attributes);

  static String _generateId(Map<String, String> attrs) {
    return attrs.values.join('-').toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
  }

  String get displayName {
    return attributes.values.join(' - ');
  }

  VariantCombination copyWith({
    Map<String, String>? attributes,
    double? price,
    double? comparePrice,
    double? discount,
    int? stock,
    String? sku,
    List<XFile>? images,
  }) {
    return VariantCombination(
      attributes: attributes ?? this.attributes,
      price: price ?? this.price,
      comparePrice: comparePrice ?? this.comparePrice,
      discount: discount ?? this.discount,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      images: images ?? this.images,
    );
  }
}

class ApiResult {
  final bool success;
  final String message;
  final dynamic data;

  ApiResult({
    required this.success,
    required this.message,
    this.data,
  });
}