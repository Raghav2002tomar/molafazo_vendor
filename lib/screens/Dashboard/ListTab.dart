import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  /// ---------------- STORE LIST ----------------
  final List<String> stores = [
    'All',
    'Store A',
    'Store B',
    'Store C',
  ];

  String selectedStore = 'All';

  /// ---------------- DUMMY PRODUCT DATA ----------------
  final List<Map<String, dynamic>> products = [
    {
      "id": 1,
      "store": "Store A",
      "name": "iPhone 15 Pro Max",
      "price": 129999,
      "discount": 119999,
      "image":
      "https://images.unsplash.com/photo-1695048133142-1a20484d2569",
      "stock": 10
    },
    {
      "id": 2,
      "store": "Store A",
      "name": "Samsung Galaxy S24 Ultra",
      "price": 89999,
      "discount": null,
      "image":
      "https://images.unsplash.com/photo-1610945265064-0e34e5519bbf",
      "stock": 5
    },
    {
      "id": 3,
      "store": "Store B",
      "name": "Nike Running Shoes",
      "price": 5999,
      "discount": 4499,
      "image":
      "https://images.unsplash.com/photo-1542291026-7eec264c27ff",
      "stock": 25
    },
    {
      "id": 4,
      "store": "Store C",
      "name": "Leather Backpack",
      "price": 3499,
      "discount": null,
      "image": "broken_url",
      "stock": 0
    },
  ];

  /// ---------------- FILTER ----------------
  List<Map<String, dynamic>> get filteredProducts {
    if (selectedStore == 'All') return products;
    return products.where((p) => p['store'] == selectedStore).toList();
  }

  /// ---------------- STORE FILTER CHIP ----------------
  Widget storeChip(String store) {
    final bool active = store == selectedStore;

    return GestureDetector(
      onTap: () => setState(() => selectedStore = store),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
         margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.only(left: 22,right: 22),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
          boxShadow: active
              ? [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.3),
              blurRadius: 10,
            )
          ]
              : [],
        ),
        child: Center(
          child: Text(
            store,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- IMAGE WITH ERROR HANDLING ----------------
  Widget productImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,height: 180,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported,
            size: 60, color: Colors.grey),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }

  /// ---------------- PRODUCT CARD ----------------
  Widget productCard(Map<String, dynamic> p) {
    final bool outOfStock = p['stock'] == 0;
    final bool hasDiscount = p['discount'] != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
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
          /// IMAGE
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: double.infinity,
                    child: productImage(p['image']),
                  ),
                ),

                /// OUT OF STOCK
                if (outOfStock)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _badge("Out of Stock", Colors.red),
                  ),

                /// DISCOUNT
                if (hasDiscount)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _badge(
                        "₹${p['price'] - p['discount']} OFF", Colors.green),
                  ),
              ],
            ),
          ),

          /// INFO
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                // const SizedBox(height: 4),

                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        "₹${p['price']}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "₹${p['discount']}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ] else
                      Text(
                        "₹${p['price']}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),

                // const SizedBox(height: 4),
                Text(
                  "Stock: ${p['stock']}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Products'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// STORE FILTER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 0, 12),
            child: const Text(
              'Stores',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: stores.map(storeChip).toList(),
            ),
          ),

          const SizedBox(height: 10),

          /// PRODUCT GRID
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
              child: Text(
                "No products available",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.99,
              ),
              itemBuilder: (context, index) =>
                  productCard(filteredProducts[index]),
            ),
          ),
        ],
      ),
    );
  }
}
