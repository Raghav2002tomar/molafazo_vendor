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

  // Store type mapping
  final List<Map<String, dynamic>> storeTypes = [
    {'label': 'Retail', 'value': '1'},
    {'label': 'Online', 'value': '2'},
    {'label': 'Wholesale', 'value': '3'},
    {'label': 'Offline', 'value': '4'},
  ];

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

    if (res['success'] == true) {
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

  // ================= PARSE STORE TYPES =================
  List<String> getStoreTypeLabels() {
    final typeData = store?['type'];
    if (typeData == null) return [];

    List<String> typeValues = [];

    try {
      // Case 1: It's a string like "[\"1\", \"2\"]"
      if (typeData is String) {
        // Remove brackets and quotes
        final cleaned = typeData.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
        if (cleaned.isNotEmpty) {
          typeValues = cleaned.split(',').map((e) => e.trim()).toList();
        }
      }
      // Case 2: It's already a List
      else if (typeData is List) {
        typeValues = typeData.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print("Error parsing store types: $e");
    }

    // Convert type values to labels
    List<String> labels = [];
    for (var value in typeValues) {
      final match = storeTypes.firstWhere(
            (type) => type['value'] == value,
        orElse: () => {'label': 'Unknown'},
      );
      labels.add(match['label']);
    }

    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeTypes = getStoreTypeLabels();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Store Details'),
        backgroundColor: Colors.white,
        actions: [
          // InkWell(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => AddStoreScreen()),
          //     );
          //   },
          //   child: SvgPicture.asset("assets/images/edit.svg"),
          // ),
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

            // ================= STORE TYPES (Multiple Chips) =================
            if (storeTypes.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: storeTypes.map((type) {
                  return Chip(
                    label: Text(
                      type,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),
            ],

            // ================= STATUS =================
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
                  _networkImage(store?['logo'], height: 180, type: "logo"),
                  const SizedBox(height: 16),
                ],
              ),

            const SizedBox(height: 16),

            // ================= STORE BACKGROUND =================
            _sectionTitle('Store Background'),
            const SizedBox(height: 8),
            _networkImage(store?['store_background_image'], height: 180, radius: 12, type: "background_image"),

            const SizedBox(height: 16),

            // ================= DESCRIPTION =================
            _sectionTitle('Store Description'),
            _card(children: [
              Text(
                _text('description'),
                style: const TextStyle(fontSize: 14),
              ),
            ]),
            const SizedBox(height: 50),
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
        String? type,
      }) {
    if (url == null || url.isEmpty) {
      return _imagePlaceholder(height, radius);
    }

    String basePath;
    if (type == "logo") {
      basePath = ApiService.store_logo_URL;
    } else if (type == "background_image") {
      basePath = ApiService.store_background_URL; // Adjust if needed
    } else {
      basePath = ApiService.store_logo_URL;
    }

    final imageUrl = url.startsWith('http') ? url : '${ApiService.ImagebaseUrl}$basePath$url';

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