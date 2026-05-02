import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../model/enquiry_model.dart';

class EnquiryApiService {
  Future<Map<String, dynamic>> createEnquiry({
    required String title,
    required String description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final res = await ApiService.postFormData(
      endpoint: "/enquiry/store",
      token: token,
      fields: {
        "title": title,
        "description": description,
      },
    );

    return Map<String, dynamic>.from(res);
  }

  Future<List<EnquiryModel>> fetchEnquiries() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    final res = await ApiService.get(
      endpoint: "/enquiry/list",
      token: token,
    );

    if (res["success"] == true && res["data"] is List) {
      return (res["data"] as List)
          .map((e) => EnquiryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }
}