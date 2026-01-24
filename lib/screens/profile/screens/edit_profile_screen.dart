import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final govtIdNumberCtrl = TextEditingController();

  // Govt ID
  String? govtIdType;
  XFile? profileImage;
  XFile? govtIdImage;

  bool saving = false;
  bool acceptedTerms = false;

  // Password visibility
  bool pwdObscure = true;
  bool confirmObscure = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// ---------- LOAD USER DATA ----------
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user");
    if (userJson != null) {
      final data = jsonDecode(userJson);

      final fullName = data["name"] ?? '';
      final nameParts = fullName.split(' ');
      firstCtrl.text = nameParts.isNotEmpty ? nameParts[0] : '';
      lastCtrl.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      emailCtrl.text = data["email"] ?? '';
      mobileCtrl.text = data["mobile"] ?? '';
      addressCtrl.text = data["city"] ?? '';

      govtIdType = data["gov_id_type"];
      govtIdNumberCtrl.text = data["gov_id_number"] ?? '';

      if (data["profile_photo"] != null && data["profile_photo"].toString().isNotEmpty) {
        profileImage = XFile(data["profile_photo"]);
      }

      if (data["government_id_documents"] != null &&
          (data["government_id_documents"] as List).isNotEmpty) {
        govtIdImage = XFile(data["government_id_documents"][0]);
      }

      setState(() {});
    }
  }

  /// ---------- IMAGE PICKER ----------
  Future<void> pickImage(bool isProfile) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final compressed = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      '${picked.path}_compressed.jpg',
      quality: 70,
    );

    setState(() {
      if (isProfile) {
        profileImage = compressed != null ? XFile(compressed.path) : null;
      } else {
        govtIdImage = compressed != null ? XFile(compressed.path) : null;
      }
    });
  }

  /// ---------- VALIDATORS ----------
  String? _requiredValidator(String? v) => v == null || v.trim().isEmpty ? 'Required' : null;

  String? _emailValidator(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    final regex = RegExp(r'^\S+@\S+\.\S+$');
    if (!regex.hasMatch(v)) return 'Invalid email';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (v.length < 6) return 'Password must be at least 6 chars';
    return null;
  }

  String? _confirmPasswordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (v != pwdCtrl.text) return 'Passwords do not match';
    return null;
  }

  /// ---------- SAVE PROFILE API ----------
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!acceptedTerms) {
      Fluttertoast.showToast(msg: "Please accept the terms & conditions");
      return;
    }

    setState(() => saving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("api_token");

    if (token == null) {
      Fluttertoast.showToast(msg: "API token missing");
      setState(() => saving = false);
      return;
    }

    File? govtIdFile;
    if (govtIdImage != null) {
      if (govtIdImage!.path.startsWith('http')) {
        govtIdFile = await _downloadTempFile(govtIdImage!.path);
      } else {
        govtIdFile = File(govtIdImage!.path);
      }
    }

    final res = await ApiService.multipart(
      endpoint: "/vendor/complete-profile",
      token: token,
      fields: {
        "name": "${firstCtrl.text.trim()} ${lastCtrl.text.trim()}",
        "email": emailCtrl.text.trim(),
        "mobile": mobileCtrl.text.trim(),
        "password": pwdCtrl.text.trim(),
        "password_confirmation": confirmCtrl.text.trim(),
        "gov_id_type": govtIdType ?? "",
        "gov_id_number": govtIdNumberCtrl.text.trim(),
        "city": addressCtrl.text.trim(),
        "country": "india",
        "terms_accepted": acceptedTerms ? "1" : "0",
        "alt_mobile": "1234512345",
        "device_id": "123",
        "device_type": "ios",
        "fcm_token": "1234321",
      },
      files: {
        if (profileImage != null) "profile_photo": File(profileImage!.path),
        if (govtIdFile != null) "gov_id_document[]": govtIdFile,
      },
    );

    setState(() => saving = false);

    if (res["success"] == true || res["status"] == true) {
      Fluttertoast.showToast(msg: "Profile updated 🎉");
      prefs.setString("user", jsonEncode(res["data"]));
      if (context.mounted) Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: res["message"] ?? "Profile update failed");
    }
  }

  /// ---------- INPUT DECORATION ----------
  InputDecoration _inputDecoration(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      suffixIcon: suffix,
    );
  }

  Widget _passwordToggle(bool isPwd) {
    return IconButton(
      icon: Icon(isPwd ? (pwdObscure ? Icons.visibility : Icons.visibility_off)
          : (confirmObscure ? Icons.visibility : Icons.visibility_off)),
      onPressed: () {
        setState(() {
          if (isPwd) pwdObscure = !pwdObscure;
          else confirmObscure = !confirmObscure;
        });
      },
    );
  }

  Widget _buildProfileImage() {
    if (profileImage == null) {
      return CircleAvatar(
        radius: 42,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(Icons.person, size: 36, color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }

    return CircleAvatar(
      radius: 42,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ClipOval(
        child: Image.file(
          File(profileImage!.path),
          width: 84,
          height: 84,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.person, size: 36, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildGovtIdImage() {
    if (govtIdImage == null) {
      return OutlinedButton.icon(
        onPressed: () => pickImage(false),
        icon: const Icon(Icons.upload_file, size: 18),
        label: const Text('Upload ID Image'),
      );
    }

    Widget imageWidget;

    if (govtIdImage!.path.startsWith('http')) {
      imageWidget = FutureBuilder<File>(
        future: _downloadTempFile(govtIdImage!.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container(
              height: 140,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Container(
              height: 140,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.red)),
            );
          }

          return Image.file(
            snapshot.data!,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 140,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.red)),
              );
            },
          );
        },
      );
    } else {
      imageWidget = Image.file(
        File(govtIdImage!.path),
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 140,
            color: Colors.grey[300],
            child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.red)),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          imageWidget,
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => pickImage(false),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.black54,
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<File> _downloadTempFile(String url) async {
    final response = await http.get(Uri.parse(url));
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    return file.writeAsBytes(response.bodyBytes);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _buildProfileImage(),
                  InkWell(
                    onTap: () => pickImage(true),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: scheme.primary,
                      child: Icon(Icons.edit, size: 14, color: scheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Basic Information', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            TextFormField(controller: firstCtrl, decoration: _inputDecoration('First Name'), validator: _requiredValidator),
            const SizedBox(height: 10),
            TextFormField(controller: lastCtrl, decoration: _inputDecoration('Last Name'), validator: _requiredValidator),
            const SizedBox(height: 10),
            TextFormField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration('Email'), validator: _emailValidator),
            // const SizedBox(height: 10),
            // TextFormField(readOnly: true, controller: mobileCtrl, keyboardType: TextInputType.phone, decoration: _inputDecoration('Mobile Number'), ),
            const SizedBox(height: 10),
            TextFormField(controller: pwdCtrl, obscureText: pwdObscure, decoration: _inputDecoration('Password', suffix: _passwordToggle(true)), validator: _passwordValidator),
            const SizedBox(height: 10),
            TextFormField(controller: confirmCtrl, obscureText: confirmObscure, decoration: _inputDecoration('Confirm Password', suffix: _passwordToggle(false)), validator: _confirmPasswordValidator),
            const SizedBox(height: 20),
            Text('Government ID', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: govtIdType,
              isDense: true,
              decoration: _inputDecoration('ID Type'),
              items: const [
                DropdownMenuItem(value: 'Aadhar', child: Text('Aadhar')),
                DropdownMenuItem(value: 'PAN', child: Text('PAN')),
                DropdownMenuItem(value: 'Passport', child: Text('Passport')),
              ],
              onChanged: (v) => setState(() => govtIdType = v),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(controller: govtIdNumberCtrl, decoration: _inputDecoration('ID Number'), validator: _requiredValidator),
            const SizedBox(height: 10),
            _buildGovtIdImage(),
            const SizedBox(height: 20),
            Text('Address', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            TextFormField(controller: addressCtrl, maxLines: 3, decoration: _inputDecoration('Full Address'), validator: _requiredValidator),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: acceptedTerms,
                  onChanged: (v) => setState(() => acceptedTerms = v ?? false),
                ),
                const Expanded(child: Text("I accept terms & conditions")),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: saving ? null : saveProfile,
                child: saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 40),

          ]),
        ),
      ),
    );
  }
}
