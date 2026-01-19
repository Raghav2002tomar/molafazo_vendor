import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:molafzo_vendor/screens/stores/screens/add_store_screen.dart';

class StoreDetailScreen extends StatelessWidget {
  const StoreDetailScreen({super.key});

  // 🔹 STATIC STORE DATA
  Map<String, dynamic> get store => {
    'name': 'TechWorld Electronics',
    'mobile': '+91 98765 99999',
    'email': 'techworld@store.com',
    'address': 'Sector 17, Chandigarh',
    'type': 'Retail',
    'description':
    'TechWorld Electronics is a premium electronics retail store offering mobiles, laptops and accessories.',
    'images': [
      'https://images.unsplash.com/photo-1580910051074-7c7e5d9f6e6f',
      'https://images.unsplash.com/photo-1607082352121-fa243f3dde32',
      'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d',
    ],
    'proof':
    'https://images.unsplash.com/photo-1586953208448-b95a79798f07',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Store Details'),
        backgroundColor: Colors.white,
        actions: [InkWell(onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddStoreScreen()));
        }, child: SvgPicture.asset("assets/images/edit.svg")),SizedBox(width: 12,)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= STORE NAME =================
            Text(
              store['name'],
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            Chip(
              label: Text(
                store['type'],
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: theme.colorScheme.primary,
            ),

            const SizedBox(height: 16),

            // ================= BASIC INFO =================
            _card(children: [
              _row('Mobile', store['mobile']),
              _row('Email', store['email']),
              _row('Address', store['address']),
            ]),

            const SizedBox(height: 16),

            // ================= STORE IMAGES =================
            _sectionTitle('Store Images'),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: store['images'].length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (_, i) => _networkImage(
                store['images'][i],
                radius: 12,
              ),
            ),

            const SizedBox(height: 16),

            // ================= STORE PROOF =================
            _sectionTitle('Store Proof'),
            const SizedBox(height: 8),
            _networkImage(
              store['proof'],
              height: 180,
              radius: 12,
            ),

            const SizedBox(height: 16),

            // ================= DESCRIPTION =================
            _sectionTitle('Store Description'),
            _card(
              children: [
                Text(
                  store['description'],
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================


   _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _card(
      {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
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
          children: children),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 13, color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= NETWORK IMAGE WITH LOADER + ERROR =================
  Widget _networkImage(
      String url, {
        double? height,
        double radius = 10,
      }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height ?? 110,
            color: Colors.grey.shade100,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (_, __, ___) {
          return Container(
            height: height ?? 110,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.broken_image, size: 40, color: Colors.grey),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
