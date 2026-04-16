

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:molafzo_vendor/extensions/context_extension.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/profile_not_eligible_widget.dart';
import '../addproduct/AddProductScreen.dart';
import '../addproduct/CopyProductScreen.dart';
import '../addproduct/contreller.dart';
import '../products/screens/add_product_basic_info.dart';
import '../products/screens/product_detail_screen.dart';
import '../products/controller/add_product_controller.dart';
import '../products/model/product_model.dart';
import '../profile/screens/store_list_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String username = 'User';
  String profilestatus = '';
  String email = '';
  final Set<int> _editingProductIds = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();

    /// 🔥 Fetch stores + products
    Future.microtask(() {
      final controller = context.read<AddProductController>();
      controller.fetchStores();
      controller.fetchProducts();
    });
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson != null) {
      final userData = jsonDecode(userJson);
      setState(() {
        username = userData['name'] ?? 'User';
        email = userData['email'] ?? '';
        profilestatus = userData['status_id']?.toString() ?? '';
      });
    }
  }

  void _showTopToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ---------------- STORE CHIP ----------------
  Widget storeChip(StoreModel? store) {
    final controller = context.watch<AddProductController>();
    final bool active = controller.selectedStore?.id == store?.id;

    return GestureDetector(
      onTap: () => controller.filterProductsByStore(store),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            store?.name ?? context.tr('all'),
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- PRODUCT CARD ----------------
  // Widget productCard(ProductModel p) {
  //   final bool outOfStock = p.availableQuantity == 0;
  //   final bool hasDiscount = p.discountPrice != null;
  //
  //   return InkWell(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => ProductDetailScreen(product: p),
  //         ),
  //       );
  //       },
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(4),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.06),
  //             blurRadius: 12,
  //             offset: const Offset(0, 6),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Expanded(
  //             child: Stack(
  //               children: [
  //                 ClipRRect(
  //                   borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
  //                   child: Image.network(
  //                     p.primaryImage,
  //                     fit: BoxFit.cover,
  //                     width: double.infinity,
  //                     errorBuilder: (_, __, ___) => Container(
  //                       color: Colors.grey.shade200,
  //                       alignment: Alignment.center,
  //                       child: const Icon(Icons.image_not_supported),
  //                     ),
  //                   ),
  //                 ),
  //
  //                 if (outOfStock)
  //                   _badge("Out of Stock", Colors.red, left: 8),
  //                 if (hasDiscount)
  //                   _badge(
  //                     "c. ${p.price - p.discountPrice!} OFF",
  //                     Colors.green,
  //                     right: 8,
  //                   ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   p.name,
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: const TextStyle(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 Row(
  //                   children: [
  //                     if (hasDiscount) ...[
  //                       Text(
  //                         "c. ${p.price}",
  //                         style: const TextStyle(
  //                           decoration: TextDecoration.lineThrough,
  //                           fontSize: 12,
  //                           color: Colors.grey,
  //                         ),
  //                       ),
  //                       const SizedBox(width: 6),
  //                       Text(
  //                         "c. ${p.discountPrice}",
  //                         style: const TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.green,
  //                         ),
  //                       ),
  //                     ] else
  //                       Text(
  //                         "c. ${p.price}",
  //                         style: const TextStyle(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //                 Text(
  //                   "Stock: ${p.availableQuantity}",
  //                   style: const TextStyle(fontSize: 12),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
// In ProductListScreen, update the product card widget
  // Update the product card widget
  Widget productCard(ProductModel p) {
    final bool outOfStock = p.availableQuantity == 0;
    final bool hasDiscount = p.discountPrice != null;
    final bool isLoading = _editingProductIds.contains(p.id);

    return InkWell(
      onTap: () {
        if (!isLoading) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: p),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    child: Image.network(
                      p.primaryImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),

                  // Edit button with loading state
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: isLoading ? null : () => _navigateToEditProduct(p),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  if (outOfStock)
                    _badge(context.tr('out_of_stock'), Colors.red, left: 8),
                  if (hasDiscount)
                    _badge(
                      "${p.price - p.discountPrice!} c. ${context.tr('off')}",
                      Colors.green,
                      right: 8,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (hasDiscount) ...[
                        Text(
                          "${p.price} c.",
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${p.discountPrice} c.",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ] else
                        Text(
                          "${p.price} c.",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    "${context.tr('stock')}: ${p.availableQuantity}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// Add navigation method
// In ProductListScreen, update _navigateToEditProduct
  void _navigateToEditProduct(ProductModel product) async {
    if (_editingProductIds.contains(product.id)) {
      return;
    }

    debugPrint('Navigating to edit product: ${product.name}');

    setState(() {
      _editingProductIds.add(product.id);
    });

    try {
      // Create a new controller
      final controller = AddProductControllernew();

      // Load the product data from the model
      await controller.loadProductFromModel(product);

      // If we have store details, we can set the store name from the product list screen
      // You'll need to have store details in your product model or fetch them
      // For now, we'll just use the storeId

      if (context.mounted) {
        setState(() {
          _editingProductIds.remove(product.id);
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddProductBasicInfonew(
              editMode: true,
              productId: product.id,
              controller: controller,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('${context.tr('error_loading_product')}: $e');
      if (mounted) {
        setState(() {
          _editingProductIds.remove(product.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('error_loading_product')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Widget _badge(String text, Color color, {double? left, double? right}) {
    return Positioned(
      top: 8,
      left: left,
      right: right,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddProductController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('products')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CopyProductScreen(),
                ),
              );
            },
          ),
          SizedBox(width: 8,),
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: () {
          //     if (profilestatus == '1') {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (_) => AddProductBasicInfonew()),
          //       );
          //     } else {
          //       _showTopToast(context,
          //           "Complete profile to add products");
          //     }
          //   },
          // ),
        ],
      ),
      body: profilestatus != '1'
          ?  ProfileNotEligibleWidget(
        title: context.tr('profile_not_approved'),
        subtitle: context.tr('complete_profile_continue'),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              context.tr('stores'),
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 35,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                storeChip(null),
                ...controller.stores.map(storeChip),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: controller.loadingProducts
                ? const Center(child: CircularProgressIndicator())
                : controller.filteredProducts.isEmpty
                ? Center(
              child: Text(context.tr('no_products_found')),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount:
              controller.filteredProducts.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (_, i) =>
                  productCard(controller.filteredProducts[i]),
            ),
          ),
        ],
      ),
    );
  }
}
