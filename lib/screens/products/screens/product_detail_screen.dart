import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../promotion/add_review/screens/packages_screen.dart';
import '../model/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  ProductCombination? _selectedCombination;
  double _currentPrice = 0;
  double? _currentDiscountPrice;
  List<ProductImage> _currentImages = [];

  @override
  void initState() {
    super.initState();
    // Initialize with base product data
    _currentPrice = widget.product.price;
    _currentDiscountPrice = widget.product.discountPrice;
    _currentImages = List.from(widget.product.images);
    _selectedCombination = widget.product.combinations?.isNotEmpty == true
        ? widget.product.combinations!.first
        : null;

    // If there's a selected combination, update price and images
    if (_selectedCombination != null) {
      _updateFromCombination(_selectedCombination!);
    }
  }

  void _updateFromCombination(ProductCombination combination) {
    setState(() {
      _currentPrice = combination.price;
      _currentDiscountPrice = combination.priceBeforeDiscount;

      // Update images if combination has specific images
      if (combination.images.isNotEmpty) {
        _currentImages = combination.images.map((imgPath) {
          return ProductImage(
            id: 0,
            image: imgPath,
            color: null,
            isPrimary: false,
          );
        }).toList();

        // Reset to first image
        _selectedImageIndex = 0;
      } else {
        // If no combination images, use original product images
        _currentImages = List.from(widget.product.images);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        elevation: 0,
        actions: [
          InkWell(onTap: ()async {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('api_token');

            if (token == null || token.isEmpty) {
              Fluttertoast.showToast(msg: "Authentication failed. Login again.");
              return;
            }
         await   Navigator.push(context, MaterialPageRoute(builder: (context)=>PackagesScreen(productId: widget.product.id.toString(),token: token,)));
          }, child: Icon(Icons.production_quantity_limits)),
          SizedBox(width: 8,)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            _buildImageGallery(),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price (Dynamic based on selected variant)
                  _buildPriceSection(),
                  const SizedBox(height: 12),

                  // Stock Status (Dynamic based on selected variant)
                  _buildStockStatus(),
                  const SizedBox(height: 12),

                  // Category Info
                  _buildCategoryInfo(),
                  const SizedBox(height: 12),

                  // Delivery Info
                  _buildDeliveryInfo(),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 16),

                  // Product Description
                  _buildDescription(),
                  const SizedBox(height: 16),

                  // Tags
                  if (widget.product.tags.isNotEmpty)
                    _buildTags(),
                  // const SizedBox(height: 16),

                  // Attributes
                  // if (widget.product.attributesJson != null &&
                  //     widget.product.attributesJson!.isNotEmpty)
                  //   _buildAttributes(),
                  // const SizedBox(height: 16),

                  // Combinations (Variants)
                  if (widget.product.combinations != null &&
                      widget.product.combinations!.isNotEmpty)
                    _buildVariants(),
                  const SizedBox(height: 16),

                  // Banks
                  // if (widget.product.banks.isNotEmpty)
                  //   _buildBanks(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_currentImages.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Main Image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _currentImages[_selectedImageIndex].imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            ),
          ),

          // Thumbnails
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _currentImages.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedImageIndex == index
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: _currentImages[index].imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Discount Badge
          if (_currentDiscountPrice != null && _currentDiscountPrice! < _currentPrice)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${((_currentPrice - _currentDiscountPrice!) / _currentPrice * 100).toStringAsFixed(0)}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final hasDiscount = _currentDiscountPrice != null && _currentDiscountPrice! < _currentPrice;

    return Row(
      children: [
        if (hasDiscount) ...[
          Text(
            '₽${_currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₽${_currentDiscountPrice!.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ] else
          Text(
            '₽${_currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildStockStatus() {
    final int stock = _selectedCombination?.stock ?? widget.product.availableQuantity;
    final bool inStock = stock > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: inStock ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        inStock
            ? 'In Stock ($stock units available)'
            : 'Out of Stock',
        style: TextStyle(
          color: inStock ? Colors.green[800] : Colors.red[800],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('Category', widget.product.category.name),
          const SizedBox(height: 8),
          _buildInfoRow('Sub Category', widget.product.subCategory.name),
          if (widget.product.childCategory != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildInfoRow('Child Category', widget.product.childCategory!.name),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('Delivery', widget.product.deliveryAvailable ? 'Available' : 'Not Available'),
          const SizedBox(height: 8),
          if (widget.product.deliveryAvailable) ...[
            _buildInfoRow('Delivery Price', '₽${widget.product.deliveryPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildInfoRow('Delivery Time', widget.product.deliveryTime),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description.isEmpty ? 'No description available' : widget.product.description,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: widget.product.tags.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAttributes() {
    if (widget.product.attributesJson == null || widget.product.attributesJson!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   'Product Specifications',
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // const SizedBox(height: 8),
        // ...widget.product.attributesJson!.entries.map((entry) {
        //   // Ensure the value is a list
        //   final values = entry.value is List ? entry.value as List : [entry.value];
        //
        //   return Padding(
        //     padding: const EdgeInsets.only(bottom: 8),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(
        //           entry.key.toUpperCase(),
        //           style: TextStyle(
        //             fontSize: 12,
        //             color: Colors.grey[600],
        //             fontWeight: FontWeight.w600,
        //           ),
        //         ),
        //         const SizedBox(height: 4),
        //         Wrap(
        //           spacing: 8,
        //           children: values.map((value) {
        //             return Container(
        //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        //               decoration: BoxDecoration(
        //                 border: Border.all(color: Colors.grey[300]!),
        //                 borderRadius: BorderRadius.circular(20),
        //               ),
        //               child: Text(
        //                 value.toString(),
        //                 style: const TextStyle(fontSize: 13),
        //               ),
        //             );
        //           }).toList(),
        //         ),
        //       ],
        //     ),
        //   );
        // }),
      ],
    );
  }
  Widget _buildVariants() {
    if (widget.product.combinations == null) return const SizedBox();

    // Group variants by attribute
    final attributes = <String, Set<String>>{};
    for (final combo in widget.product.combinations!) {
      for (final entry in combo.variant.entries) {
        attributes.putIfAbsent(entry.key, () => {}).add(entry.value.toString());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Text(
        //   'Variants',
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        // const SizedBox(height: 12),
        ...attributes.entries.map((attr) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                attr.key.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: attr.value.map((value) {
                  // Fix: Convert the variant value to string for comparison
                  final isSelected = _selectedCombination?.variant[attr.key]?.toString() == value;
                  return FilterChip(
                    label: Text(value),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        // Find combination that matches ALL selected attributes
                        final newCombo = _findCombinationMatchingSelections(attr.key, value);
                        if (newCombo != null) {
                          setState(() {
                            _selectedCombination = newCombo;
                            _updateFromCombination(newCombo);
                          });
                        }
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
          );
        }),
        if (_selectedCombination != null && _selectedCombination!.variant.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Variant Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ..._selectedCombination!.variant.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '${entry.key}: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(entry.value.toString()),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
      ],
    );
  }

  ProductCombination? _findCombinationMatchingSelections(String selectedKey, String selectedValue) {
    if (widget.product.combinations == null) return null;

    // Build current selection map
    final Map<String, String> currentSelections = {};
    if (_selectedCombination != null) {
      // Convert all variant values to strings
      _selectedCombination!.variant.forEach((key, value) {
        currentSelections[key] = value.toString();
      });
    }
    currentSelections[selectedKey] = selectedValue;

    // Find combination that matches all selections
    for (final combo in widget.product.combinations!) {
      bool matches = true;
      for (final entry in currentSelections.entries) {
        final comboValue = combo.variant[entry.key]?.toString();
        if (comboValue != entry.value) {
          matches = false;
          break;
        }
      }
      if (matches) {
        return combo;
      }
    }

    return null;
  }


  Widget _buildBanks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Banks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.product.banks.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final bank = widget.product.banks[index];
            return ListTile(
              leading: bank.logo.isNotEmpty
                  ? CircleAvatar(
                backgroundImage: NetworkImage(bank.logo),
                radius: 20,
              )
                  : const Icon(Icons.account_balance),
              title: Text(bank.bankName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account: ${bank.accountHolderName}'),
                  Text('Number: ${bank.accountNumber}'),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}