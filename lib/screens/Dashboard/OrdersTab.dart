// import 'dart:convert';
// import 'dart:ffi';
// import 'package:flutter/material.dart';
// import 'package:molafzo_vendor/screens/addproduct/AddProductScreen.dart';
// import 'package:molafzo_vendor/screens/orders/screens/order_detail_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../widgets/profile_not_eligible_widget.dart';
// import '../orders/model/order_model.dart';
// import '../products/screens/add_product_basic_info.dart';
// import '../orders/controller/order_controller.dart';
//
// class OrderListScreen extends StatefulWidget {
//   const OrderListScreen({super.key});
//
//   @override
//   State<OrderListScreen> createState() => _OrderListScreenState();
// }
//
// class _OrderListScreenState extends State<OrderListScreen> {
//   int selectedIndex = 0;
//   List<Order> orders = [];
//   bool isLoading = false;
//   String? errorMessage;
//
//   String username = 'User';
//   String profilestatus = '';
//   String email = '';
//
//   final api = OrderApiService();
//
//   final filters = [
//     'New Order',
//     'Awaiting Pickup',
//     'Completed',
//     'Cancelled',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     fetechuserdata().then((_) {
//       if (profilestatus == '1') {
//         loadOrders();
//       }
//     });
//   }
//
//   Future<void> fetechuserdata() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userJson = prefs.getString('user');
//
//     if (userJson != null) {
//       final userData = jsonDecode(userJson);
//       setState(() {
//         username = userData['name'] ?? 'User';
//         email = userData['email'] ?? '';
//         profilestatus = userData['status_id']?.toString() ?? '';
//       });
//     }
//   }
//
//   Future<void> loadOrders() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//       orders.clear();
//     });
//
//     try {
//       final statusId = selectedIndex + 1; // ✅ FIXED
//       orders = await api.fetchOrders(statusId);
//     } catch (e) {
//       errorMessage = e.toString();
//     }
//
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   bool get _isProfileIncomplete => email.isEmpty;
//
//   void _showTopToast(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.black87,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Orders'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           const SizedBox(width: 12),
//         ],
//       ),
//       body: (profilestatus != '1')
//           ? ProfileNotEligibleWidget(
//         title: _isProfileIncomplete
//             ? "Profile incomplete"
//             : profilestatus == '2'
//             ? "Profile under review"
//             : "Access restricted",
//         subtitle: _isProfileIncomplete
//             ? "Complete your profile to access orders."
//             : profilestatus == '2'
//             ? "Please wait for admin approval."
//             : "You cannot access this section.",
//       )
//           : Column(
//         children: [
//           /// FILTER TABS
//           SizedBox(
//             height: 35,
//             child: ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               scrollDirection: Axis.horizontal,
//               itemCount: filters.length,
//               separatorBuilder: (_, __) => const SizedBox(width: 8),
//               itemBuilder: (context, index) {
//                 final isActive = index == selectedIndex;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() => selectedIndex = index);
//                     loadOrders();
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: isActive ? Colors.black : Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: isActive
//                             ? Colors.black
//                             : Colors.grey.shade300,
//                       ),
//                     ),
//                     child: Text(
//                       filters[index],
//                       style: TextStyle(
//                         fontSize: 13,
//                         color:
//                         isActive ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           /// CONTENT
//           Expanded(
//             child: Builder(
//               builder: (_) {
//                 if (isLoading) {
//                   return const Center(
//                       child: CircularProgressIndicator());
//                 }
//
//                 if (errorMessage != null) {
//                   return Center(child: Text(errorMessage!));
//                 }
//
//                 if (orders.isEmpty) {
//                   return const Center(
//                     child:   Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.inbox, size: 60, color: Colors.grey),
//                           const SizedBox(height: 12),
//                           const Text(
//                             "No orders yet",
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             "New orders will appear here",
//                             style: TextStyle(color: Colors.grey),
//                           ),
//                         ],
//                       )
//
//                   );
//                 }
//
//                 return ListView.builder(
//                   itemCount: orders.length,
//                   // separatorBuilder: (_, __) => nullptr,
//                   itemBuilder: (context, index) {
//                     final order = orders[index];
//                     return _OrderTile(
//                       orderId: "#${order.id}",
//                       date: order.createdAt,
//                       items: "${order.items.length} items",
//                       onTap: ()async {
//                         final result = await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => OrderDetailScreen(order: order),
//                           ),
//                         );
//
//                         if (result == true) {
//                           loadOrders();
//                           // setState(() {
//                           //   fetechuserdata(); // 🔁 reload orders
//                           // });
//                         }
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// ---------------- ORDER TILE ----------------
//
// class _OrderTile extends StatelessWidget {
//   final String orderId;
//   final String date;
//   final String items;
//   final VoidCallback onTap;
//
//   const _OrderTile({
//     required this.orderId,
//     required this.date,
//     required this.items,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               )
//             ],
//           ),
//           child: Row(
//             children: [
//               /// LEFT STATUS DOT
//               Container(
//                 height: 10,
//                 width: 10,
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 10),
//
//               /// DETAILS
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Order #$orderId',
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       date,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               /// ITEMS COUNT
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   items,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//
//               const SizedBox(width: 8),
//               const Icon(Icons.chevron_right, color: Colors.black54),
//             ],
//           ),
//         )
//
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:molafzo_vendor/screens/orders/screens/order_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/profile_not_eligible_widget.dart';
import '../orders/controller/order_controller.dart';
import '../orders/model/order_model.dart';


