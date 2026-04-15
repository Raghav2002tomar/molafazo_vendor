//
// import 'package:flutter/material.dart';
//
// import '../../services/api_service.dart';
// import '../chat/screens/chat_detail_screen.dart';
// import '../chat/screens/chat_service.dart';
// import '../chat/screens/conversation_model.dart';
//
//
// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({super.key});
//
//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }
//
// class _ChatListScreenState extends State<ChatListScreen> {
//   List<ConversationModel> conversations = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     loadConversations();
//   }
//
//   Future<void> loadConversations() async {
//     setState(() => _isLoading = true);
//
//     final data = await ChatService.getConversations();
//
//     setState(() {
//       conversations = data
//           .map((e) => ConversationModel.fromJson(e))
//           .toList();
//       _isLoading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     final tt = Theme.of(context).textTheme;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: cs.surface,
//       appBar: AppBar(
//         title: Text(
//           'Chats',
//           style: tt.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: cs.onSurface,
//           ),
//         ),
//         backgroundColor: cs.surface,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//       ),
//       body: _buildBody(cs, tt, isDark),
//     );
//   }
//
//   Widget _buildBody(ColorScheme cs, TextTheme tt, bool isDark) {
//     if (_isLoading) {
//       return Center(
//         child: CircularProgressIndicator(color: cs.primary),
//       );
//     }
//
//     if (conversations.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 90,
//               height: 90,
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.white12 : Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Icon(
//                 Icons.chat_bubble_outline_rounded,
//                 size: 42,
//                 color: cs.onSurfaceVariant,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "No Conversations Yet",
//               style: tt.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: cs.onSurface,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               "Start a chat to see it here",
//               style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: loadConversations,
//       color: cs.primary,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         itemCount: conversations.length,
//         separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
//         itemBuilder: (context, index) {
//           final chat = conversations[index];
//
//           // Build image URL for product or user
//           String imageUrl;
//           if (chat.productImage != null && chat.productImage!.isNotEmpty) {
//             imageUrl = "${ApiService.ImagebaseUrl}/${ApiService.product_images_URL}${chat.productImage}";
//           } else {
//             imageUrl = "${ApiService.ImagebaseUrl}${ApiService.profile_image_URL}${chat.otherUserImage ?? ''}";
//           }
//
//           return InkWell(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => ChatDetailScreen(
//                     productname: chat.productName,
//                     productimage: chat.productImage,
//                     name: chat.otherUserName,
//                     image: imageUrl,
//                     conversationId: chat.conversationId,
//                     // productId: chat.productId, // Pass product ID if needed
//                   ),
//                 ),
//               );
//             },
//             borderRadius: BorderRadius.circular(12),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Product/User Avatar
//                   Stack(
//                     children: [
//                       CircleAvatar(
//                         radius: 28,
//                         backgroundColor: Colors.grey.shade200,
//                         backgroundImage: imageUrl.isNotEmpty
//                             ? NetworkImage(imageUrl)
//                             : null,
//                         child: imageUrl.isEmpty
//                             ? Text(
//                           chat.otherUserName.isNotEmpty
//                               ? chat.otherUserName[0].toUpperCase()
//                               : "?",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: cs.primary,
//                           ),
//                         )
//                             : null,
//                       ),
//                       // if (chat.unreadCount > 0)
//                       //   Positioned(
//                       //     right: 0,
//                       //     top: 0,
//                       //     child: Container(
//                       //       padding: const EdgeInsets.all(4),
//                       //       decoration: const BoxDecoration(
//                       //         color: Colors.red,
//                       //         shape: BoxShape.circle,
//                       //       ),
//                       //       constraints: const BoxConstraints(
//                       //         minWidth: 18,
//                       //         minHeight: 18,
//                       //       ),
//                       //       child: Text(
//                       //         chat.unreadCount > 9 ? '9+' : chat.unreadCount.toString(),
//                       //         style: const TextStyle(
//                       //           color: Colors.white,
//                       //           fontSize: 10,
//                       //           fontWeight: FontWeight.bold,
//                       //         ),
//                       //         textAlign: TextAlign.center,
//                       //       ),
//                       //     ),
//                       //   ),
//                     ],
//                   ),
//
//                   const SizedBox(width: 12),
//
//                   // Chat Details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // User Name
//                         Text(
//                           chat.otherUserName,
//                           style: tt.bodyMedium?.copyWith(
//                             fontWeight: FontWeight.w700,
//                             color: cs.onSurface,
//                           ),
//                         ),
//
//                         const SizedBox(height: 2),
//
//                         // Product Name (if available)
//                         if (chat.productName != null && chat.productName!.isNotEmpty)
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.shopping_bag_outlined,
//                                 size: 12,
//                                 color: cs.primary,
//                               ),
//                               const SizedBox(width: 4),
//                               Expanded(
//                                 child: Text(
//                                   chat.productName!,
//                                   style: tt.bodySmall?.copyWith(
//                                     color: cs.primary,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                         const SizedBox(height: 4),
//
//                         // Last Message
//                         if (chat.lastMessage != null && chat.lastMessage!.isNotEmpty)
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.message_outlined,
//                                 size: 12,
//                                 color: cs.onSurfaceVariant.withOpacity(0.7),
//                               ),
//                               const SizedBox(width: 4),
//                               Expanded(
//                                 child: Text(
//                                   chat.lastMessage!,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: tt.bodySmall?.copyWith(
//                                     color: chat.unreadCount > 0
//                                         ? cs.onSurface
//                                         : cs.onSurfaceVariant,
//                                     fontWeight: chat.unreadCount > 0
//                                         ? FontWeight.w600
//                                         : FontWeight.normal,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                         const SizedBox(height: 4),
//
//                         // Time
//                         if (chat.lastMessageTime != null)
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.access_time,
//                                 size: 10,
//                                 color: cs.onSurfaceVariant.withOpacity(0.5),
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 _formatTime(chat.lastMessageTime!),
//                                 style: tt.bodySmall?.copyWith(
//                                   fontSize: 10,
//                                   color: cs.onSurfaceVariant.withOpacity(0.7),
//                                 ),
//                               ),
//                             ],
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   String _formatTime(String dateTimeString) {
//     try {
//       final dateTime = DateTime.parse(dateTimeString);
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
//       return dateTimeString;
//     }
//   }
// }


// screens/ChatListScreen.dart (updated - shows only latest rejection)
import 'package:flutter/material.dart';
import 'package:molafzo_vendor/extensions/context_extension.dart';
import '../../services/api_service.dart';
import '../chat/controller/AdminRejectionService.dart';
import '../chat/model/AdminRejectionModel.dart';
import '../chat/screens/AdminRejectionDetailScreen.dart';
import '../chat/screens/chat_detail_screen.dart';
import '../chat/screens/chat_service.dart';
import '../chat/screens/conversation_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ConversationModel> conversations = [];
  List<AdminRejectionModel> rejections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    setState(() => _isLoading = true);

    final convData = await ChatService.getConversations();
    final rejectionData = await AdminRejectionService.getRejections();

    setState(() {
      conversations = convData
          .map((e) => ConversationModel.fromJson(e))
          .toList();
      rejections = rejectionData;
      _isLoading = false;
    });
  }

  // Get the latest rejection only
  AdminRejectionModel? getLatestRejection() {
    if (rejections.isEmpty) return null;

    // Sort rejections by date (newest first)
    rejections.sort((a, b) {
      try {
        final aTime = DateTime.parse(a.createdAt);
        final bTime = DateTime.parse(b.createdAt);
        return bTime.compareTo(aTime);
      } catch (e) {
        return 0;
      }
    });

    return rejections.first;
  }

  // Create a combined list item model with single admin card
  List<ChatListItem> getCombinedList() {
    List<ChatListItem> items = [];

    // Add single admin rejection item (only if exists)
    final latestRejection = getLatestRejection();
    if (latestRejection != null) {
      items.add(ChatListItem(
        id: 'admin_latest',
        type: ChatItemType.admin,
        rejection: latestRejection,
        timestamp: latestRejection.createdAt,
      ));
    }

    // Add conversation items
    for (var conv in conversations) {
      String timestamp = conv.lastMessageTime ?? DateTime.now().toIso8601String();

      items.add(ChatListItem(
        id: 'conv_${conv.conversationId}',
        type: ChatItemType.conversation,
        conversation: conv,
        timestamp: timestamp,
      ));
    }

    // Sort by timestamp (newest first)
    items.sort((a, b) {
      try {
        final aTime = DateTime.parse(a.timestamp);
        final bTime = DateTime.parse(b.timestamp);
        return bTime.compareTo(aTime);
      } catch (e) {
        return 0;
      }
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          context.tr('txt_chat'),
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildBody(cs, tt, isDark),
    );
  }

  Widget _buildBody(ColorScheme cs, TextTheme tt, bool isDark) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: cs.primary),
      );
    }

    final combinedItems = getCombinedList();

    if (combinedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 42,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('txt_no_conv_yet'),
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('txt_start_chat_here'),
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadAllData,
      color: cs.primary,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: combinedItems.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final item = combinedItems[index];

          if (item.type == ChatItemType.admin) {
            return _buildAdminRejectionTile(item.rejection!, cs, tt);
          } else {
            return _buildConversationTile(item.conversation!, cs, tt);
          }
        },
      ),
    );
  }

  Widget _buildAdminRejectionTile(AdminRejectionModel rejection, ColorScheme cs, TextTheme tt) {
    return InkWell(
      onTap: () {
        // Pass all rejections to detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminRejectionDetailScreen(
              allRejections: rejections, // Pass all rejections
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: cs.primary.withOpacity(0.1),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.primary.withOpacity(0.3), width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 28,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      size: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.tr('txt_admin_support'),
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          context.tr('txt_rejection'),
                          style: tt.labelSmall?.copyWith(
                            color: Colors.red.shade700,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        rejection.type == 'store' ? Icons.store : Icons.shopping_bag,
                        size: 12,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          rejection.type == 'store'
                              ? (rejection.storeName ?? context.tr('txt_store_rejected'))
                              : (rejection.productName ?? context.tr('txt_prod_rejected')),
                          style: tt.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          rejection.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall?.copyWith(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 10,
                        color: cs.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rejection.getFormattedDate(),
                        style: tt.bodySmall?.copyWith(
                          fontSize: 10,
                          color: cs.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(ConversationModel chat, ColorScheme cs, TextTheme tt) {
    String imageUrl;
    if (chat.productImage != null && chat.productImage!.isNotEmpty) {
      imageUrl = "${ApiService.ImagebaseUrl}/${ApiService.product_images_URL}${chat.productImage}";
    } else {
      imageUrl = "${ApiService.ImagebaseUrl}${ApiService.profile_image_URL}${chat.otherUserImage ?? ''}";
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              productname: chat.productName,
              productimage: chat.productImage,
              name: chat.otherUserName,
              image: imageUrl,
              conversationId: chat.conversationId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? Text(
                chat.otherUserName.isNotEmpty
                    ? chat.otherUserName[0].toUpperCase()
                    : "?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.otherUserName,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (chat.productName != null && chat.productName!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 12,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            chat.productName!,
                            style: tt.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  if (chat.lastMessage != null && chat.lastMessage!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: 12,
                          color: cs.onSurfaceVariant.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            chat.lastMessage!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodySmall?.copyWith(
                              color: chat.unreadCount > 0
                                  ? cs.onSurface
                                  : cs.onSurfaceVariant,
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  if (chat.lastMessageTime != null)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 10,
                          color: cs.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(chat.lastMessageTime!),
                          style: tt.bodySmall?.copyWith(
                            fontSize: 10,
                            color: cs.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
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
      return dateTimeString;
    }
  }
}

enum ChatItemType { admin, conversation }

class ChatListItem {
  final String id;
  final ChatItemType type;
  final AdminRejectionModel? rejection;
  final ConversationModel? conversation;
  final String timestamp;

  ChatListItem({
    required this.id,
    required this.type,
    this.rejection,
    this.conversation,
    required this.timestamp,
  });
}