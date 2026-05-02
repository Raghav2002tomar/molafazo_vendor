class EnquiryModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String description;
  final String? answer;
  final String? answeredAt;
  final String status;
  final String createdAt;
  final String updatedAt;

  EnquiryModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.answer,
    required this.answeredAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    return EnquiryModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      answer: json['answer']?.toString(),
      answeredAt: json['answered_at']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}