import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/profile_not_eligible_widget.dart';
import '../orders/screens/order_detail_screen.dart';
import '../products/screens/add_product_basic_info.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  int selectedIndex = 1;

  String username = 'User';
  String profilestatus = '';
  String email = '';

  bool get _isProfileIncomplete {
    // Simple check based on profilestatus
    return email.isEmpty || email == null;
  }

  String get _profileStatusMessage {
    if (_isProfileIncomplete) {
      return "Complete your profile";
    } else if (profilestatus == '2') {
      return "Profile under review";
    } else if (profilestatus == '1') {
      return "Profile approved ✓";
    }
    return "";
  }

  Color get _profileStatusColor {
    if (_isProfileIncomplete) return Colors.red;
    if (profilestatus == '2') return Colors.orange;
    if (profilestatus == '1') return Colors.green;
    return Colors.grey;
  }


  @override
  void initState() {
    // TODO: implement initState
    fetechuserdata();
    super.initState();
  }

  Future<void> fetechuserdata() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user'); // Get the saved JSON string
    if (userJson != null) {
      final userData = jsonDecode(userJson); // Convert JSON string to Map
      setState(() {
        username = userData['name'] ?? 'User';
        username = userData['email'] ?? '';
        profilestatus = userData['status_id']?.toString() ?? '';
      });
      print("✅ User loaded: $username, status: $profilestatus");
    } else {
      // Fallback default values
      setState(() {
        username = 'User';
        profilestatus = '';
      });
    }
  }
  void _showTopToast(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  final filters = [
    'All',
    'New Order',
    'Awaiting Pickup',
    'In Transit',
    'Completed',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Orders'),
        // centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          InkWell(onTap: (){
            // Check profile status before navigating
            if (profilestatus == '1') {
              // Profile approved ✅
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductBasicInfo()),
              );
            }else if (email.isEmpty || email == null) {
              // Profile incomplete 🔴
              _showTopToast(context, "Complete your profile to add products.");
            }
            else if (profilestatus == '2') {
              // Profile under review 🟠
              _showTopToast(context, "Your profile is under review. Please wait for approval.");
            }
          },
            child: Container(decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(8)
            ), child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                children: [
                  Icon(Icons.add),

                ],
              ),
            ),),
          ),
          SizedBox(width: 16,)
        ],
      ),
        body: (profilestatus != '1')
        ? ProfileNotEligibleWidget(
      title: email.isEmpty || email == null
          ? "Profile incomplete"
          : profilestatus == '2'
          ? "Profile under review"
          : "Access restricted",
      subtitle: email.isEmpty || email == null
          ? "Complete your profile to access products."
          : profilestatus == '2'
          ? "Your profile is under review. Please wait for approval."
          : "Your profile cannot access this section.",
      onUpdateTap: (email.isEmpty || email == null)
          ? () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => EditProfileScreen(),
        //   ),
        // );
      }
          : null, // ❌ Hide button if under review
    )

          :

      Column(
        children: [
          /// FILTER TABS
          SizedBox(
            height: 35,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isActive = index == selectedIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive
                            ? Colors.black
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          /// ORDER LIST
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              separatorBuilder: (_, __) =>
                  Divider(color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                return _OrderTile(
                  orderId: '#212323',
                  date: 'Today | 9:00 am',
                  items: '3 items',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- ORDER TILE ----------------

class _OrderTile extends StatelessWidget {
  final String orderId;
  final String date;
  final String items;

  const _OrderTile({
    required this.orderId,
    required this.date,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            /// LEFT INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID $orderId',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
      
            /// RIGHT INFO
            Text(
              items,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.green,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
