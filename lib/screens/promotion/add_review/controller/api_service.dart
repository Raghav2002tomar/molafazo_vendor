import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = "https://mudir.inbozor.app/api";
  static const String ImagebaseUrl = "https://mudir.inbozor.app";

  static Map<String, String> _headers({String? token}) {
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<dynamic> get({
    required String endpoint,
    String? token,
  }) async {
    try {
      final response = await http
          .get(
        Uri.parse(baseUrl + endpoint),
        headers: _headers(token: token),
      )
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        "success": data["status"] == true,
        "data": data["data"],
        "message": data["message"],
      };
    } else {
      return {
        "success": false,
        "message": data["message"] ?? "Something went wrong",
        "status": response.statusCode,
      };
    }
  }

  static dynamic _handleError(dynamic error) {
    return {
      "success": false,
      "message": error.toString().contains("Timeout")
          ? "Request timeout"
          : "No Internet / Server Error",
    };
  }

  // Add this method for submitting review
  static Future<Map<String, dynamic>> submitReview({
    required String token,
    required String promotionRequestId,
    required String title,
    required String review,
    required String rating,
    required String username,
    required List<File> images,
    required File profileImage,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/vendor/add-review'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['promotion_request_id'] = promotionRequestId;
      request.fields['title'] = title;
      request.fields['review'] = review;
      request.fields['rating'] = rating;
      request.fields['username'] = username;

      // Add multiple images
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          'images[]',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Add profile image
      final profileStream = http.ByteStream(profileImage.openRead());
      final profileLength = await profileImage.length();
      final profileMultipartFile = http.MultipartFile(
        'profile_image',
        profileStream,
        profileLength,
        filename: profileImage.path.split('/').last,
      );
      request.files.add(profileMultipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decoded = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": decoded['status'] ?? true,
          "message": decoded['message'] ?? "Review submitted successfully",
          "data": decoded['data'],
        };
      } else {
        return {
          "success": false,
          "message": decoded['message'] ?? "Failed to submit review",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: ${e.toString()}",
      };
    }
  }
}