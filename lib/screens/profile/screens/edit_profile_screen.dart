import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final govtIdNumberCtrl = TextEditingController();

  String? govtIdType;
  XFile? profileImage;
  XFile? govtIdImage;

  bool saving = false;

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
        profileImage =
        compressed != null ? XFile(compressed.path) : null;
      } else {
        govtIdImage =
        compressed != null ? XFile(compressed.path) : null;
      }
    });
  }

  /// ---------- SAVE ----------
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => saving = false);
      Navigator.pop(context, true);
    }
  }

  /// ---------- COMPACT INPUT DECORATION ----------
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- PROFILE IMAGE ----------
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor:
                      scheme.surfaceContainerHighest,
                      backgroundImage: profileImage != null
                          ? FileImage(File(profileImage!.path))
                          : null,
                      child: profileImage == null
                          ? Icon(
                        Icons.person,
                        size: 36,
                        color: scheme.onSurfaceVariant,
                      )
                          : null,
                    ),
                    InkWell(
                      onTap: () => pickImage(true),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: scheme.primary,
                        child: Icon(
                          Icons.edit,
                          size: 14,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ---------- BASIC INFO ----------
              Text(
                'Basic Information',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: firstCtrl,
                decoration: _inputDecoration('First Name'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: lastCtrl,
                decoration: _inputDecoration('Last Name'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Email'),
                validator: (v) => v != null &&
                    RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)
                    ? null
                    : 'Invalid email',
              ),

              const SizedBox(height: 20),

              /// ---------- GOVT ID ----------
              Text(
                'Government ID',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: govtIdType,
                isDense: true,
                decoration: _inputDecoration('ID Type'),
                items: const [
                  DropdownMenuItem(
                      value: 'Aadhar', child: Text('Aadhar')),
                  DropdownMenuItem(
                      value: 'PAN', child: Text('PAN')),
                  DropdownMenuItem(
                      value: 'Passport', child: Text('Passport')),
                ],
                onChanged: (v) => setState(() => govtIdType = v),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: govtIdNumberCtrl,
                decoration: _inputDecoration('ID Number'),
              ),
              const SizedBox(height: 10),

              govtIdImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(govtIdImage!.path),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
                  : OutlinedButton.icon(
                onPressed: () => pickImage(false),
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload ID Image'),
              ),

              const SizedBox(height: 20),

              /// ---------- ADDRESS ----------
              Text(
                'Address',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: addressCtrl,
                maxLines: 3,
                decoration: _inputDecoration('Full Address'),
              ),

              const SizedBox(height: 28),

              /// ---------- SAVE ----------
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: saving ? null : saveProfile,
                  child: saving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
