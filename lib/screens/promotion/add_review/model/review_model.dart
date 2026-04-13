class ReviewModel {
  final int promotionRequestId;
  final String title;
  final String review;
  final int rating;
  final String username;
  final List<String> images;
  final String profileImage;

  ReviewModel({
    required this.promotionRequestId,
    required this.title,
    required this.review,
    required this.rating,
    required this.username,
    required this.images,
    required this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'promotion_request_id': promotionRequestId,
      'title': title,
      'review': review,
      'rating': rating,
      'username': username,
      'images': images,
      'profile_image': profileImage,
    };
  }
}