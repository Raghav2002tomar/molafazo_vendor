import '../../../../services/api_service.dart';

class PaymentDetailsModel {
  final int id;
  final String accountName;
  final String accountNumber;
  final String ifsc;
  final String upiId;
  final String qrCode;
  final String createdAt;
  final String updatedAt;

  PaymentDetailsModel({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.ifsc,
    required this.upiId,
    required this.qrCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailsModel(
      id: json['id'],
      accountName: json['account_name']?? '',
      accountNumber: json['account_number']?? '',
      ifsc: json['ifsc']?? '',
      upiId: json['upi_id']?? '',
      qrCode: json['qr_code']?? '',
      createdAt: json['created_at']?? '',
      updatedAt: json['updated_at']?? '',
    );
  }

  String get fullQrCodeUrl => '${ApiService.ImagebaseUrl}/$qrCode';
}