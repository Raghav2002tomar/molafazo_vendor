//
// import 'package:flutter/material.dart';
// import 'package:molafzo_vendor/screens/addproduct/model.dart';
// import 'package:provider/provider.dart';
// import 'contreller.dart';
//
// class AddProductCategoryScreen extends StatelessWidget {
//   final AddProductControllernew controller;
//   const AddProductCategoryScreen({super.key, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: controller,
//       child: Consumer<AddProductControllernew>(
//         builder: (context, c, _) {
//           return Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               backgroundColor: Colors.white,
//               title: const Text('Select Category'),
//               elevation: 0,
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () => Navigator.pop(context),
//               ),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   onPressed: () {
//                     c.fetchCategories();
//                   },
//                 ),
//               ],
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Product Category',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Select category, subcategory, and child category',
//                     style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Selected Category Display
//                   if (c.selectedCategory != null || c.selectedSubCategory != null || c.selectedChildCategory != null)
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.green.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.green.shade200),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               _getSelectedCategoryPath(c),
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.green.shade700,
//                               ),
//                             ),
//                           ),
//                           if (c.selectedChildCategory != null)
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pop(context, true); // Return to main page
//                               },
//                               child: const Text('Done'),
//                             ),
//                         ],
//                       ),
//                     ),
//
//                   const SizedBox(height: 24),
//
//                   // Categories List
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Main Categories
//                           _buildCategorySection(
//                             title: 'Category',
//                             items: c.categories,
//                             selectedItem: c.selectedCategory,
//                             loading: c.loadingCategory,
//                             onSelect: (category) {
//                               c.selectedCategory = category;
//                               c.selectedSubCategory = null;
//                               c.selectedChildCategory = null;
//                               c.subCategories.clear();
//                               c.childCategories.clear();
//                               c.fetchSubCategories(category.id);
//                             },
//                           ),
//
//                           const SizedBox(height: 16),
//
//                           // Subcategories - only show if a category is selected
//                           if (c.selectedCategory != null) ...[
//                             const Divider(),
//                             _buildCategorySection(
//                               title: 'Subcategory',
//                               items: c.subCategories,
//                               selectedItem: c.selectedSubCategory,
//                               loading: c.loadingSubCategory,
//                               onSelect: (subCategory) {
//                                 c.selectedSubCategory = subCategory;
//                                 c.selectedChildCategory = null;
//                                 c.childCategories.clear();
//                                 c.fetchChildCategories(subCategory.id);
//                               },
//                             ),
//                           ],
//
//                           const SizedBox(height: 16),
//
//                           // Child Categories - only show if a subcategory is selected
//                           if (c.selectedSubCategory != null) ...[
//                             const Divider(),
//                             _buildCategorySection(
//                               title: 'Child Category',
//                               items: c.childCategories,
//                               selectedItem: c.selectedChildCategory,
//                               loading: c.loadingChildCategory,
//                               onSelect: (childCategory) {
//                                 c.selectedChildCategory = childCategory;
//                                 c.notifyListeners();
//                               },
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildCategorySection<T>({
//     required String title,
//     required List<T> items,
//     required T? selectedItem,
//     required bool loading,
//     required Function(T) onSelect,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         if (loading)
//           const Center(
//             child: Padding(
//               padding: EdgeInsets.all(20.0),
//               child: CircularProgressIndicator(),
//             ),
//           )
//         else if (items.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Center(
//               child: Column(
//                 children: [
//                   Icon(Icons.info_outline, color: Colors.grey.shade400, size: 32),
//                   const SizedBox(height: 8),
//                   Text(
//                     'No $title available',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         else
//           Wrap(
//             spacing: 10,
//             runSpacing: 10,
//             children: items.map((item) {
//               final isSelected = selectedItem == item;
//               String name = '';
//               if (item is Category) name = item.name;
//               if (item is SubCategory) name = item.name;
//               if (item is ChildCategory) name = item.name;
//
//               return ChoiceChip(
//                 label: Text(name),
//                 selected: isSelected,
//                 onSelected: (selected) {
//                   if (selected) {
//                     onSelect(item);
//                   }
//                 },
//                 backgroundColor: Colors.grey.shade100,
//                 selectedColor: Colors.green.shade100,
//                 labelStyle: TextStyle(
//                   color: isSelected ? Colors.green.shade700 : Colors.black87,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 ),
//                 avatar: isSelected
//                     ? const Icon(Icons.check, size: 18, color: Colors.green)
//                     : null,
//               );
//             }).toList(),
//           ),
//         const SizedBox(height: 8),
//       ],
//     );
//   }
//
//   String _getSelectedCategoryPath(AddProductControllernew c) {
//     List<String> path = [];
//     if (c.selectedCategory != null) {
//       path.add(c.selectedCategory!.name);
//     }
//     if (c.selectedSubCategory != null) {
//       path.add(c.selectedSubCategory!.name);
//     }
//     if (c.selectedChildCategory != null) {
//       path.add(c.selectedChildCategory!.name);
//     }
//     return path.join(' → ');
//   }
// }

// CategorySelectScreen.dart - Updated with black theme

import 'package:flutter/material.dart';
import 'package:molafzo_vendor/screens/addproduct/model.dart';
import 'package:provider/provider.dart';
import 'contreller.dart';

class AddProductCategoryScreen extends StatelessWidget {
  final AddProductControllernew controller;
  const AddProductCategoryScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<AddProductControllernew>(
        builder: (context, c, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text('Select Category', style: TextStyle(color: Colors.black, fontSize: 16)),
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  onPressed: () {
                    c.fetchCategories();
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select category, subcategory, and child category',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (c.selectedCategory != null || c.selectedSubCategory != null || c.selectedChildCategory != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.black, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _getSelectedCategoryPath(c),
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ),
                          if (c.selectedChildCategory != null)
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              style: TextButton.styleFrom(foregroundColor: Colors.black),
                              child: const Text('Done', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategorySection(
                            title: 'Category',
                            items: c.categories,
                            selectedItem: c.selectedCategory,
                            loading: c.loadingCategory,
                            onSelect: (category) {
                              c.selectedCategory = category;
                              c.selectedSubCategory = null;
                              c.selectedChildCategory = null;
                              c.subCategories.clear();
                              c.childCategories.clear();
                              c.fetchSubCategories(category.id);
                            },
                          ),
                          const SizedBox(height: 16),
                          if (c.selectedCategory != null) ...[
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            _buildCategorySection(
                              title: 'Subcategory',
                              items: c.subCategories,
                              selectedItem: c.selectedSubCategory,
                              loading: c.loadingSubCategory,
                              onSelect: (subCategory) {
                                c.selectedSubCategory = subCategory;
                                c.selectedChildCategory = null;
                                c.childCategories.clear();
                                c.fetchChildCategories(subCategory.id);
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          if (c.selectedSubCategory != null) ...[
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            _buildCategorySection(
                              title: 'Child Category',
                              items: c.childCategories,
                              selectedItem: c.selectedChildCategory,
                              loading: c.loadingChildCategory,
                              onSelect: (childCategory) {
                                c.selectedChildCategory = childCategory;
                                c.notifyListeners();
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection<T>({
    required String title,
    required List<T> items,
    required T? selectedItem,
    required bool loading,
    required Function(T) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 10),
        if (loading)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade500, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'No $title available',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final isSelected = selectedItem == item;
              String name = '';
              if (item is Category) name = item.name;
              if (item is SubCategory) name = item.name;
              if (item is ChildCategory) name = item.name;

              return ChoiceChip(
                label: Text(name, style: TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onSelect(item);
                  }
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.black,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                avatar: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              );
            }).toList(),
          ),
      ],
    );
  }

  String _getSelectedCategoryPath(AddProductControllernew c) {
    List<String> path = [];
    if (c.selectedCategory != null) {
      path.add(c.selectedCategory!.name);
    }
    if (c.selectedSubCategory != null) {
      path.add(c.selectedSubCategory!.name);
    }
    if (c.selectedChildCategory != null) {
      path.add(c.selectedChildCategory!.name);
    }
    return path.join(' → ');
  }
}