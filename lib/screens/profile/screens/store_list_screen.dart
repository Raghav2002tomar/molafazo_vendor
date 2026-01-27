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
          _InfoRow(label: 'Email', value: store.email),
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
        color: active ? Colors.green.shade50 : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        active ? 'Active' : 'Pending',
        style: TextStyle(
          fontSize: 11,
          color: active ? Colors.green : Colors.white,
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
  final String email;
  final String mobile;
  final String address;
  final String city;
  final String country;
  final int type;
  final int statusId;
  final String workingHours;

  StoreModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.city,
    required this.country,
    required this.type,
    required this.statusId,
    required this.workingHours,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      type: json['type'] ?? 0,
      statusId: json['status_id'] ?? 0,
      workingHours: json['working_hours'] ?? '',
    );
  }

  /// UI Helpers
  bool get isActive => statusId == 1;

  String get typeText {
    switch (type) {
      case 1:
        return 'Retail';
      case 2:
        return 'Wholesale';
      default:
        return 'Other';
    }
  }

  String get fullAddress => '$address, $city, $country';
}
