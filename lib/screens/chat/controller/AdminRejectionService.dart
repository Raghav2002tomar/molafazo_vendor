// controller/AdminRejectionService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../model/AdminRejectionModel.dart';

class AdminRejectionService {

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  static Future<List<AdminRejectionModel>> getRejections() async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/vendor/rejections'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> rejections = data['data'];
          return rejections
              .map((json) => AdminRejectionModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching rejections: $e');
      return [];
    }
  }
}