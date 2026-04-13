import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:molafzo_vendor/screens/stores/screens/add_store_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/api_service.dart';
import '../../stores/screens/store_detail_screen.dart';
class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  bool loading = true;
  List<StoreModel> stores = [];

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token == null) {
      setState(() => loading = false);
      return;
    }

    final res = await ApiService.get(
      endpoint: '/vendor/store/list',
      token: token,
    );

    if (res['success'] == true) {
      stores = (res['data'] as List)
          .map((e) => StoreModel.fromJson(e))
          .toList();
    } else {
      stores = [];
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Store Management"),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: fetchStores,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InkWell(
                onTap: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddStoreScreen()),
                  );
                  // final prefs = await SharedPreferences.getInstance();
                  // final userJson = prefs.getString('user'); // Get the saved JSON string
                  // if (userJson != null) {
                  //   final userData = jsonDecode(userJson); // Convert JSON string to Map
                  //   final userId = userData['status_id']; // or 'user_id' depending on what you saved
                  //   print(userId);
                  // } else {
                  //   print('No user data found');
                  // }

                },
                child: _addStoreBtn(scheme),
              ),
              const SizedBox(height: 20),

              if (loading)
                const Center(child: CircularProgressIndicator()),

              if (!loading && stores.isEmpty)
                const Center(child: Text("No stores found")),

              if (!loading)
                ...stores.map(
                      (store) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StoreCard(store: store),
                  ),
                ),
              SizedBox(height: 50,)
            ],
          ),
        ),
      ),
    );
  }

  Widget _addStoreBtn(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_business, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            'Add New Store',
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
class _StoreCard extends StatelessWidget {
  final StoreModel store;

  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.store, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _statusChip(store.isActive),
                        const SizedBox(width: 8),
                        Text(store.typeText),
                      ],
                    )
                  ],
                ),
              ),
              // Edit Button - Pass full store data
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddStoreScreen(
                        storeData: store, // Pass the full store object
                      ),
                    ),
                  );
                  // Refresh list after edit
                  if (result == true) {
                    final storeListScreen = context.findAncestorStateOfType<_StoreListScreenState>();
                    storeListScreen?.fetchStores();
                  }
                },
              ),
              // View Details Button
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StoreDetailScreen(storeId: store.id),
                    ),
                  );
                },
              )
            ],
          ),
          const Divider(height: 20),
          _InfoRow(label: 'Email', value: store.email.isNotEmpty ? store.email : 'Not provided'),
          _InfoRow(label: 'Phone', value: store.mobile),
          _InfoRow(label: 'Address', value: store.fullAddress),
          _InfoRow(label: 'Hours', value: store.workingHours),
        ],
      ),
    );
  }

  Widget _statusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        active ? 'Active' : 'Pending',
        style: TextStyle(
          fontSize: 11,
          color: active ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class StoreModel {
  final int id;
  final String name;
  final String mobile;
  final String email;
  final String address;
  final String city;
  final String country;
  final List<int> types;
  final int statusId;
  final String workingHours;
  final int deliveryBySeller;
  final int selfPickup;
  final String? description;
  final String? logo;
  final String? storeBackgroundImage;
  final String? backgroundColor;
  final List<Map<String, dynamic>>? socialLinks;
  final Map<String, dynamic>? deliveryPolicy;
  final Map<String, dynamic>? returnPolicy;
  final String? deliveryDays;
  final String? landmark;

  StoreModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.address,
    required this.city,
    required this.country,
    required this.types,
    required this.statusId,
    required this.workingHours,
    required this.deliveryBySeller,
    required this.selfPickup,
    this.description,
    this.logo,
    this.storeBackgroundImage,
    this.backgroundColor,
    this.socialLinks,
    this.deliveryPolicy,
    this.returnPolicy,
    this.deliveryDays,
    this.landmark,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    // Parse types
    List<int> parsedTypes = [];
    if (json['type'] != null) {
      try {
        if (json['type'] is String) {
          final typeString = json['type'];
          final cleaned = typeString.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
          if (cleaned.isNotEmpty) {
            parsedTypes = cleaned.split(',').map((e) => int.parse(e.trim())).toList();
          }
        } else if (json['type'] is List) {
          parsedTypes = (json['type'] as List).map((e) => int.parse(e.toString())).toList();
        } else if (json['type'] is int) {
          parsedTypes = [json['type'] as int];
        }
      } catch (e) {
        parsedTypes = [];
      }
    }

    // Parse address to separate address and landmark if needed
    String fullAddress = json['address'] ?? '';
    String address = fullAddress;
    String landmark = '';

    // If address has comma, split into address and landmark
    if (fullAddress.contains(',') && !fullAddress.contains('http')) {
      final parts = fullAddress.split(',');
      address = parts[0].trim();
      if (parts.length > 1) {
        landmark = parts.sublist(1).join(',').trim();
      }
    }

    return StoreModel(
      id: json['id'],
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      address: address,
      landmark: landmark,
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      types: parsedTypes,
      statusId: json['status_id'] ?? 0,
      workingHours: json['working_hours'] ?? '',
      deliveryBySeller: json['delivery_by_seller'] ?? 0,
      selfPickup: json['self_pickup'] ?? 0,
      description: json['description'],
      logo: json['logo'],
      storeBackgroundImage: json['store_background_image'],
      backgroundColor: json['background_color'],
      socialLinks: json['social_links'] is List
          ? List<Map<String, dynamic>>.from(json['social_links'])
          : null,
      deliveryPolicy: json['delivery_policy'] is Map
          ? Map<String, dynamic>.from(json['delivery_policy'])
          : null,
      returnPolicy: json['return_policy'] is Map
          ? Map<String, dynamic>.from(json['return_policy'])
          : null,
      deliveryDays: json['delivery_days'],
    );
  }

  bool get isActive => statusId == 1;

  String get typeText {
    if (types.isEmpty) return 'Other';
    List<String> typeNames = [];
    for (var type in types) {
      switch (type) {
        case 1:
          typeNames.add('Retail');
          break;
        case 2:
          typeNames.add('Online');
          break;
        case 3:
          typeNames.add('Wholesale');
          break;
        case 4:
          typeNames.add('Offline');
          break;
        default:
          typeNames.add('Other');
      }
    }
    return typeNames.join(', ');
  }

  String get fullAddress {
    if (landmark != null && landmark!.isNotEmpty) {
      return '$address, $landmark';
    }
    return address;
  }
}