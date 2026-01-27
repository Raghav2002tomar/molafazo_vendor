// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:molafzo_vendor/screens/stores/screens/add_store_screen.dart';
//
// class StoreDetailScreen extends StatelessWidget {
//   const StoreDetailScreen({super.key});
//
//   // 🔹 STATIC STORE DATA
//   Map<String, dynamic> get store => {
//     'name': 'TechWorld Electronics',
//     'mobile': '+91 98765 99999',
//     'email': 'techworld@store.com',
//     'address': 'Sector 17, Chandigarh',
//     'type': 'Retail',
//     'description':
//     'TechWorld Electronics is a premium electronics retail store offering mobiles, laptops and accessories.',
//     'images': [
//       'https://images.unsplash.com/photo-1580910051074-7c7e5d9f6e6f',
//       'https://images.unsplash.com/photo-1607082352121-fa243f3dde32',
//       'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d',
//     ],
//     'proof':
//     'https://images.unsplash.com/photo-1586953208448-b95a79798f07',
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Store Details'),
//         backgroundColor: Colors.white,
//         actions: [InkWell(onTap: (){
//           Navigator.push(context, MaterialPageRoute(builder: (context)=>AddStoreScreen()));
//         }, child: SvgPicture.asset("assets/images/edit.svg")),SizedBox(width: 12,)],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//             // ================= STORE NAME =================
//             Text(
//               store['name'],
//               style: theme.textTheme.titleLarge
//                   ?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 6),
//
//             Chip(
//               label: Text(
//                 store['type'],
//                 style: const TextStyle(color: Colors.white),
//               ),
//               backgroundColor: theme.colorScheme.primary,
//             ),
//
//             const SizedBox(height: 16),
//
//             // ================= BASIC INFO =================
//             _card(children: [
//               _row('Mobile', store['mobile']),
//               _row('Email', store['email']),
//               _row('Address', store['address']),
//             ]),
//
//             const SizedBox(height: 16),
//
//             // ================= STORE IMAGES =================
//             _sectionTitle('Store Images'),
//             const SizedBox(height: 8),
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: store['images'].length,
//               gridDelegate:
//               const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemBuilder: (_, i) => _networkImage(
//                 store['images'][i],
//                 radius: 12,
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // ================= STORE PROOF =================
//             _sectionTitle('Store Proof'),
//             const SizedBox(height: 8),
//             _networkImage(
//               store['proof'],
//               height: 180,
//               radius: 12,
//             ),
//
//             const SizedBox(height: 16),
//
//             // ================= DESCRIPTION =================
//             _sectionTitle('Store Description'),
//             _card(
//               children: [
//                 Text(
//                   store['description'],
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ================= UI HELPERS =================
//
//
//    _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   Widget _card(
//       {required List<Widget> children}) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: children),
//     );
//   }
//
//   Widget _row(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style:
//               const TextStyle(fontSize: 13, color: Colors.black54)),
//           Flexible(
//             child: Text(
//               value,
//               textAlign: TextAlign.end,
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// ================= NETWORK IMAGE WITH LOADER + ERROR =================
//   Widget _networkImage(
//       String url, {
//         double? height,
//         double radius = 10,
//       }) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(radius),
//       child: Image.network(
//         url,
//         height: height,
//         width: double.infinity,
//         fit: BoxFit.cover,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Container(
//             height: height ?? 110,
//             color: Colors.grey.shade100,
//             alignment: Alignment.center,
//             child: const CircularProgressIndicator(strokeWidth: 2),
//           );
//         },
//         errorBuilder: (_, __, ___) {
//           return Container(
//             height: height ?? 110,
//             color: Colors.grey.shade200,
//             alignment: Alignment.center,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: const [
//                   Icon(Icons.broken_image, size: 40, color: Colors.grey),
//
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import 'add_store_screen.dart';

class StoreDetailScreen extends StatefulWidget {
  final int storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  bool loading = true;
  Map<String, dynamic>? store;

  @override
  void initState() {
    super.initState();
    fetchStoreDetails();
  }

