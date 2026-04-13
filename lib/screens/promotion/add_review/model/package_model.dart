import 'package:flutter/material.dart';

class PackageModel {
  final int id;
  final String title;
  final int reviewCount;
  final int usedReviews;
  final int remainingReviews;
  final String price;
  final String? status; // 'approved', 'pending', or null
  final String? promotionRequestId;
  final bool isApplied;

  PackageModel({
    required this.id,
    required this.title,
    required this.reviewCount,
    required this.usedReviews,
    required this.remainingReviews,
    required this.price,
    this.status,
    this.promotionRequestId,
    required this.isApplied,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    // Handle promotion_request_id - convert from int to String if needed
    String? promotionRequestId;
    if (json['promotion_request_id'] != null) {
      promotionRequestId = json['promotion_request_id'].toString();
    }

    return PackageModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      reviewCount: json['review_count'] ?? 0,
      usedReviews: json['used_reviews'] ?? 0,
      remainingReviews: json['remaining_reviews'] ?? 0,
      price: json['price']?.toString() ?? '0',
      status: json['status'],
      promotionRequestId: promotionRequestId,
      isApplied: json['is_applied'] ?? false,
    );
  }

  // Helper getters for UI
  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isNotApplied => !isApplied;

  // Check if user can still add reviews
  bool get canAddReview => isApproved && isApplied && remainingReviews > 0;

  String get displayStatus {
    if (status == 'approved') return 'Approved';
    if (status == 'pending') return 'Pending Approval';
    return 'Not Applied';
  }

  Color get statusColor {
    if (status == 'approved') return Colors.green;
    if (status == 'pending') return Colors.orange;
    return Colors.grey;
  }

  IconData get statusIcon {
    if (status == 'approved') return Icons.check_circle;
    if (status == 'pending') return Icons.pending;
    return Icons.remove_circle_outline;
  }
}