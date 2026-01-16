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
      "name": "iPhone 15 Pro",
      "price": 129999,
      "discount": 119999,
      "image":
      "https://images.unsplash.com/photo-1695048133142-1a20484d2569",
      "stock": 10
    },
    {
      "id": 2,
      "store": "Store A",
      "name": "Samsung Galaxy S24",
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
      "image":
      "https://images.unsplash.com/photo-1598032894681-ff9ff6e4c1f3",
      "stock": 0
    },
  ];

  /// ---------------- FILTER LOGIC ----------------
  List<Map<String, dynamic>> get filteredProducts {
    if (selectedStore == 'All') return products;
    return products.where((p) => p['store'] == selectedStore).toList();
  }

  /// ---------------- STORE CHIP ----------------
  Widget storeChip(String store) {
    final bool active = store == selectedStore;

    return GestureDetector(
      onTap: () => setState(() => selectedStore = store),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          store,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// ---------------- PRODUCT CARD ----------------
  Widget productCard(Map<String, dynamic> p) {
    final bool outOfStock = p['stock'] == 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    p['image'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (outOfStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Out of Stock',
                        style:
                        TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),

                if (p['discount'] != null) ...[
                  Text(
                    "₹${p['price']}",
                    style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 12),
                  ),
                  Text(
                    "₹${p['discount']}",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ] else
                  Text(
                    "₹${p['price']}",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),

                const SizedBox(height: 4),
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

  /// ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// STORE FILTER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 0, 10),
            child: const Text(
              'Filter by Store',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(
            height: 46,
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
                ? const Center(child: Text('No products found'))
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
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
