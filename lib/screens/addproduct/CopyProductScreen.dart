// // copy_product_screen.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:molafzo_vendor/screens/addproduct/model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../services/api_service.dart';
// import '../addproduct/contreller.dart';
// import '../addproduct/AddProductScreen.dart';
// import '../products/model/product_model.dart';
//
// class CopyProductScreen extends StatefulWidget {
//   const CopyProductScreen({super.key});
//
//   @override
//   State<CopyProductScreen> createState() => _CopyProductScreenState();
// }
//
// class _CopyProductScreenState extends State<CopyProductScreen> {
//   List<ProductModel> products = [];
//   bool isLoading = false;
//   bool isInitialLoading = true;
//   bool hasMore = true;
//   int currentPage = 1;
//   final ScrollController _scrollController = ScrollController();
//   int? selectedStoreId;
//   List<StoreModel> stores = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchStores();
//     _fetchProducts();
//     _scrollController.addListener(_onScroll);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200 &&
//         !isLoading && hasMore) {
//       currentPage++;
//       _fetchProducts();
//     }
//   }
//
//   Future<void> _fetchStores() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('api_token');
//
//       final response = await ApiService.get(
//         endpoint: "/vendor/store/list",
//         token: token,
//       );
//
//       if (response['success'] == true && response['data'] != null) {
//         final storesData = response['data'] as List;
//         stores = storesData.map((e) => StoreModel.fromJson(e)).toList();
//         if (stores.isNotEmpty) {
//           selectedStoreId = stores.first.id;
//           setState(() {});
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching stores: $e');
//     }
//   }
//
//   Future<void> _fetchProducts() async {
//     if (isLoading) return;
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('api_token');
//
//       if (token == null) {
//         debugPrint('❌ No token found');
//         setState(() {
//           isLoading = false;
//           isInitialLoading = false;
//         });
//         return;
//       }
//
//       final response = await ApiService.get(
//         endpoint: "/vendor/product/list?type=all",
//         token: token,
//       );
//
//       if (response["success"] == true || response["status"] == true) {
//         final newProductsData = response["data"] as List;
//         final newProducts = newProductsData.map((e) => ProductModel.fromJson(e)).toList();
//         debugPrint('✅ Fetched ${newProducts.length} products');
//
//         setState(() {
//           if (currentPage == 1) {
//             products = newProducts;
//           } else {
//             products.addAll(newProducts);
//           }
//           hasMore = newProducts.length >= 15;
//           isLoading = false;
//           isInitialLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           isInitialLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('❌ Error fetching products: $e');
//       setState(() {
//         isLoading = false;
//         isInitialLoading = false;
//       });
//     }
//   }
//
//   void _openCopyProductScreen(ProductModel product) async {
//     if (selectedStoreId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a store first')),
//       );
//       return;
//     }
//
//     // Create a new controller
//     final controller = AddProductControllernew();
//
//     // Load the product data from the model (this will populate all fields)
//     await controller.loadProductFromModel(product);
//
//     // Set the selected store (the store where we want to copy to)
//     final selectedStore = stores.firstWhere((s) => s.id == selectedStoreId);
//     controller.selectedStore = selectedStore;
//
//     if (context.mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => AddProductBasicInfonew(
//             editMode: true,
//             productId: null, // No product ID for edit
//             controller: controller,
//             originalProductIdForCopy: product.id, // Pass the original product ID for copy
//           ),
//         ),
//       );
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: [
//           ElevatedButton(
//             onPressed: selectedStoreId != null
//                 ? () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) => AddProductBasicInfonew()),
//               );
//             }
//                 : null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               minimumSize: const Size(0, 32),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.only(left: 16,right: 16),
//               child: const Text(
//                 'Add New',
//                 style: TextStyle(fontSize: 11),
//               ),
//             ),
//           ),
//           SizedBox(width: 16,)
//         ],
//         // title: const Text('Copy Products from Marketplace'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(80),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: Colors.grey.shade200)),
//             ),
//             child: Column(
//               children: [
//                 Text('Copy Products from Marketplace'),
//                 Row(
//                   children: [
//                     const Icon(Icons.store, size: 20, color: Colors.black54),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Copy to:',
//                       style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: DropdownButton<int>(
//                         value: selectedStoreId,
//                         isExpanded: true,
//                         underline: const SizedBox(),
//                         hint: const Text('Select Store'),
//                         items: stores.map((store) {
//                           return DropdownMenuItem<int>(
//                             value: store.id,
//                             child: Text(
//                               store!.name,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedStoreId = value;
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: isInitialLoading
//           ? const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading products...'),
//           ],
//         ),
//       )
//           : products.isEmpty
//           ? const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.inventory, size: 64, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               'No products available',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       )
//           : GridView.builder(
//         controller: _scrollController,
//         padding: const EdgeInsets.all(12),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: 0.65,
//         ),
//         itemCount: products.length + (isLoading ? 1 : 0),
//         itemBuilder: (context, index) {
//           if (index == products.length) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }
//           final product = products[index];
//           return _buildProductCard(product);
//         },
//       ),
//     );
//   }
//
//   Widget _buildProductCard(ProductModel product) {
//     final imageUrl = product.primaryImage;
//     final hasDiscount = product.hasDiscount;
//     final price = product.price;
//     final discountPrice = product.discountPrice;
//
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AspectRatio(
//             aspectRatio: 1,
//             child: Image.network(
//               imageUrl,
//               fit: BoxFit.cover,
//               width: double.infinity,
//               errorBuilder: (_, __, ___) => Container(
//                 color: Colors.grey.shade200,
//                 child: const Icon(Icons.image_not_supported, size: 40),
//               ),
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Container(
//                   color: Colors.grey.shade200,
//                   child: const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   product.name,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//
//                 Row(
//                   children: [
//                     if (hasDiscount && discountPrice != null) ...[
//                       Text(
//                         '₹${price.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                           decoration: TextDecoration.lineThrough,
//                           fontSize: 11,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         '₹${discountPrice.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                           color: Colors.green,
//                         ),
//                       ),
//                     ] else
//                       Text(
//                         '₹${price.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                   ],
//                 ),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: selectedStoreId != null
//                         ? () => _openCopyProductScreen(product)
//                         : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       minimumSize: const Size(0, 32),
//                     ),
//                     child: const Text(
//                       'Copy to My Store',
//                       style: TextStyle(fontSize: 11),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// copy_product_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:molafzo_vendor/screens/addproduct/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../addproduct/contreller.dart';
import '../addproduct/AddProductScreen.dart';
import '../products/model/product_model.dart';

class CopyProductScreen extends StatefulWidget {
  const CopyProductScreen({super.key});

  @override
  State<CopyProductScreen> createState() => _CopyProductScreenState();
}

class _CopyProductScreenState extends State<CopyProductScreen> {
  List<ProductModel> products = [];
  bool isLoading = false;
  bool isInitialLoading = true;
  bool hasMore = true;
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  int? selectedStoreId;
  List<StoreModel> stores = [];

  // Add a set to track which products are being copied
  final Set<int> _copyingProductIds = {};

  @override
  void initState() {
    super.initState();
    _fetchStores();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoading && hasMore) {
      currentPage++;
      _fetchProducts();
    }
  }

  Future<void> _fetchStores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      final response = await ApiService.get(
        endpoint: "/vendor/store/list",
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        final storesData = response['data'] as List;
        stores = storesData.map((e) => StoreModel.fromJson(e)).toList();
        if (stores.isNotEmpty) {
          selectedStoreId = stores.first.id;
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error fetching stores: $e');
    }
  }

  Future<void> _fetchProducts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null) {
        debugPrint('❌ No token found');
        setState(() {
          isLoading = false;
          isInitialLoading = false;
        });
        return;
      }

      final response = await ApiService.get(
        endpoint: "/vendor/product/list?type=all",
        token: token,
      );

      if (response["success"] == true || response["status"] == true) {
        final newProductsData = response["data"] as List;
        final newProducts = newProductsData.map((e) => ProductModel.fromJson(e)).toList();
        debugPrint('✅ Fetched ${newProducts.length} products');

        setState(() {
          if (currentPage == 1) {
            products = newProducts;
          } else {
            products.addAll(newProducts);
          }
          hasMore = newProducts.length >= 15;
          isLoading = false;
          isInitialLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isInitialLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      setState(() {
        isLoading = false;
        isInitialLoading = false;
      });
    }
  }

  void _openCopyProductScreen(ProductModel product) async {
    // Prevent multiple clicks on the same product
    if (_copyingProductIds.contains(product.id)) {
      return;
    }

    if (selectedStoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a store first')),
      );
      return;
    }

    // Add to copying set
    setState(() {
      _copyingProductIds.add(product.id);
    });

    try {
      // Create a new controller
      final controller = AddProductControllernew();

      // Load the product data from the model (this will populate all fields)
      await controller.loadProductFromModel(product);

      // IMPORTANT: Set the selected store (the store where we want to copy to)
      // This overrides the store from the original product
      final selectedStore = stores.firstWhere((s) => s.id == selectedStoreId);
      controller.selectedStore = selectedStore;

      if (context.mounted) {
        // Remove from copying set before navigation
        setState(() {
          _copyingProductIds.remove(product.id);
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddProductBasicInfonew(
              editMode: true,
              productId: null, // No product ID for copy
              controller: controller,
              originalProductIdForCopy: product.id, // Pass the original product ID for copy
            ),
          ),
        );
      } else {
        // If context is not mounted, still remove from set
        setState(() {
          _copyingProductIds.remove(product.id);
        });
      }
    } catch (e) {
      debugPrint('Error loading product for copy: $e');
      // Remove from copying set on error
      if (mounted) {
        setState(() {
          _copyingProductIds.remove(product.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: selectedStoreId != null
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddProductBasicInfonew()),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: const Size(0, 32),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: const Text(
                'Add New',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                const Text('Copy Products from Marketplace'),
                Row(
                  children: [
                    const Icon(Icons.store, size: 20, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Text(
                      'Copy to:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<int>(
                        value: selectedStoreId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Select Store'),
                        items: stores.map((store) {
                          return DropdownMenuItem<int>(
                            value: store.id,
                            child: Text(
                              store.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStoreId = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: isInitialLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading products...'),
          ],
        ),
      )
          : products.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: products.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final product = products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final imageUrl = product.primaryImage;
    final hasDiscount = product.hasDiscount;
    final price = product.price;
    final discountPrice = product.discountPrice;
    final bool isCopying = _copyingProductIds.contains(product.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, size: 40),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    if (hasDiscount && discountPrice != null) ...[
                      Text(
                        '${price.toStringAsFixed(0)} c.',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${discountPrice.toStringAsFixed(0)} c.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ] else
                      Text(
                        '${price.toStringAsFixed(0)} c.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (selectedStoreId != null && !isCopying)
                        ? () => _openCopyProductScreen(product)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      minimumSize: const Size(0, 32),
                    ),
                    child: isCopying
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Copy to My Store',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}