  Future<void> fetchStoreDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token == null) {
      setState(() => loading = false);
      return;
    }

    final res = await ApiService.get(
      endpoint: '/vendor/store/details/${widget.storeId}',
      token: token,
    );

    print(res); // debug

    if (res['success'] == true ) {
      store = res['data'];
    } else {
      store = null;
    }

    setState(() => loading = false);
  }

  // ================= SAFE GETTER =================
  String _text(String key, {String fallback = '-'}) {
    final v = store?[key];
    if (v == null || v.toString().isEmpty) return fallback;
    return v.toString();
  }

  List<String> _list(String key) {
    final v = store?[key];
    if (v is List) return v.whereType<String>().toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Store Details'),
        backgroundColor: Colors.white,
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddStoreScreen()),
              );
            },
            child: SvgPicture.asset("assets/images/edit.svg"),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : store == null
          ? const Center(child: Text("Store not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= NAME =================
            Text(
              _text('name'),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            Chip(
              label: Text(
                store?['type'].toString() == '1'
                    ? 'Retail'
                    : 'Wholesale',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 6),

            Chip(
              label: Text(
                store?['status_id'].toString() == '1'
                    ? 'Active'
                    : store?['status_id'].toString() == '2'
                    ? 'Pending Approval'
                    : 'Unknown',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: store?['status_id'].toString() == '1'
                  ? Colors.green
                  : store?['status_id'].toString() == '2'
                  ? Colors.red
                  : Colors.grey,
            ),

            const SizedBox(height: 16),

            // ================= BASIC INFO =================
            _card(children: [
              _row('Mobile', _text('mobile')),
              _row('Email', _text('email')),
              _row(
                'Address',
                [
                  store?['address'],
                  store?['city'],
                  store?['country'],
                ]
                    .where((e) => e != null && e.toString().isNotEmpty)
                    .join(', ')
                    .isEmpty
                    ? '-'
                    : [
                  store?['address'],
                  store?['city'],
                  store?['country'],
                ]
                    .where((e) => e != null && e.toString().isNotEmpty)
                    .join(', '),
              ),
              _row('Working Hours', _text('working_hours')),
            ]),

            const SizedBox(height: 16),

            // ================= STORE LOGO =================
            if (store?['logo'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Store Logo'),
                  const SizedBox(height: 8),
                  _networkImage(store?['logo'], height: 180),
                  const SizedBox(height: 16),
                ],
              ),

            // ================= STORE IMAGES =================
            _sectionTitle('Store Images'),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _list('images').isEmpty ? 3 : _list('images').length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (_, i) =>
                  _networkImage(_list('images').isEmpty ? null : _list('images')[i], radius: 12),
            ),

            const SizedBox(height: 16),

            // ================= STORE PROOF =================
            _sectionTitle('Store Proof'),
            const SizedBox(height: 8),
            _networkImage(store?['proof'], height: 180, radius: 12),

            const SizedBox(height: 16),

            // ================= DESCRIPTION =================
            _sectionTitle('Store Description'),
            _card(children: [
              Text(
                _text('description'),
                style: const TextStyle(fontSize: 14),
              ),
            ]),
            SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
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

  /// ================= SAFE NETWORK IMAGE =================
  Widget _networkImage(
      String? url, {
        double? height,
        double radius = 10,
      }) {
    if (url == null || url.isEmpty) {
      return _imagePlaceholder(height, radius);
    }

    final imageUrl = url.startsWith('http') ? url : 'https://trisparksoftwaresolutions.com/$url';

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _imageLoader(height, radius);
        },
        errorBuilder: (_, __, ___) => _imageError(height, radius),
      ),
    );
  }

  Widget _imageLoader(double? h, double r) => Container(
    height: h ?? 110,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(r),
    ),
    child: const CircularProgressIndicator(strokeWidth: 2),
  );

  Widget _imageError(double? h, double r) => Container(
    height: h ?? 110,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(r),
    ),
    child: const Icon(Icons.broken_image, size: 40),
  );

  Widget _imagePlaceholder(double? h, double r) => Container(
    height: h ?? 110,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(r),
    ),
    child: const Icon(Icons.image, size: 40),
  );
}
