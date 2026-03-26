//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:molafzo_vendor/services/api_service.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../chat/screens/chat_detail_screen.dart';
// import '../../chat/screens/chat_service.dart';
// import '../controller/order_controller.dart';
// import '../model/order_model.dart';
//
// class OrderDetailScreen extends StatefulWidget {
//   final Order order;
//
//   const OrderDetailScreen({super.key, required this.order});
//
//   @override
//   State<OrderDetailScreen> createState() => _OrderDetailScreenState();
// }
//
// class _OrderDetailScreenState extends State<OrderDetailScreen> {
//   bool isProcessing = false;
//
//   bool get isNewOrder => widget.order.statusId == 1;
//   bool get awaitingPickup => widget.order.statusId == 2;
//   bool get completed => widget.order.statusId == 3;
//   bool get cancelled => widget.order.statusId == 4;
//
//   Future<void> _updateStatus(int statusId) async {
//     setState(() => isProcessing = true);
//
//     try {
//       await OrderApiService().updateOrderStatus(widget.order.id, statusId);
//       if (mounted) Navigator.pop(context, true); // 🔁 refresh list
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Failed to update order")));
//       }
//     }
//
//     if (mounted) setState(() => isProcessing = false);
//   }
//
//   // Get first product from order items for chat context
//   OrderItem? get _firstProduct {
//     if (widget.order.items.isNotEmpty) {
//       return widget.order.items.first;
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final order = widget.order;
//     final firstProduct = _firstProduct;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         title: const Text(
//           "Order Details",
//           style: TextStyle(color: Colors.black, fontSize: 18),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             /// SCROLLABLE CONTENT
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   children: [
//                     _orderIdCard(order),
//                     const SizedBox(height: 16),
//                     _customerInfo(context, order, firstProduct),
//                     const SizedBox(height: 16),
//                     _orderItems(order),
//                     const SizedBox(height: 16),
//                     _totalRow(order),
//                     const SizedBox(height: 16),
//                     // if (awaitingPickup) ...[
//                     //   const SizedBox(height: 20),
//                       _agentInfo(order, firstProduct),
//                     // ],
//                     const SizedBox(height: 24),
//                   ],
//                 ),
//               ),
//             ),
//
//             /// BOTTOM ACTIONS
//             if (isNewOrder || awaitingPickup)
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 child: isNewOrder
//                     ? _processButtons()
//                     : _completeButton(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _completeButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: isProcessing ? null : () => _updateStatus(3), // 3 = Completed
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.green,
//           padding: const EdgeInsets.symmetric(vertical: 14),
//         ),
//         child: isProcessing
//             ? const CircularProgressIndicator(color: Colors.white)
//             : const Text("Complete Order"),
//       ),
//     );
//   }
//
//   // ================= ORDER ID =================
//
//   Widget _orderIdCard(Order order) {
//     return _card(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: isNewOrder
//                   ? Colors.orange.shade100
//                   : completed
//                   ? Colors.green.shade100
//                   : cancelled
//                   ? Colors.red.shade100
//                   : Colors.blue.shade100,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               _statusText(order.statusId),
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: isNewOrder
//                     ? Colors.orange
//                     : completed
//                     ? Colors.green
//                     : cancelled
//                     ? Colors.red
//                     : Colors.blue,
//               ),
//             ),
//           ),
//           const Spacer(),
//           const Text(
//             "Order ID",
//             style: TextStyle(fontSize: 13, color: Colors.black54),
//           ),
//           const SizedBox(width: 4),
//           Text(
//             "#${order.id}",
//             style: const TextStyle(fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= CUSTOMER INFO =================
//
//   Widget _customerInfo(BuildContext context, Order order, OrderItem? firstProduct) {
//     return _card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle(context, "Customer Information", true, order, firstProduct),
//           const SizedBox(height: 10),
//           _infoRow("Name", order.customer.name),
//           _infoRow("Phone", order.customer.mobile),
//           const SizedBox(height: 12),
//           _sectionTitle(context, "Delivery Address", false, order, null),
//           const SizedBox(height: 8),
//           Text(order.deliveryAddress, style: const TextStyle(fontSize: 13)),
//           const SizedBox(height: 12),
//           _sectionTitle(context, "Payment Mode", false, order, null),
//           const SizedBox(height: 8),
//           Text(order.paymentType, style: const TextStyle(fontSize: 13)),
//         ],
//       ),
//     );
//   }
//
//   // ================= ORDER ITEMS =================
//
//   Widget _orderItems(Order order) {
//     if (order.items.isEmpty) {
//       return _card(
//         child: const Text(
//           "No items found",
//           style: TextStyle(fontSize: 13, color: Colors.black54),
//         ),
//       );
//     }
//
//     return _card(
//       child: Column(
//         children: order.items.map((item) {
//           return Column(
//             children: [
//               _orderItemTile(item),
//               if (item != order.items.last) _divider(),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _orderItemTile(OrderItem item) {
//     final product = item.product;
//     final hasVariant = item.variant != null && item.variant!.isNotEmpty;
//     final variantDisplay = hasVariant ? _getVariantDisplay(item.variant!) : '';
//
//     // Parse prices
//     final double originalPrice = double.tryParse(product.price) ?? 0;
//     final double discountPrice = double.tryParse(product.discountPrice) ?? 0;
//     final bool hasDiscount = discountPrice > 0 && discountPrice < originalPrice;
//
//     // Use item price from variant or product
//     final double displayPrice = double.tryParse(item.price) ?? 0;
//     final double originalItemPrice = double.tryParse(product.price) ?? 0;
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         /// PRODUCT IMAGE
//         Container(
//           height: 60,
//           width: 60,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.grey.shade200,
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: product.primaryImage.isNotEmpty
//               ? Image.network(
//             "${ApiService.ImagebaseUrl}${ApiService.product_images_URL}${product.primaryImage}",
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) =>
//             const Icon(Icons.image_not_supported),
//           )
//               : const Icon(Icons.image),
//         ),
//
//         const SizedBox(width: 12),
//
//         /// PRODUCT DETAILS
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 product.name,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 2),
//
//               /// VARIANT DETAILS
//               if (hasVariant) ...[
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     variantDisplay,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: Colors.grey.shade700,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//               ],
//
//               Text(
//                 "Qty: ${item.quantity}",
//                 style: const TextStyle(fontSize: 12, color: Colors.black54),
//               ),
//               const SizedBox(height: 4),
//
//               /// PRICE SECTION - Show both original and discounted price
//
//             ],
//           ),
//         ),
//
//         /// ITEM TOTAL
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               "c. ${item.total.toStringAsFixed(0)}",
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               "(${item.quantity} item${item.quantity > 1 ? 's' : ''})",
//               style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.grey.shade500,
//               ),
//             ),
//             // Show original total if discounted
//             if (hasDiscount) ...[
//               const SizedBox(height: 2),
//               Text(
//                 "c. ${(originalPrice * item.quantity).toStringAsFixed(0)}",
//                 style: TextStyle(
//                   fontSize: 9,
//                   color: Colors.grey.shade400,
//                   decoration: TextDecoration.lineThrough,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ],
//     );
//   }
//
//
// // Helper method to format variant display
//   String _getVariantDisplay(Map<String, dynamic> variant) {
//     if (variant.isEmpty) return '';
//
//     final List<String> variantParts = [];
//     variant.forEach((key, value) {
//       variantParts.add('$key: $value');
//     });
//
//     return variantParts.join(' • ');
//   }
//
//
//   String _statusText(int statusId) {
//     switch (statusId) {
//       case 1:
//         return "New Order";
//       case 2:
//         return "Awaiting Pickup";
//       case 3:
//         return "Completed";
//       case 4:
//         return "Cancelled";
//       default:
//         return "Unknown";
//     }
//   }
//
//   // ================= TOTAL =================
//
//   Widget _totalRow(Order order) {
//     // Calculate total amount based on item price
//     double totalAmount = 0;
//
//     for (var item in order.items) {
//       final itemPrice = double.tryParse(item.price) ?? 0;
//       totalAmount += itemPrice * item.quantity;
//     }
//
//     return _card(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             "Total",
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 16,
//             ),
//           ),
//           Text(
//             "c. ${totalAmount.toStringAsFixed(0)}",
//             style: const TextStyle(
//               fontWeight: FontWeight.w800,
//               fontSize: 20,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _agentInfo(Order order, OrderItem? firstProduct) {
//     return _card(
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 22,
//             backgroundImage: NetworkImage(
//               "${ApiService.ImagebaseUrl}${ApiService.profile_image_URL}${order.customer.image}",
//             ),
//             child: const Icon(Icons.person),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   order.customer.name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 const Text(
//                   "Contact with chat and call",
//                   style: TextStyle(fontSize: 12, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//           if (firstProduct != null)
//             InkWell(
//               onTap: () async {
//                 final product = firstProduct.product;
//
//                 /// Show loader
//                 if (!context.mounted) return;
//                 showDialog(
//                   context: context,
//                   barrierDismissible: false,
//                   builder: (_) =>
//                   const Center(child: CircularProgressIndicator()),
//                 );
//
//                 try {
//                   /// START CHAT API CALL with product ID
//                   final conversationId = await ChatService.startConversation(
//                     productId: product.id,
//                     otherUserId: order.customer.id,
//                   );
//
//                   if (context.mounted) Navigator.pop(context); // Close loader
//
//                   if (conversationId != null && context.mounted) {
//                     /// OPEN CHAT SCREEN with product info
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ChatDetailScreen(
//                           name: order.customer.name,
//                           image: "${ApiService.ImagebaseUrl}${ApiService.profile_image_URL}${order.customer.image}",
//                           productname: product.name,
//                           productimage: product.primaryImage,
//                           conversationId: conversationId,
//                         ),
//                       ),
//                     );
//                   } else if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Failed to start conversation"),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   if (context.mounted) {
//                     Navigator.pop(context); // Close loader
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text("Error: $e"),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 }
//               },
//               child: SvgPicture.asset(
//                 "assets/images/chat.svg",
//                 height: 26,
//                 color: Colors.green.shade700,
//               ),
//             ),
//           const SizedBox(width: 16),
//           InkWell(
//             onTap: () {
//               _makePhoneCall(order.customer.mobile);
//             },
//             child: Icon(
//               Icons.call,
//               size: 26,
//               color: Colors.green.shade700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ================= BUTTONS =================
//
//   Widget _processButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: isProcessing ? null : () => _updateStatus(4), // Cancel
//             style: OutlinedButton.styleFrom(
//               side: const BorderSide(color: Colors.red),
//               foregroundColor: Colors.red,
//             ),
//             child: isProcessing
//                 ? const CircularProgressIndicator()
//                 : const Text("Reject"),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: isProcessing ? null : () => _updateStatus(2), // Accept
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//             ),
//             child: isProcessing
//                 ? const CircularProgressIndicator(color: Colors.white)
//                 : const Text("Accept"),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ================= HELPERS =================
//
//   Widget _card({required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade300),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   Widget _sectionTitle(
//       BuildContext context,
//       String text,
//       bool showChat,
//       Order? order,
//       OrderItem? firstProduct,
//       ) {
//     return Row(
//       children: [
//         Text(
//           text,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const Spacer(),
//
//         /// CHAT BUTTON
//         if (showChat && order != null && firstProduct != null)
//           InkWell(
//             onTap: () async {
//               final product = firstProduct.product;
//
//               /// Show loader
//               if (!context.mounted) return;
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (_) =>
//                 const Center(child: CircularProgressIndicator()),
//               );
//
//               try {
//                 /// START CHAT API CALL with product ID
//                 final conversationId = await ChatService.startConversation(
//                   productId: product.id,
//                   otherUserId: order.customer.id,
//                 );
//
//                 if (context.mounted) Navigator.pop(context); // Close loader
//
//                 if (conversationId != null && context.mounted) {
//                   /// OPEN CHAT SCREEN with product info
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => ChatDetailScreen(
//                         name: order.customer.name,
//                         image: "${ApiService.ImagebaseUrl}${ApiService.profile_image_URL}${order.customer.image}",
//                         productname: product.name,
//                         productimage: product.primaryImage,
//                         conversationId: conversationId,
//                       ),
//                     ),
//                   );
//                 } else if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Failed to start conversation"),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               } catch (e) {
//                 if (context.mounted) {
//                   Navigator.pop(context); // Close loader
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Error: $e"),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               }
//             },
//             child: SvgPicture.asset(
//               "assets/images/chat.svg",
//               height: 20,
//               color: Colors.green.shade700,
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 12, color: Colors.black54),
//           ),
//           Text(value, style: const TextStyle(fontSize: 13)),
//         ],
//       ),
//     );
//   }
//
//   Widget _divider() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(vertical: 10),
//       child: Divider(height: 1),
//     );
//   }
//
//   Future<void> _makePhoneCall(String phoneNumber) async {
//     final Uri url = Uri(
//       scheme: 'tel',
//       path: phoneNumber,
//     );
//
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Cannot open dialer")),
//         );
//       }
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:molafzo_vendor/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../chat/screens/chat_detail_screen.dart';
import '../../chat/screens/chat_service.dart';
import '../controller/order_controller.dart';
import '../model/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool isProcessing = false;

  bool get isNewOrder => widget.order.statusId == 1;
  bool get awaitingPickup => widget.order.statusId == 2;
  bool get completed => widget.order.statusId == 3;
  bool get cancelled => widget.order.statusId == 4;

  Future<void> _updateStatus(int statusId) async {
    setState(() => isProcessing = true);

    try {
      await OrderApiService().updateOrderStatus(widget.order.id, statusId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to update order")));
      }
    }

    if (mounted) setState(() => isProcessing = false);
  }

  // Format date and time
  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      // Format date
      final String formattedDate = _formatDate(dateTime);

      // Format time
      final String formattedTime = _formatTime(dateTime);

      // Show relative time for recent orders
      if (difference.inDays < 7) {
        if (difference.inDays > 0) {
          return '$formattedDate • ${difference.inDays}d ago';
        } else if (difference.inHours > 0) {
          return '$formattedDate • ${difference.inHours}h ago';
        } else if (difference.inMinutes > 0) {
          return '$formattedDate • ${difference.inMinutes}m ago';
        } else {
          return '$formattedDate • Just now';
        }
      }

      return '$formattedDate at $formattedTime';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final orderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (orderDate == today) {
      return 'Today';
    } else if (orderDate == yesterday) {
      return 'Yesterday';
    } else {
      // Format as "Mar 25, 2026"
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  OrderItem? get _firstProduct {
    if (widget.order.items.isNotEmpty) {
      return widget.order.items.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final firstProduct = _firstProduct;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _orderIdCard(order),
                    const SizedBox(height: 16),
                    _customerInfo(context, order, firstProduct),
                    const SizedBox(height: 16),
                    _orderItems(order),
                    const SizedBox(height: 16),
                    _orderMetaInfo(order),
                    const SizedBox(height: 16),
                    _totalRow(order),
                    const SizedBox(height: 16),
                    _agentInfo(order, firstProduct),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            /// BOTTOM ACTIONS
            if (isNewOrder || awaitingPickup)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: isNewOrder
                    ? _processButtons()
                    : _completeButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _completeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : () => _updateStatus(3),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Complete Order"),
      ),
    );
  }

  // ================= ORDER ID =================

  Widget _orderIdCard(Order order) {
    return _card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isNewOrder
                  ? Colors.orange.shade100
                  : completed
                  ? Colors.green.shade100
                  : cancelled
                  ? Colors.red.shade100
                  : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusText(order.statusId),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isNewOrder
                    ? Colors.orange
                    : completed
                    ? Colors.green
                    : cancelled
                    ? Colors.red
                    : Colors.blue,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            "Order ID",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(width: 4),
          Text(
            "#${order.id}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ================= ORDER META INFO (with Date & Time) =================

  Widget _orderMetaInfo(Order order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Information",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow("Order Date", _formatDateTime(order.createdAt)),
          _infoRow("Payment Method", order.paymentType.toUpperCase()),
          _infoRow("Delivery Method",
              order.deliveryMethod.replaceAll('_', ' ').toUpperCase()),
          if (order.deliveryMethod == 'store_pickup')
            _infoRow("Pickup Type", "Store Pickup"),
        ],
      ),
    );
  }

  // ================= CUSTOMER INFO =================

  Widget _customerInfo(BuildContext context, Order order, OrderItem? firstProduct) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, "Customer Information", true, order, firstProduct),
          const SizedBox(height: 10),
          _infoRow("Name", order.customer.name),
          _infoRow("Phone", order.customer.mobile),
          const SizedBox(height: 12),
          const Text(
            "Delivery Address",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(order.deliveryAddress, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          const Text(
            "Payment Mode",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(order.paymentType, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // ================= ORDER ITEMS =================

  Widget _orderItems(Order order) {
    if (order.items.isEmpty) {
      return _card(
        child: const Text(
          "No items found",
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Items",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) {
            return Column(
              children: [
                _orderItemTile(item),
                if (item != order.items.last) _divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _orderItemTile(OrderItem item) {
    final product = item.product;
    final hasVariant = item.variant != null && item.variant!.isNotEmpty;
    final variantDisplay = hasVariant ? _getVariantDisplay(item.variant!) : '';

    // Parse prices
    final double originalPrice = double.tryParse(product.price) ?? 0;
    final bool hasDiscount = originalPrice > 0 && double.tryParse(product.discountPrice) != null &&
        double.parse(product.discountPrice) > 0 &&
        double.parse(product.discountPrice) < originalPrice;

    final double displayPrice = double.tryParse(item.price) ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// PRODUCT IMAGE
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
          ),
          clipBehavior: Clip.antiAlias,
          child: product.primaryImage.isNotEmpty
              ? Image.network(
            "${ApiService.ImagebaseUrl}${ApiService.product_images_URL}${product.primaryImage}",
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.image_not_supported),
          )
              : const Icon(Icons.image),
        ),

        const SizedBox(width: 12),

        /// PRODUCT DETAILS
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),

              /// VARIANT DETAILS
              if (hasVariant) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    variantDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],

              Text(
                "Qty: ${item.quantity}",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),

        /// ITEM TOTAL
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "c. ${item.total.toStringAsFixed(0)}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "(${item.quantity} item${item.quantity > 1 ? 's' : ''})",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(height: 2),
              Text(
                "c. ${(originalPrice * item.quantity).toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade400,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _getVariantDisplay(Map<String, dynamic> variant) {
    if (variant.isEmpty) return '';

    final List<String> variantParts = [];
    variant.forEach((key, value) {
      variantParts.add('$key: $value');
    });

    return variantParts.join(' • ');
  }

  String _statusText(int statusId) {
    switch (statusId) {
      case 1:
        return "New Order";
      case 2:
        return "Awaiting Pickup";
      case 3:
        return "Completed";
      case 4:
        return "Cancelled";
      default:
        return "Unknown";
    }
  }

  // ================= TOTAL =================

  Widget _totalRow(Order order) {
    double totalAmount = 0;

    for (var item in order.items) {
      totalAmount += item.total;
    }

    return _card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            "c. ${totalAmount.toStringAsFixed(0)}",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _agentInfo(Order order, OrderItem? firstProduct) {
    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              "${ApiService.ImagebaseUrl}${ApiService.profile_image_URL}${order.customer.image}",
            ),
            child: const Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customer.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Contact with chat and call",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          if (firstProduct != null)
            InkWell(
              onTap: () async {
                final product = firstProduct.product;

                if (!context.mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                  const Center(child: CircularProgressIndicator()),
                );

                try {
                  final conversationId = await ChatService.startConversation(
                    productId: product.id,
                    otherUserId: order.customer.id,
                  );

                  if (context.mounted) Navigator.pop(context);

                  if (conversationId != null && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          name: order.customer.name,
                          image: "${ApiService.ImagebaseUrl}${ApiService.profile_image_URL}${order.customer.image}",
                          productname: product.name,
                          productimage: product.primaryImage,
                          conversationId: conversationId,
                        ),
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Failed to start conversation"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: SvgPicture.asset(
                "assets/images/chat.svg",
                height: 26,
                color: Colors.green.shade700,
              ),
            ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              _makePhoneCall(order.customer.mobile);
            },
            child: Icon(
              Icons.call,
              size: 26,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTONS =================

  Widget _processButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isProcessing ? null : () => _updateStatus(4),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
            ),
            child: isProcessing
                ? const CircularProgressIndicator()
                : const Text("Reject"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isProcessing ? null : () => _updateStatus(2),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Accept"),
          ),
        ),
      ],
    );
  }

  // ================= HELPERS =================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(
      BuildContext context,
      String text,
      bool showChat,
      Order? order,
      OrderItem? firstProduct,
      ) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),

        if (showChat && order != null && firstProduct != null)
          InkWell(
            onTap: () async {
              final product = firstProduct.product;

              if (!context.mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                const Center(child: CircularProgressIndicator()),
              );

              try {
                final conversationId = await ChatService.startConversation(
                  productId: product.id,
                  otherUserId: order.customer.id,
                );

                if (context.mounted) Navigator.pop(context);

                if (conversationId != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        name: order.customer.name,
                        image: "${ApiService.ImagebaseUrl}${ApiService.profile_image_URL}${order.customer.image}",
                        productname: product.name,
                        productimage: product.primaryImage,
                        conversationId: conversationId,
                      ),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to start conversation"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: SvgPicture.asset(
              "assets/images/chat.svg",
              height: 20,
              color: Colors.green.shade700,
            ),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot open dialer")),
        );
      }
    }
  }
}