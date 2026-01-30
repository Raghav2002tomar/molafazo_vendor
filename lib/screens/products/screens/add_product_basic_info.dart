import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile/screens/store_list_screen.dart';
import '../controller/add_product_controller.dart';
import '../model/category_model.dart';
import 'add_product_media_info.dart';

class AddProductBasicInfo extends StatefulWidget {
  const AddProductBasicInfo({super.key});

  @override
  State<AddProductBasicInfo> createState() => _AddProductBasicInfoState();
}

class _AddProductBasicInfoState extends State<AddProductBasicInfo> {
  late final AddProductController controller;

  @override
  void initState() {
    super.initState();
    controller = AddProductController();
    controller.fetchStores();
    controller.fetchCategories();
  }

  @override
  void dispose() {
    controller.disposeAll();
    controller.dispose();
    super.dispose();
  }

  InputDecoration inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<AddProductController>(
        builder: (context, c, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text('Add Product – Basic Info'),
            ),
            body: Form(
              key: c.formKeyBasic,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Store
                    label('Select Approved Store *'),
                    DropdownButtonFormField<StoreModel>(
                      decoration: inputDec('Choose store'),
                      value: c.stores.contains(c.selectedStore)
                          ? c.selectedStore
                          : null,
                      items: c.stores
                          .map(
                            (store) => DropdownMenuItem(
                          value: store,
                          child: Text(store.name),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => c.selectedStore = v,
                      validator: (v) => v == null ? 'Required' : null,
                    ),

                    const SizedBox(height: 16),

                    /// Category
                    label('Category *'),
                    DropdownButtonFormField<Category>(
                      decoration: inputDec('Select category'),
                      value: c.categories.contains(c.selectedCategory)
                          ? c.selectedCategory
                          : null,
                      items: c.categories
                          .map(
                            (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ),
                      )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        c.selectedCategory = v;
                        c.fetchSubCategories(v.id);
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),

                    const SizedBox(height: 16),

                    /// Subcategory
                    label('Subcategory *'),
                    DropdownButtonFormField<SubCategory>(
                      decoration: inputDec('Select subcategory'),
                      value: c.subCategories.contains(c.selectedSubCategory)
                          ? c.selectedSubCategory
                          : null,
                      items: c.subCategories
                          .map(
                            (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ),
                      )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        c.selectedSubCategory = v;
                        c.fetchChildCategories(v.id);
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),

                    const SizedBox(height: 16),

                    /// Child category
                    label('Sub-Child Category *'),
                    DropdownButtonFormField<ChildCategory>(
                      decoration: inputDec('Select child category'),
                      value:
                      c.childCategories.contains(c.selectedChildCategory)
                          ? c.selectedChildCategory
                          : null,
                      items: c.childCategories
                          .map(
                            (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ),
                      )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        c.selectedChildCategory = v;
                        c.fetchAttributes(v.id);
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),

                    const SizedBox(height: 16),

                    /// Attributes loader
                    if (c.loadingAttributes)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      ),

                    /// Dynamic attributes
                    ...c.attributes.map((attr) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          label(attr.name.toUpperCase()),
                          DropdownButtonFormField<String>(
                            decoration:
                            inputDec('Select ${attr.name.toLowerCase()}'),
                            value: attr.values.contains(
                                c.selectedAttributes[attr.name])
                                ? c.selectedAttributes[attr.name]
                                : null,
                            items: attr.values
                                .map(
                                  (v) => DropdownMenuItem(
                                value: v,
                                child: Text(v),
                              ),
                            )
                                .toList(),
                            onChanged: (v) =>
                            c.selectedAttributes[attr.name] = v,
                            validator: (v) =>
                            v == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    /// Product info
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

                    const SizedBox(height: 50),
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