class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  int selectedIndex = 0;
  List<Order> orders = [];
  bool isLoading = false;
  String? errorMessage;

  String username = 'User';
  String profilestatus = '';
  String email = '';

  final api = OrderApiService();

  // Updated filters - Only 3 filters
  final filters = [
    'All',
    'Completed',
    'Cancelled',
  ];

  // Map filter name to status IDs
  List<int> _getStatusIdsForFilter(String filter) {
    switch (filter) {
      case 'All':
        return [1, 2]; // New Order + Awaiting Pickup
      case 'Completed':
        return [3];
      case 'Cancelled':
        return [4];
      default:
        return [1, 2];
    }
  }

  // Get status color based on status ID
  Color _getStatusColor(int statusId) {
    switch (statusId) {
      case 1:
        return Colors.orange; // New Order
      case 2:
        return Colors.blue; // Awaiting Pickup
      case 3:
        return Colors.green; // Completed
      case 4:
        return Colors.red; // Cancelled
      default:
        return Colors.grey;
    }
  }

  // Get status text based on status ID
  String _getStatusText(int statusId) {
    switch (statusId) {
      case 1:
        return 'New';
      case 2:
        return 'Pickup';
      case 3:
        return 'Completed';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData().then((_) {
      if (profilestatus == '1') {
        loadOrders();
      }
    });
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson != null) {
      final userData = jsonDecode(userJson);
      setState(() {
        username = userData['name'] ?? 'User';
        email = userData['email'] ?? '';
        profilestatus = userData['status_id']?.toString() ?? '';
      });
    }
  }

  Future<void> loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      orders.clear();
    });

    try {
      final currentFilter = filters[selectedIndex];
      final statusIds = _getStatusIdsForFilter(currentFilter);

      // Fetch orders for each status ID and combine them
      List<Order> allOrders = [];

      for (var statusId in statusIds) {
        final fetchedOrders = await api.fetchOrders(statusId);
        allOrders.addAll(fetchedOrders);
      }

      // Sort orders by date (newest first)
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        orders = allOrders;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool get _isProfileIncomplete => email.isEmpty;

  String _formatDate(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: const [
          SizedBox(width: 12),
        ],
      ),
      body: (profilestatus != '1')
          ? ProfileNotEligibleWidget(
        title: _isProfileIncomplete
            ? "Profile incomplete"
            : profilestatus == '2'
            ? "Profile under review"
            : "Access restricted",
        subtitle: _isProfileIncomplete
            ? "Complete your profile to access orders."
            : profilestatus == '2'
            ? "Please wait for admin approval."
            : "You cannot access this section.",
      )
          : Column(
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
                    if (selectedIndex != index) {
                      setState(() {
                        selectedIndex = index;
                      });
                      loadOrders();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
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
                        color: isActive ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          /// CONTENT
          Expanded(
            child: Builder(
              builder: (_) {
                if (isLoading) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (errorMessage != null) {
                  return Center(child: Text(errorMessage!));
                }

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          "No orders yet",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          filters[selectedIndex] == 'All'
                              ? "New orders will appear here"
                              : "No ${filters[selectedIndex].toLowerCase()} orders",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _OrderTile(
                      orderId: "#${order.id}",
                      date: _formatDate(order.createdAt),
                      items: "${order.items.length} items",
                      statusId: order.statusId,
                      statusColor: _getStatusColor(order.statusId),
                      statusText: _getStatusText(order.statusId),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OrderDetailScreen(order: order),
                          ),
                        );

                        if (result == true) {
                          loadOrders();
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- ORDER TILE WITH STATUS COLOR ----------------
class _OrderTile extends StatelessWidget {
  final String orderId;
  final String date;
  final String items;
  final int statusId;
  final Color statusColor;
  final String statusText;
  final VoidCallback onTap;

  const _OrderTile({
    required this.orderId,
    required this.date,
    required this.items,
    required this.statusId,
    required this.statusColor,
    required this.statusText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              /// LEFT STATUS DOT with color based on order status
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              /// DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Order $orderId',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              /// ITEMS COUNT
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  items,
                  style: const TextStyle(fontSize: 12),
                ),
              ),

              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}