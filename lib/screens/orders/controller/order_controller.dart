import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:molafzo_vendor/services/api_service.dart';

import '../model/order_model.dart';

class OrderApiService {
  static const String baseUrl = "${ApiService.baseUrl}/vendor";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  Future<List<Order>> fetchOrders(int statusId) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/orders?status_id=$statusId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == true) {
      return (body['data'] as List)
          .map((e) => Order.fromJson(e))
          .toList();
    }

    if (body['status'] == false && body['data'] is List) {
      return [];
    }

    throw Exception(body['message'] ?? "Failed to load orders");
  }

  Future<void> updateOrderStatus(int orderId, int statusId) async {
    final token = await _getToken();

    await http.post(
      Uri.parse("$baseUrl/orders/$orderId/status"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"status_id": statusId}),
    );
  }
}
