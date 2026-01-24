class VendorProfileResponse {
  bool? status;
  String? message;
  VendorProfile? data;

  VendorProfileResponse({this.status, this.message, this.data});

  VendorProfileResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new VendorProfile.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class VendorProfile {
  int? id;
  String? role;
  int? statusId;
  String? name;
  String? email;
  String? mobile;
  String? altMobile;
  String? country;
  String? city;
  String? profilePhoto;
  String? govIdType;
  String? govIdNumber;
  List<String>? governmentIdDocuments;
  Null? approvedAt;
  int? emailVerified;
  Null? emailVerifiedAt;
  int? isMobileVerified;
  String? mobileVerifiedAt;
  int? termsAccepted;
  int? isSocial;
  String? deviceType;
  String? fcmToken;
  String? createdAt;
  String? updatedAt;

  VendorProfile(
      {this.id,
        this.role,
        this.statusId,
        this.name,
        this.email,
        this.mobile,
        this.altMobile,
        this.country,
        this.city,
        this.profilePhoto,
        this.govIdType,
        this.govIdNumber,
        this.governmentIdDocuments,
        this.approvedAt,
        this.emailVerified,
        this.emailVerifiedAt,
        this.isMobileVerified,
        this.mobileVerifiedAt,
        this.termsAccepted,
        this.isSocial,
        this.deviceType,
        this.fcmToken,
        this.createdAt,
        this.updatedAt});

  VendorProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    statusId = json['status_id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    altMobile = json['alt_mobile'];
    country = json['country'];
    city = json['city'];
    profilePhoto = json['profile_photo'];
    govIdType = json['gov_id_type'];
    govIdNumber = json['gov_id_number'];
    governmentIdDocuments = json['government_id_documents'].cast<String>();
    approvedAt = json['approved_at'];
    emailVerified = json['email_verified'];
    emailVerifiedAt = json['email_verified_at'];
    isMobileVerified = json['is_mobile_verified'];
    mobileVerifiedAt = json['mobile_verified_at'];
    termsAccepted = json['terms_accepted'];
    isSocial = json['is_social'];
    deviceType = json['device_type'];
    fcmToken = json['fcm_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    data['status_id'] = this.statusId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['alt_mobile'] = this.altMobile;
    data['country'] = this.country;
    data['city'] = this.city;
    data['profile_photo'] = this.profilePhoto;
    data['gov_id_type'] = this.govIdType;
    data['gov_id_number'] = this.govIdNumber;
    data['government_id_documents'] = this.governmentIdDocuments;
    data['approved_at'] = this.approvedAt;
    data['email_verified'] = this.emailVerified;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['is_mobile_verified'] = this.isMobileVerified;
    data['mobile_verified_at'] = this.mobileVerifiedAt;
    data['terms_accepted'] = this.termsAccepted;
    data['is_social'] = this.isSocial;
    data['device_type'] = this.deviceType;
    data['fcm_token'] = this.fcmToken;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}