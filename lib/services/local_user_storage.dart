import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserStorage {
  static const _keyUser = 'local_user';

  /// ✅ SAVE FULL VENDOR PROFILE
  static Future<void> saveUser({
    required String phone,
    String? altPhone,
    required String firstName,
    required String lastName,
    required String email,

    // Govt ID
    String? govtIdType,
    String? govtIdNumber,

    // Address
    String? city,
    String? state,
    String? country,

    // Media paths (local)
    String? profileImage,
    String? idProof,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final userData = {
      'phone': phone,
      'alt_phone': altPhone,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,

      'govt_id_type': govtIdType,
      'govt_id_number': govtIdNumber,

      'address': {
        'city': city,
        'state': state,
        'country': country,
      },

      'profile_image': profileImage,
      'id_proof': idProof,

      'created_at': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_keyUser, jsonEncode(userData));
  }

  /// ✅ READ USER
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    return jsonDecode(raw);
  }

  /// ✅ CLEAR USER (LOGOUT)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }
}
