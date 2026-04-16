//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:molafzo_vendor/screens/orders/screens/order_detail_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../widgets/profile_not_eligible_widget.dart';
// import '../orders/controller/order_controller.dart';
// import '../orders/model/order_model.dart';
//
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
//   // Updated filters - Only 3 filters
//   final filters = [
//     'All',
//     'Completed',
//     'Cancelled',
//   ];
//
//   // Map filter name to status IDs
//   List<int> _getStatusIdsForFilter(String filter) {
//     switch (filter) {
//       case 'All':
//         return [1, 2]; // New Order + Awaiting Pickup
//       case 'Completed':
//         return [3];
//       case 'Cancelled':
//         return [4];
//       default:
//         return [1, 2];
//     }
//   }
//
//   // Get status color based on status ID
//   Color _getStatusColor(int statusId) {
//     switch (statusId) {
//       case 1:
//         return Colors.orange; // New Order
//       case 2:
//         return Colors.blue; // Awaiting Pickup
//       case 3:
//         return Colors.green; // Completed
//       case 4:
//         return Colors.red; // Cancelled
//       default:
//         return Colors.grey;
//     }
//   }
//
//   // Get status text based on status ID
//   String _getStatusText(int statusId) {
//     switch (statusId) {
//       case 1:
//         return 'New';
//       case 2:
//         return 'Pickup';
//       case 3:
//         return 'Completed';
//       case 4:
//         return 'Cancelled';
//       default:
//         return 'Unknown';
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserData().then((_) {
//       if (profilestatus == '1') {
//         loadOrders();
//       }
//     });
//   }
//
//   Future<void> fetchUserData() async {
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
//       final currentFilter = filters[selectedIndex];
//       final statusIds = _getStatusIdsForFilter(currentFilter);
//
//       // Fetch orders for each status ID and combine them
//       List<Order> allOrders = [];
//
//       for (var statusId in statusIds) {
//         final fetchedOrders = await api.fetchOrders(statusId);
//         allOrders.addAll(fetchedOrders);
//       }
//
//       // Sort orders by date (newest first)
//       allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//
//       setState(() {
//         orders = allOrders;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   bool get _isProfileIncomplete => email.isEmpty;
//
//   String _formatDate(String dateTimeStr) {
//     try {
//       final dateTime = DateTime.parse(dateTimeStr);
//       final now = DateTime.now();
//       final difference = now.difference(dateTime);
//
//       if (difference.inDays > 0) {
//         return '${difference.inDays}d ago';
//       } else if (difference.inHours > 0) {
//         return '${difference.inHours}h ago';
//       } else if (difference.inMinutes > 0) {
//         return '${difference.inMinutes}m ago';
//       } else {
//         return 'Just now';
//       }
//     } catch (e) {
//       return dateTimeStr;
//     }
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
//         actions: const [
//           SizedBox(width: 12),
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
//                     if (selectedIndex != index) {
//                       setState(() {
//                         selectedIndex = index;
//                       });
//                       loadOrders();
//                     }
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
//                         color: isActive ? Colors.white : Colors.black87,
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
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.inbox,
//                             size: 60, color: Colors.grey),
//                         const SizedBox(height: 12),
//                         const Text(
//                           "No orders yet",
//                           style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           filters[selectedIndex] == 'All'
//                               ? "New orders will appear here"
//                               : "No ${filters[selectedIndex].toLowerCase()} orders",
//                           style: const TextStyle(color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   itemCount: orders.length,
//                   itemBuilder: (context, index) {
//                     final order = orders[index];
//                     return _OrderTile(
//                       orderId: "#${order.id}",
//                       date: _formatDate(order.createdAt),
//                       items: "${order.items.length} items",
//                       statusId: order.statusId,
//                       statusColor: _getStatusColor(order.statusId),
//                       statusText: _getStatusText(order.statusId),
//                       onTap: () async {
//                         final result = await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 OrderDetailScreen(order: order),
//                           ),
//                         );
//
//                         if (result == true) {
//                           loadOrders();
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
// /// ---------------- ORDER TILE WITH STATUS COLOR ----------------
// class _OrderTile extends StatelessWidget {
//   final String orderId;
//   final String date;
//   final String items;
//   final int statusId;
//   final Color statusColor;
//   final String statusText;
//   final VoidCallback onTap;
//
//   const _OrderTile({
//     required this.orderId,
//     required this.date,
//     required this.items,
//     required this.statusId,
//     required this.statusColor,
//     required this.statusText,
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
//               /// LEFT STATUS DOT with color based on order status
//               Container(
//                 height: 10,
//                 width: 10,
//                 decoration: BoxDecoration(
//                   color: statusColor,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: statusColor.withOpacity(0.3),
//                       blurRadius: 4,
//                       spreadRadius: 1,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 10),
//
//               /// DETAILS
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           'Order $orderId',
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         // Status badge
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: statusColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: statusColor.withOpacity(0.3),
//                               width: 0.5,
//                             ),
//                           ),
//                           child: Text(
//                             statusText,
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                               color: statusColor,
//                             ),
//                           ),
//                         ),
//                       ],
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
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:molafzo_vendor/extensions/context_extension.dart';
import 'package:molafzo_vendor/screens/orders/screens/order_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/profile_not_eligible_widget.dart';
import '../../providers/translate_provider.dart';
import '../orders/controller/order_controller.dart';
import '../orders/model/order_model.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  bool isLoading = false;
  String? errorMessage;

  String username = 'User';
  String profilestatus = '';
  String email = '';

  final api = OrderApiService();

  // Filter options
  final List<FilterOption> filterOptions = [
    FilterOption('All', 'All Orders', 'Show all orders', [1, 2, 3, 4]),
    FilterOption('Pending', 'Pending Orders', 'New & Awaiting Pickup', [1, 2]),
    FilterOption('Completed', 'Completed Orders', 'Delivered orders', [3]),
    FilterOption('Cancelled', 'Cancelled Orders', 'Cancelled orders', [4]),
  ];

  String currentFilter = 'All';

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
        return context.tr('new_order');
      case 2:
        return context.tr('pickup');
      case 3:
        return context.tr('completed');
      case 4:
        return context.tr('cancelled');
      default:
        return context.tr('unknown');
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
      // Fetch all orders (status IDs 1-4)
      List<Order> allOrders = [];

      for (var statusId = 1; statusId <= 4; statusId++) {
        final fetchedOrders = await api.fetchOrders(statusId);
        allOrders.addAll(fetchedOrders);
      }

      // Sort orders by date (newest first)
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        orders = allOrders;
        _applyFilter(); // Apply current filter
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

  void _applyFilter() {
    final selectedFilter = filterOptions.firstWhere(
          (filter) => filter.id == currentFilter,
      orElse: () => filterOptions[0],
    );

    setState(() {
      filteredOrders = orders.where((order) {
        return selectedFilter.statusIds.contains(order.statusId);
      }).toList();
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    context.tr('filter_orders'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...filterOptions.map((filter) {
                    final isSelected = currentFilter == filter.id;
                    return Column(
                      children: [
                        ListTile(
                          leading: Radio<String>(
                            value: filter.id,
                            groupValue: currentFilter,
                            onChanged: (value) {
                              setStateBottomSheet(() {
                                currentFilter = value!;
                              });
                              // Wait a bit to show selection then close
                              Future.delayed(const Duration(milliseconds: 300), () {
                                Navigator.pop(context);
                                _applyFilter();
                              });
                            },
                            activeColor: Colors.black,
                          ),
                          title: Text(
                            filter.displayName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(filter.description),
                          onTap: () {
                            setStateBottomSheet(() {
                              currentFilter = filter.id;
                            });
                            Future.delayed(const Duration(milliseconds: 300), () {
                              Navigator.pop(context);
                              _applyFilter();
                            });
                          },
                        ),
                        if (filter != filterOptions.last)
                          const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                      child: Text(context.tr('cancel')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
        title: Text(context.tr('orders')),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Filter button - Fixed version without Badge widget
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
                color: currentFilter != 'All' ? Colors.black : Colors.black54,
              ),
              if (currentFilter != 'All')
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: (profilestatus != '1')
          ? ProfileNotEligibleWidget(
        title: _isProfileIncomplete
            ? context.tr('profile_incomplete')
            : profilestatus == '2'
            ? context.tr('profile_under_review')
            : context.tr('access_restricted'),
        subtitle: _isProfileIncomplete
            ? context.tr('complete_profile_access_orders')
            : profilestatus == '2'
            ? context.tr('wait_admin_approval')
            : context.tr('cannot_access_section'),
      )
          : Column(
        children: [
          // Optional: Show active filter chip
          if (currentFilter != 'All') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    context.tr('active_filter'),
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_alt, size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          filterOptions.firstWhere((f) => f.id == currentFilter).displayName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              currentFilter = 'All';
                              _applyFilter();
                            });
                          },
                          child: const Icon(Icons.close, size: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          /// CONTENT
          Expanded(
            child: Builder(
              builder: (_) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (errorMessage != null) {
                  return Center(child: Text(errorMessage!));
                }

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                         Text(
                          context.tr('no_orders_found'),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentFilter == 'All'
                              ? context.tr('new_orders_appear_here')
                              : "No ${currentFilter.toLowerCase()} ${context.tr('txt_orders')}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (currentFilter != 'All') ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                currentFilter = 'All';
                                _applyFilter();
                              });
                            },
                            icon: const Icon(Icons.clear_all),
                            label: Text(context.tr('clear_filter')),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _OrderTile(
                      orderId: "#${order.id}",
                      date: _formatDate(order.createdAt),
                      items: "${order.items.length} ${context.tr('items')}",
                      statusId: order.statusId,
                      statusColor: _getStatusColor(order.statusId),
                      statusText: _getStatusText(order.statusId),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(order: order),
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

/// Filter Option Model
class FilterOption {
  final String id;
  final String displayName;
  final String description;
  final List<int> statusIds;

  const FilterOption(
      this.id,
      this.displayName,
      this.description,
      this.statusIds,
      );
}

/// ORDER TILE WITH STATUS COLOR
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
                          '${context.tr('order')} $orderId',
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