class Order {
  final int id;
  final int statusId;
  final String totalAmount;
  final String createdAt;
  final String deliveryAddress;
  final String paymentType;
  final String deliveryMethod;
  final Customer customer;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.statusId,
    required this.totalAmount,
    required this.createdAt,
    required this.deliveryAddress,
    required this.paymentType,
    required this.deliveryMethod,
    required this.customer,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      statusId: json['status_id'],
      totalAmount: json['total_amount']?.toString() ?? '0',
      createdAt: json['created_at'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      paymentType: json['payment_type'] ?? '',
      deliveryMethod: json['delivery_method'] ?? '',
      customer: Customer.fromJson(json['customer']),
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }
}




class Customer {
  final int id;        // ✅ FIXED (int instead of String)
  final String name;
  final String mobile;
  final String image;

  Customer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.image,
  });

  factory Customer.fromJson(Map<String, dynamic>? json) {
    return Customer(
      id: json?['id'] ?? 0,  // ✅ no error now
      name: json?['name']?.toString() ?? 'Unknown',
      mobile: json?['mobile']?.toString() ?? '',
      image: json?['profile_photo']?.toString() ?? '',
    );
  }
}


class OrderItem {
  final int id;
  final int productId;
  final int quantity;
  final String price;
  final double total;
  final Map<String, dynamic>? variant; // Add this
  final OrderProduct product;

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.total,
    this.variant,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: json['price']?.toString() ?? '0',
      total: _parseDouble(json['total']),
      variant: json['variant'] != null ? Map<String, dynamic>.from(json['variant']) : null,
      product: OrderProduct.fromJson(json['product']),
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

class OrderProduct {
  final int id;
  final String name;
  final String price;
  final String discountPrice;
  final String primaryImage;

  OrderProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.primaryImage,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString() ?? '0',
      primaryImage: json['primary_image'] ?? '',
    );
  }
}

class Product {
  final int id;
  final String name;
  final String price;
  final String discountPrice;
  final String primaryImage;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.primaryImage,
  });

  factory Product.fromJson(Map<String, dynamic>? json) {
    return Product(
      id: json?['id'] ?? 0,
      name: json?['name'] ?? '',
      price: json?['price']?.toString() ?? '0',
      discountPrice: json?['discount_price']?.toString() ?? '0',
      primaryImage: json?['primary_image'] ?? '',
    );
  }
}
