import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../controller/add_store_controller.dart';

class AddStoreScreen extends StatefulWidget {
  const AddStoreScreen({super.key});

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final nameCtrl = TextEditingController();

  final mobileCtrl = TextEditingController();

  final emailCtrl = TextEditingController();

  final addressCtrl = TextEditingController();

  final descCtrl = TextEditingController();
  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }
  InputDecoration _decoration(String label, {IconData? icon}) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
      ),
    );

  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(title,
          style: Theme.of(context).textTheme.titleLarge),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddStoreController(),
      child: Consumer<AddStoreController>(
        builder: (context, c, _) {
          final theme = Theme.of(context);



          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                backgroundColor: Colors.white,
                title: const Text('Create Store')),
            body: Form(
              key: c.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Status

                    _sectionTitle('Store Information', context),
                    SizedBox(height: 8,),
                    label('Store Name *'),

                    TextFormField(
                      controller: nameCtrl,
                      decoration: inputDec('Store Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    label('Mobile Number *'),

                    TextFormField(
                      controller: mobileCtrl,
                      decoration: inputDec('Mobile Number'),

                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    label('Email *'),

                    TextFormField(
                      controller: emailCtrl,
                      decoration: inputDec('Email'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    label('Address *'),

                    TextFormField(
                      controller: addressCtrl,
                      maxLines: 2,
                      decoration: inputDec('Address'),

                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    label('Store Type *'),

                    DropdownButtonFormField<String>(
                      value: c.storeType,
                      decoration: inputDec('Store Type'),
                      items: c.storeTypes.map((e) {
                        return DropdownMenuItem<String>(
                          value: e['value'],
                          child: Text(e['label']!),
                        );
                      }).toList(),
                      onChanged: (v) {
                        c.storeType = v;
                        c.notifyListeners();
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    SwitchListTile(
                      title: const Text('Self Pickup'),
                      value: c.selfPickup,
                      onChanged: (v) {
                        c.selfPickup = v;
                        c.notifyListeners();
                      },
                    ),

                    SwitchListTile(
                      title: const Text('Delivery By Seller'),
                      value: c.deliveryBySeller,
                      onChanged: (v) {
                        c.deliveryBySeller = v;
                        c.notifyListeners();
                      },
                    ),
                    SizedBox(height: 8,),
                    label('Store Timing *'),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => c.pickTime(context, true),
                            child: Text(
                              c.openingTime == null
                                  ? 'Opening Time'
                                  : c.openingTime!.format(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => c.pickTime(context, false),
                            child: Text(
                              c.closingTime == null
                                  ? 'Closing Time'
                                  : c.closingTime!.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),


                    _sectionTitle('Store Images', context),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Images'),
                      onPressed: c.pickStoreImages,
                    ),

                    if (c.storeImages.isNotEmpty)
                      SizedBox(height: 8,),
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
                      onPressed: c.submitting
                          ? null
                          : () async {
                        if (!c.formKey.currentState!.validate()) return;

                        if (c.storeProofImage == null) {
                          Fluttertoast.showToast(msg: 'Store proof is required');
                          return;
                        }

                        await c.submitStore(
                          name: nameCtrl.text.trim(),
                          mobile: mobileCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          address: addressCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          city: addressCtrl.text.trim(),
                        );
                      },
                      child: c.submitting
                          ? const CircularProgressIndicator()
                          : const Text('Submit Store'),
                    ),
                    SizedBox(height: 50,)
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFCA5A5)),
      ),
    );
  }

  Widget label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
  );
}
