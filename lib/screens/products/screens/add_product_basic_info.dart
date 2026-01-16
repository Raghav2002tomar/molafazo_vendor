import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/add_product_controller.dart';
import 'add_product_media_info.dart';

class AddProductBasicInfo extends StatelessWidget {
  const AddProductBasicInfo({super.key});

  InputDecoration inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddProductController(),
      child: Consumer<AddProductController>(
        builder: (context, c, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Add Product – Basic Info')),
            body: Form(
              key: c.formKeyBasic,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Store
                    label('Select Approved Store *'),
                    DropdownButtonFormField(
                      decoration: inputDec('Choose store'),
                      value: c.selectedStore,
                      items: c.approvedStores
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => c.selectedStore = v,
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    /// Category
                    label('Category *'),
                    DropdownButtonFormField(
                      decoration: inputDec('Select category'),
                      value: c.category,
                      items: c.categories
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => c.category = v,
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    label('Subcategory *'),
                    DropdownButtonFormField(
                      decoration: inputDec('Select subcategory'),
                      value: c.subCategory,
                      items: c.subCategories
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => c.subCategory = v,
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    label('Sub-Child Category *'),
                    DropdownButtonFormField(
                      decoration: inputDec('Select child category'),
                      value: c.childCategory,
                      items: c.childCategories
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => c.childCategory = v,
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    /// Optional dropdowns
                    label('Brand'),
                    DropdownButtonFormField(
                      decoration: inputDec('Select brand'),
                      value: c.brand,
                      items: c.brands
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => c.brand = v,
                    ),
                    const SizedBox(height: 16),

                    label('Color'),
                    DropdownButtonFormField(
                      decoration: inputDec('Select color'),
                      value: c.color,
                      items: c.colors
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => c.color = v,
                    ),
                    const SizedBox(height: 16),

                    label('Size'),
                    DropdownButtonFormField(
                      decoration: inputDec('Select size'),
                      value: c.size,
                      items: c.sizes
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => c.size = v,
                    ),
                    const SizedBox(height: 16),

                    /// Text fields
                    label('Product Name *'),
                    TextFormField(
                      controller: c.nameController,
                      decoration: inputDec('Enter product name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    label('SKU / Product Code *'),
                    TextFormField(
                      controller: c.skuController,
                      decoration: inputDec('Unique product code'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    label('Product Price *'),
                    TextFormField(
                      controller: c.priceController,
                      keyboardType: TextInputType.number,
                      decoration: inputDec('Enter price'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    label('Discount Price'),
                    TextFormField(
                      controller: c.discountController,
                      keyboardType: TextInputType.number,
                      decoration: inputDec('Optional'),
                    ),
                    const SizedBox(height: 16),

                    label('Available Quantity *'),
                    TextFormField(
                      controller: c.qtyController,
                      keyboardType: TextInputType.number,
                      decoration: inputDec('Stock quantity'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    label('Product Description *'),
                    TextFormField(
                      controller: c.descController,
                      maxLines: 3,
                      decoration: inputDec('Enter product description'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: () {
                        if (!c.formKeyBasic.currentState!.validate()) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddProductMediaInfo(controller: c),
                          ),
                        );
                      },
                      child: const Text('Next'),
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
