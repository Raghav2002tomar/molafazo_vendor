// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:didit_sdk/sdk_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:molafzo_vendor/services/api_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class VerificationScreen extends StatefulWidget {
//   @override
//   _VerificationScreenState createState() => _VerificationScreenState();
// }
//
// class _VerificationScreenState extends State<VerificationScreen> {
//   bool _isLoading = false;
//   String _status = '';
//
//   Future<void> _verifyIdentity() async {
//     setState(() => _isLoading = true);
//
//     try {
//       final token = await _fetchSessionToken();
//
//       final result = await DiditSdk.startVerification(
//         token,
//         config: DiditConfig(loggingEnabled: true),
//       );
//
//       switch (result) {
//         case VerificationCompleted(:final session):
//           _status = 'Verification ${session.status.name}';
//
//           // ✅ RETURN TRUE
//           Navigator.pop(context, true);
//           break;
//
//         case VerificationCancelled():
//           _status = 'Verification cancelled';
//
//           // ❌ RETURN FALSE
//           Navigator.pop(context, false);
//           break;
//
//         case VerificationFailed(:final error):
//           _status = 'Error: ${error.message}';
//
//           // ❌ RETURN FALSE
//           Navigator.pop(context, false);
//           break;
//       }
//     } catch (e) {
//       Navigator.pop(context, false);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Run after UI loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _verifyIdentity();
//     });
//   }
//
//
//   Future<String> _fetchSessionToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('api_token');
//
//     if (token == null || token.isEmpty) {
//       Fluttertoast.showToast(msg: "Authentication failed. Login again.");
//       // return;
//     }
//     final response = await http.post(
//       Uri.parse('${ApiService.baseUrl}/kyc/create-session'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//
//       if (data['status'] == true) {
//         return data['sdk_token']; // ✅ IMPORTANT
//       } else {
//         throw Exception('Failed to create session');
//       }
//     } else {
//       throw Exception('API Error: ${response.statusCode}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Identity Verification')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(_status),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _verifyIdentity,
//               child: Text(_isLoading ? 'Loading...' : 'Verify Identity'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:didit_sdk/sdk_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:molafzo_vendor/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = false;
  String _status = '';

  Future<void> _verifyIdentity() async {
    setState(() => _isLoading = true);

    try {
      final token = await _fetchSessionToken();

      final result = await DiditSdk.startVerification(
        token,
        config: DiditConfig(loggingEnabled: true),
      );

      switch (result) {
        case VerificationCompleted(:final session):
          _status = 'Verification ${session.status.name}';
          // ✅ RETURN TRUE - Document verified successfully
          if (mounted) {
            Navigator.pop(context, true);
          }
          break;

        case VerificationCancelled():
          _status = 'Verification cancelled';
          // ❌ RETURN FALSE
          if (mounted) {
            Navigator.pop(context, false);
          }
          break;

        case VerificationFailed(:final error):
          _status = 'Error: ${error.message}';
          // ❌ RETURN FALSE
          if (mounted) {
            Navigator.pop(context, false);
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, false);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Run after UI loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyIdentity();
    });
  }

  Future<String> _fetchSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token == null || token.isEmpty) {
      Fluttertoast.showToast(msg: "Authentication failed. Login again.");
      throw Exception('Authentication failed');
    }

    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/kyc/create-session'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        return data['sdk_token']; // ✅ IMPORTANT
      } else {
        throw Exception('Failed to create session');
      }
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_status.isNotEmpty)
              Text(
                _status,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyIdentity,
              child: Text(_isLoading ? 'Loading...' : 'Verify Identity'),
            ),
          ],
        ),
      ),
    );
  }
}