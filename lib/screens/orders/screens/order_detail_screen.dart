//
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
//       if (mounted) Navigator.pop(context, true);
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
//   // Format date and time
//   String _formatDateTime(String dateTimeStr) {
//     try {
//       final dateTime = DateTime.parse(dateTimeStr);
//       final now = DateTime.now();
//       final difference = now.difference(dateTime);
//
//       // Format date
//       final String formattedDate = _formatDate(dateTime);
//
//       // Format time
//       final String formattedTime = _formatTime(dateTime);
//
//       // Show relative time for recent orders
//       if (difference.inDays < 7) {
//         if (difference.inDays > 0) {
//           return '$formattedDate • ${difference.inDays}d ago';
//         } else if (difference.inHours > 0) {
//           return '$formattedDate • ${difference.inHours}h ago';
//         } else if (difference.inMinutes > 0) {
//           return '$formattedDate • ${difference.inMinutes}m ago';
//         } else {
//           return '$formattedDate • Just now';
//         }
//       }
//
//       return '$formattedDate at $formattedTime';
//     } catch (e) {
//       return dateTimeStr;
//     }
//   }
//
//   String _formatDate(DateTime dateTime) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final orderDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
//
//     if (orderDate == today) {
//       return 'Today';
//     } else if (orderDate == yesterday) {
//       return 'Yesterday';
//     } else {
//       // Format as "Mar 25, 2026"
//       final months = [
//         'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//       ];
//       return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
//     }
//   }
//
//   String _formatTime(DateTime dateTime) {
//     int hour = dateTime.hour;
//     int minute = dateTime.minute;
//     String period = hour >= 12 ? 'PM' : 'AM';
//
//     if (hour > 12) hour -= 12;
//     if (hour == 0) hour = 12;
//
//     return '$hour:${minute.toString().padLeft(2, '0')} $period';
//   }
//
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
//                     _orderMetaInfo(order),
//                     const SizedBox(height: 16),
//                     _totalRow(order),
//                     const SizedBox(height: 16),
//                     _agentInfo(order, firstProduct),
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
//         onPressed: isProcessing ? null : () => _updateStatus(3),
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
//   // ================= ORDER META INFO (with Date & Time) =================
//
//   Widget _orderMetaInfo(Order order) {
//     return _card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Order Information",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _infoRow("Order Date", _formatDateTime(order.createdAt)),
//           _infoRow("Payment Method", order.paymentType.toUpperCase()),
//           _infoRow(
//             "Delivery Type",
//             order.deliveryMethod == "store_pickup"
//                 ? "Self Pickup"
//                 : "Home Delivery",
//           ),
//           if (order.deliveryMethod == 'store_pickup')
//             _infoRow("Pickup Type", "Store Pickup"),
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
//           /// 🔹 ADDRESS TITLE
//           Text(
//             order.deliveryMethod == "store_pickup"
//                 ? "Pickup Location"
//                 : "Delivery Address",
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//
//           const SizedBox(height: 6),
//
//           /// 🔹 MESSAGE (IMPORTANT UX)
//           Text(
//             order.deliveryMethod == "store_pickup"
//                 ? "This is a self pickup order. Customer will come to your store to collect it."
//                 : "Deliver this order to the customer's address below.",
//             style: TextStyle(
//               fontSize: 12,
//               color: order.deliveryMethod == "store_pickup"
//                   ? Colors.orange.shade700
//                   : Colors.green.shade700,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           /// 🔹 ADDRESS (COMMON FIELD)
//           Text(
//             order.deliveryAddress,
//             style: const TextStyle(fontSize: 13),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             "Payment Mode",
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
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
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Order Items",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 12),
//           ...order.items.map((item) {
//             return Column(
//               children: [
//                 _orderItemTile(item),
//                 if (item != order.items.last) _divider(),
//               ],
//             );
//           }).toList(),
//         ],
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
//     final bool hasDiscount = originalPrice > 0 && double.tryParse(product.discountPrice) != null &&
//         double.parse(product.discountPrice) > 0 &&
//         double.parse(product.discountPrice) < originalPrice;
//
//     final double displayPrice = double.tryParse(item.price) ?? 0;
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
//     double totalAmount = 0;
//
//     for (var item in order.items) {
//       totalAmount += item.total;
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
//                 if (!context.mounted) return;
//                 showDialog(
//                   context: context,
//                   barrierDismissible: false,
//                   builder: (_) =>
//                   const Center(child: CircularProgressIndicator()),
//                 );
//
//                 try {
//                   final conversationId = await ChatService.startConversation(
//                     productId: product.id,
//                     otherUserId: order.customer.id,
//                   );
//
//                   if (context.mounted) Navigator.pop(context);
//
//                   if (conversationId != null && context.mounted) {
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
//                     Navigator.pop(context);
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
//             onPressed: isProcessing ? null : () => _updateStatus(4),
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
//             onPressed: isProcessing ? null : () => _updateStatus(2),
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
//         if (showChat && order != null && firstProduct != null)
//           InkWell(
//             onTap: () async {
//               final product = firstProduct.product;
//
//               if (!context.mounted) return;
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (_) =>
//                 const Center(child: CircularProgressIndicator()),
//               );
//
//               try {
//                 final conversationId = await ChatService.startConversation(
//                   productId: product.id,
//                   otherUserId: order.customer.id,
//                 );
//
//                 if (context.mounted) Navigator.pop(context);
//
//                 if (conversationId != null && context.mounted) {
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
//                   Navigator.pop(context);
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
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 13),
//               textAlign: TextAlign.right,
//             ),
//           ),
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
import 'package:molafzo_vendor/extensions/context_extension.dart';
import 'package:molafzo_vendor/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  // ─────────────────────────────────────────────────────────
  //  Status helpers
  // ─────────────────────────────────────────────────────────

  String _statusText(int id) {
    switch (id) {
      case 1: return context.tr('new_orders');
      case 2: return context.tr('awaiting_pickup');
      case 3: return context.tr('completed');
      case 4: return context.tr('cancelled');
      default: return context.tr('unknown');
    }
  }

  Color _statusColor(int id) {
    switch (id) {
      case 1: return const Color(0xFFF59E0B);
      case 2: return const Color(0xFF3B82F6);
      case 3: return const Color(0xFF22C55E);
      case 4: return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Date/time helpers
  // ─────────────────────────────────────────────────────────

  String _formatDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      final now = DateTime.now();
      final diff = now.difference(dt);
      final dateStr = _formatDate(dt);
      final timeStr = _formatTime(dt);

      if (diff.inDays < 7) {
        if (diff.inDays > 0) return '$dateStr • ${diff.inDays}d ago';
        if (diff.inHours > 0) return '$dateStr • ${diff.inHours}h ago';
        if (diff.inMinutes > 0) return '$dateStr • ${diff.inMinutes}m ago';
        return '$dateStr • Just now';
      }
      return '$dateStr at $timeStr';
    } catch (_) {
      return raw;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final orderDay = DateTime(dt.year, dt.month, dt.day);

    if (orderDay == today) return 'Today';
    if (orderDay == yesterday) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    int h = dt.hour;
    final m = dt.minute;
    final period = h >= 12 ? 'PM' : 'AM';
    if (h > 12) h -= 12;
    if (h == 0) h = 12;
    return '$h:${m.toString().padLeft(2, '0')} $period';
  }

  // ─────────────────────────────────────────────────────────
  //  Misc helpers
  // ─────────────────────────────────────────────────────────

  OrderItem? get _firstProduct =>
      widget.order.items.isNotEmpty ? widget.order.items.first : null;

  double get _orderTotal =>
      widget.order.items.fold(0, (sum, i) => sum + i.total);

  String _getVariantDisplay(Map<String, dynamic> v) {
    if (v.isEmpty) return '';
    return v.entries.map((e) => '${e.key}: ${e.value}').join(' • ');
  }

  // ─────────────────────────────────────────────────────────
  //  API call
  // ─────────────────────────────────────────────────────────

  Future<void> _updateStatus(int statusId) async {
    setState(() => isProcessing = true);
    try {
      await OrderApiService().updateOrderStatus(widget.order.id, statusId);
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update order")),
        );
      }
    }
    if (mounted) setState(() => isProcessing = false);
  }

  // ─────────────────────────────────────────────────────────
  //  PDF Receipt generation (opens on tap via Printing)
  // ─────────────────────────────────────────────────────────

  Future<void> _openReceiptPdf() async {
    final order = widget.order;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Green header ──────────────────────────────────────────
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 22, horizontal: 24),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green700,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      context.tr('order_receipt'),
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${context.tr('order')} #${order.id}',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 22),

              // ── Status + Date ──────────────────────────────────────────
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: completed ? PdfColors.green100 : cancelled ? PdfColors.red100 : PdfColors.orange100,
                      borderRadius: pw.BorderRadius.circular(20),
                      border: pw.Border.all(
                        color: completed ? PdfColors.green700 : cancelled ? PdfColors.red700 : PdfColors.orange700,
                        width: 1,
                      ),
                    ),
                    child: pw.Text(
                      _statusText(order.statusId).toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: completed ? PdfColors.green800 : cancelled ? PdfColors.red800 : PdfColors.orange800,
                      ),
                    ),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    _formatDateTime(order.createdAt),
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),

              pw.SizedBox(height: 22),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 16),

              // ── Customer Info ──────────────────────────────────────────
              _pdfSectionTitle(context.tr('customer_info')),
              pw.SizedBox(height: 10),
              _pdfRow(context.tr('txt_name'), order.customer.name),
              _pdfRow(context.tr('txt_phone'), order.customer.mobile),
              _pdfRow(
                order.deliveryMethod == 'store_pickup' ? context.tr('txt_pickup_loc') : context.tr('txt_delivery_address'),
                order.deliveryAddress,
              ),

              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 16),

              // ── Order Details ──────────────────────────────────────────
              _pdfSectionTitle(context.tr('txt_order_details')),
              pw.SizedBox(height: 10),
              _pdfRow(context.tr('txt_payment_method'), order.paymentType.toUpperCase()),
              _pdfRow(
                context.tr('txt_delivery_type'),
                order.deliveryMethod == 'store_pickup' ? context.tr('txt_store_pickup') : context.tr('txt_home_delivery'),
              ),
              _pdfRow(context.tr('txt_order_date'), _formatDateTime(order.createdAt)),

              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 16),

              // ── Items ──────────────────────────────────────────────────
              _pdfSectionTitle(context.tr('txt_items')),
              pw.SizedBox(height: 10),
              ...order.items.map((item) {
                final hasVariant = item.variant != null && item.variant!.isNotEmpty;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.product.name,
                              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                            ),
                            if (hasVariant) ...[
                              pw.SizedBox(height: 2),
                              pw.Text(
                                _getVariantDisplay(item.variant!),
                                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                              ),
                            ],
                            pw.Text(
                              'Qty: ${item.quantity}',
                              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                        '${item.total.toStringAsFixed(0)}c.',
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),

              pw.SizedBox(height: 8),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 14),

              // ── Total ──────────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    context.tr('txt_totals'),
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '${_orderTotal.toStringAsFixed(0)} c.',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green700,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 36),
              pw.Center(
                child: pw.Text(
                  context.tr('txt_thanks_for_order'),
                  style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  pw.Widget _pdfSectionTitle(String title) => pw.Text(
    title,
    style: pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey800,
    ),
  );

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 140,
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────────────────
  //  Chat helper
  // ─────────────────────────────────────────────────────────

  Future<void> _openChat(BuildContext context, Order order, OrderItem item) async {
    final product = item.product;
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
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
              image:
              "${ApiService.ImagebaseUrl}${ApiService.profile_image_URL}${order.customer.image}",
              productname: product.name,
              productimage: product.primaryImage,
              conversationId: conversationId,
            ),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(context.tr('txt_failed_to_start')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${context.tr('error')}: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String number) async {
    final url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar( SnackBar(content: Text(context.tr('txt_cant_open_dialer'))));
    }
  }

  // ═════════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final firstProduct = _firstProduct;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  _buildStatusCard(order),
                  const SizedBox(height: 12),
                  _buildCustomerCard(context, order, firstProduct),
                  const SizedBox(height: 12),
                  _buildItemsCard(order),
                  const SizedBox(height: 12),
                  _buildOrderInfoCard(order),
                  const SizedBox(height: 12),
                  _buildTotalCard(),
                  const SizedBox(height: 12),
                  _buildReceiptButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (isNewOrder || awaitingPickup) _buildBottomActions(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  AppBar
  // ─────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.tr('txt_order_details'),
        style: TextStyle(
          color: Colors.black87,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFEEEEEE)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Status card  (Order ID + badge + date)
  // ─────────────────────────────────────────────────────────

  Widget _buildStatusCard(Order order) {
    final statusColor = _statusColor(order.statusId);

    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Status pill with dot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  _statusText(order.statusId),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${context.tr('order')} #${order.id}",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDateTime(order.createdAt),
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Customer card
  // ─────────────────────────────────────────────────────────

  Widget _buildCustomerCard(
      BuildContext context,
      Order order,
      OrderItem? firstProduct,
      ) {
    final isPickup = order.deliveryMethod == 'store_pickup';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name + action buttons
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: NetworkImage(
                  "${ApiService.ImagebaseUrl}${ApiService.profile_image_URL}${order.customer.image}",
                ),
                child: const Icon(Icons.person_outline_rounded, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.customer.mobile,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (firstProduct != null)
                _iconBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () => _openChat(context, order, firstProduct),
                ),
              const SizedBox(width: 8),
              _iconBtn(
                icon: Icons.call_rounded,
                onTap: () => _makePhoneCall(order.customer.mobile),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _divider(),
          const SizedBox(height: 14),

          // Address row
          _infoIconRow(
            icon: isPickup ? Icons.store_rounded : Icons.location_on_rounded,
            iconBg: isPickup ? Colors.orange.shade50 : Colors.green.shade50,
            iconColor: isPickup ? Colors.orange.shade700 : Colors.green.shade700,
            label: isPickup ? context.tr('txt_pickup_loc') : context.tr('txt_delivery_address'),
            value: order.deliveryAddress,
            subtitle: isPickup
                ? context.tr('txt_customer_will_collect')
                : context.tr('txt_deliver_to_customer'),
            subtitleColor: isPickup ? Colors.orange.shade700 : Colors.green.shade700,
          ),

          const SizedBox(height: 14),
          _divider(),
          const SizedBox(height: 14),

          // Payment row
          _infoIconRow(
            icon: Icons.payment_rounded,
            iconBg: Colors.blue.shade50,
            iconColor: Colors.blue.shade700,
            label: context.tr('txt_payment_mode'),
            value: order.paymentType.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    const color = Color(0xFF22C55E);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _infoIconRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    String? subtitle,
    Color? subtitleColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: subtitleColor ?? Colors.black38),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Items card
  // ─────────────────────────────────────────────────────────

  Widget _buildItemsCard(Order order) {
    if (order.items.isEmpty) {
      return _card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(context.tr('txt_no_item_found'), style: TextStyle(color: Colors.black38)),
          ),
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            context.tr('txt_order_items'),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(height: 14),
          ...order.items.asMap().entries.map((e) {
            return Column(
              children: [
                _buildItemTile(e.value),
                if (e.key < order.items.length - 1) ...[
                  const SizedBox(height: 10),
                  _divider(),
                  const SizedBox(height: 10),
                ],
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildItemTile(OrderItem item) {
    final product = item.product;
    final hasVariant = item.variant != null && item.variant!.isNotEmpty;

    final double origPrice = double.tryParse(product.price) ?? 0;
    final bool hasDiscount = origPrice > 0 &&
        double.tryParse(product.discountPrice) != null &&
        double.parse(product.discountPrice) > 0 &&
        double.parse(product.discountPrice) < origPrice;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 64,
            height: 64,
            color: Colors.grey.shade100,
            child: product.primaryImage.isNotEmpty
                ? Image.network(
              "${ApiService.ImagebaseUrl}${ApiService.product_images_URL}${product.primaryImage}",
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
            )
                : const Icon(Icons.image_outlined, color: Colors.grey),
          ),
        ),
        const SizedBox(width: 12),

        // Name + variant + qty
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (hasVariant) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    _getVariantDisplay(item.variant!),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Qty: ${item.quantity}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${item.total.toStringAsFixed(0)} c.",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "${item.quantity} item${item.quantity > 1 ? 's' : ''}",
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
            if (hasDiscount) ...[
              const SizedBox(height: 2),
              Text(
                "${(origPrice * item.quantity).toStringAsFixed(0)} c.",
                style: TextStyle(
                  fontSize: 11,
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

  // ─────────────────────────────────────────────────────────
  //  Order info card  (date, shipping, payment)
  // ─────────────────────────────────────────────────────────

  Widget _buildOrderInfoCard(Order order) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            context.tr('txt_order_info'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          _infoIconRow(
            icon: Icons.calendar_today_rounded,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF6366F1),
            label: context.tr('txt_order_date'),
            value: _formatDateTime(order.createdAt),
          ),
          const SizedBox(height: 10),
          _divider(),
          const SizedBox(height: 10),
          _infoIconRow(
            icon: Icons.local_shipping_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF3B82F6),
            label: context.tr('txt_shipping_method'),
            value: order.deliveryMethod == 'store_pickup' ? context.tr('txt_store_pickup') : context.tr('txt_to_door'),
          ),
          const SizedBox(height: 10),
          _divider(),
          const SizedBox(height: 10),
          _infoIconRow(
            icon: Icons.payment_rounded,
            iconBg: const Color(0xFFF0FDF4),
            iconColor: const Color(0xFF22C55E),
            label: context.tr('txt_payment'),
            value: order.paymentType.toUpperCase(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Total card
  // ─────────────────────────────────────────────────────────

  Widget _buildTotalCard() {
    return _card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(
            context.tr('txt_total_amount'),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
          Text(
            "${_orderTotal.toStringAsFixed(0)} c.",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Receipt button  (opens PDF preview on tap)
  // ─────────────────────────────────────────────────────────

  Widget _buildReceiptButton() {
    return GestureDetector(
      onTap: _openReceiptPdf,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, color: Color(0xFF22C55E), size: 20),
            SizedBox(width: 8),
            Text(
              context.tr('txt_view_receipt'),
              style: TextStyle(
                color: Color(0xFF22C55E),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Bottom action buttons
  // ─────────────────────────────────────────────────────────

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: isNewOrder ? _processButtons() : _completeButton(),
    );
  }

  Widget _completeButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isProcessing ? null : () => _updateStatus(3),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22C55E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isProcessing
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
        )
            : Text(
          context.tr('txt_mark_as_completed'),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _processButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: isProcessing ? null : () => _updateStatus(4),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                foregroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isProcessing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(context.tr('txt_reject'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isProcessing ? null : () => _updateStatus(2),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isProcessing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
                  : Text(context.tr('txt_accept'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  Reusable helpers
  // ─────────────────────────────────────────────────────────

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);
}