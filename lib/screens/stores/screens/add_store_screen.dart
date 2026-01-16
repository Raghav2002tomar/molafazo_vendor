import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/add_store_controller.dart';

class AddStoreScreen extends StatelessWidget {
  const AddStoreScreen({super.key});

  InputDecoration _decoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 18) : null,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(title,
          style: Theme.of(context).textTheme.titleMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddStoreController(),
      child: Consumer<AddStoreController>(
        builder: (context, c, _) {
          final theme = Theme.of(context);

          final nameCtrl = TextEditingController();
          final mobileCtrl = TextEditingController();
          final emailCtrl = TextEditingController();
          final addressCtrl = TextEditingController();
          final descCtrl = TextEditingController();

          return Scaffold(
            appBar: AppBar(title: const Text('Create Store')),
            body: Form(
              key: c.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Status
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.info_outline,
                            color: theme.colorScheme.secondary),
                        title: const Text('Admin Approval Required'),
                        subtitle: const Text(
                            'Store will remain pending until approved.'),
                      ),
                    ),

                    _sectionTitle('Store Information', context),

                    TextFormField(
                      controller: nameCtrl,
                      decoration:
                      _decoration('Store Name *', icon: Icons.store),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: mobileCtrl,
                      decoration: _decoration('Mobile Number *',
                          icon: Icons.phone),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: emailCtrl,
                      decoration:
                      _decoration('Email *', icon: Icons.email),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: addressCtrl,
                      maxLines: 2,
                      decoration: _decoration('Address *',
                          icon: Icons.location_on),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      decoration: _decoration('Store Type *',
                          icon: Icons.category),
                      value: c.storeType,
                      items: c.storeTypes
                          .map((e) => DropdownMenuItem(
                          value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => c.storeType = v,
                      validator: (v) => v == null ? 'Required' : null,
                    ),

                    _sectionTitle('Store Images', context),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Images'),
                      onPressed: c.pickStoreImages,
                    ),

                    if (c.storeImages.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: c.storeImages.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (_, i) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(c.storeImages[i].path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: InkWell(
                                onTap: () => c.removeStoreImage(i),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    _sectionTitle('Store Proof *', context),
                    c.storeProofImage == null
                        ? OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Proof'),
                      onPressed: c.pickStoreProofImage,
                    )
                        : Image.file(File(c.storeProofImage!.path),
                        height: 160, fit: BoxFit.cover),

                    _sectionTitle('Store Description', context),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration:
                      _decoration('Description', icon: Icons.description),
                    ),

                    const SizedBox(height: 20),

                    FilledButton(
                      onPressed: () {
                        if (!c.formKey.currentState!.validate()) return;
                        if (c.storeProofImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                Text('Store proof is required')),
                          );
                          return;
                        }

                        c?.submitStore(
                          name: nameCtrl.text,
                          mobile: mobileCtrl.text,
                          email: emailCtrl.text,
                          address: addressCtrl.text,
                          description: descCtrl.text,
                        );
                      },
                      child: const Text('Submit Store'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
