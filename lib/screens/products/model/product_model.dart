class ProductModel {
  final int id;
  final int storeId;
  final String name;
  final double price;
  final double? discountPrice;
  final int stock;
  final String image;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      storeId: json['store_id'],
      name: json['name'],
      price: double.parse(json['price']),
      discountPrice: json['discount_price'] != null
          ? double.parse(json['discount_price'])
          : null,
      stock: json['available_quantity'],
      image: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]['image']
          : '',
    );
  }
}
