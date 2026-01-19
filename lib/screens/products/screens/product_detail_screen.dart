import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:molafzo_vendor/screens/products/screens/add_product_basic_info.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  // ---------- SAFE VALUE ----------
  String val(String key, {String fallback = 'N/A'}) {
    final v = product[key];
    if (v == null || v.toString().trim().isEmpty) return fallback;
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = product['discount'] != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.white,
        actions: [InkWell(onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddProductBasicInfo()));
        }, child: SvgPicture.asset("assets/images/edit.svg")),SizedBox(width: 12,)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= IMAGE =================
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                val('image',
                    fallback:
                    'https://via.placeholder.com/600x400.png?text=No+Image'),
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            // ================= NAME =================
            Text(
              val('name', fallback: 'Sample Product Name'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // ================= PRICE =================
            Row(
              children: [
                if (hasDiscount) ...[
                  Text(
                    "₹${val('price', fallback: '0')}",
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "₹${val('discount', fallback: '0')}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ] else
                  Text(
                    "₹${val('price', fallback: '0')}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // ================= STOCK =================
            Text(
              val('stock') == '0'
                  ? 'Out of Stock'
                  : 'Stock: ${val('stock', fallback: '0')}',
              style: TextStyle(
                fontSize: 14,
                color:
                val('stock') == '0' ? Colors.red : Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            // ================= BASIC INFO =================
            _sectionTitle('Basic Information'),
            _card([
              _row('Product ID', val('id', fallback: 'P-0001')),
              _row('Store', val('store', fallback: 'Main Store')),
              _row('Category', val('category', fallback: 'General')),
              _row('Sub Category', val('subCategory', fallback: 'N/A')),
              _row('Child Category', val('childCategory', fallback: 'N/A')),
              _row('Brand', val('brand', fallback: 'No Brand')),
              _row('Color', val('color', fallback: 'Default')),
              _row('Size', val('size', fallback: 'Standard')),
            ]),

            const SizedBox(height: 20),

            // ================= DESCRIPTION =================
            _sectionTitle('Description'),
            _card([
              Text(
                val(
                  'description',
                  fallback:
                  'This is a sample product description. Detailed information will appear here.',
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ]),

            const SizedBox(height: 20),

            // ================= INVENTORY =================
            _sectionTitle('Inventory & Pricing'),
            _card([
              _row('Price', '₹${val('price', fallback: '0')}'),
              _row('Discount Price', val('discount', fallback: 'No Discount')),
              _row('Available Quantity', val('quantity', fallback: '0')),
              _row('SKU / Code', val('sku', fallback: 'SKU-XXXX')),
            ]),

            const SizedBox(height: 20),

            // ================= EXTRA DETAILS =================
            _sectionTitle('Additional Details'),
            _card([
              _row('Weight', val('weight', fallback: 'N/A')),
              _row('Dimensions', val('dimensions', fallback: 'N/A')),
              _row('Warranty', val('warranty', fallback: 'No Warranty')),
              _row('Tags', val('tags', fallback: 'No Tags')),
              _row('SEO Notes', val('seo', fallback: 'N/A')),
            ]),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
