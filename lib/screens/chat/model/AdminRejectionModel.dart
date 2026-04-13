// model/AdminRejectionModel.dart
class AdminRejectionModel {
  final String type;
  final int? notificationId;
  final int? storeId;
  final int? productId;
  final String? storeName;
  final String? productName;
  final String? storeImage;
  final String? productImage;
  final String message;
  final String? reason;
  final String createdAt;

  AdminRejectionModel({
    required this.type,
    this.notificationId,
    this.storeId,
    this.productId,
    this.storeName,
    this.productName,
    this.storeImage,
    this.productImage,
    required this.message,
    this.reason,
    required this.createdAt,
  });

  factory AdminRejectionModel.fromJson(Map<String, dynamic> json) {
    return AdminRejectionModel(
      type: json['type'] ?? '',
      notificationId: json['notification_id'],
      storeId: json['store_id'],
      productId: json['product_id'],
      storeName: json['store_name'],
      productName: json['product_name'],
      storeImage: json['store_image'],
      productImage: json['product_image'],
      message: json['message'] ?? '',
      reason: json['reason'],
      createdAt: json['created_at'] ?? '',
    );
  }

  String getFormattedDate() {
    try {
      final date = DateTime.parse(createdAt);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return '';
    }
  }

  String getFullDateTime() {
    try {
      final date = DateTime.parse(createdAt);
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }
}