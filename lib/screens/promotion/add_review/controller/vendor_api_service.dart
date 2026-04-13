import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../../../services/api_service.dart' hide ApiService;
import 'api_service.dart';

class VendorApiService {
  static Future<Map<String, dynamic>> getPackages({
    required String token,
    required String pID,
  }) async {
    try {
      final response = await ApiService.get(
        endpoint: '/vendor/packages?product_id=${pID}',
        token: token,
      );
      return response;
    } catch (e) {
      return {
        "success": false,
        "message": "Failed to fetch packages: ${e.toString()}",
      };
    }
  }

  static Future<Map<String, dynamic>> getPaymentDetails({
    required String token,
  }) async {
    try {
      final response = await ApiService.get(
        endpoint: '/vendor/payment-details',
        token: token,
      );
      return response;
    } catch (e) {
      return {
        "success": false,
        "message": "Failed to fetch payment details: ${e.toString()}",
      };
    }
  }

  static Future<Map<String, dynamic>> submitPromotionRequest({
    required String token,
    required String productId,
    required String packageId,
    required File screenshotImage,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/vendor/promotion-request'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['product_id'] = productId;
      request.fields['package_id'] = packageId;

      final stream = http.ByteStream(screenshotImage.openRead());
      final length = await screenshotImage.length();
      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: screenshotImage.path.split('/').last,
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decoded = jsonDecode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": decoded['status'] ?? true,
          "message": decoded['message'] ?? "Promotion request submitted successfully",
          "data": decoded['data'],
        };
      } else {
        return {
          "success": false,
          "message": decoded['message'] ?? "Failed to submit promotion request",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: ${e.toString()}",
      };
    }
  }

  static Future<Map<String, dynamic>> addReview({
    required String token,
    required String promotionRequestId,
    required String title,
    required String review,
    required String rating,
    required String username,
    List<File>? images,
    File? profileImage,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/vendor/add-review'),
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

      if (images != null && images.isNotEmpty) {
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
      }

      if (profileImage != null) {
        final stream = http.ByteStream(profileImage.openRead());
        final length = await profileImage.length();
        final multipartFile = http.MultipartFile(
          'profile_image',
          stream,
          length,
          filename: profileImage.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

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