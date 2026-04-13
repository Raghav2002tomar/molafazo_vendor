// screens/AdminRejectionDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:molafzo_vendor/services/api_service.dart';
import '../model/AdminRejectionModel.dart';

class AdminRejectionDetailScreen extends StatelessWidget {
  final List<AdminRejectionModel> allRejections;

  const AdminRejectionDetailScreen({
    super.key,
    required this.allRejections,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sortedRejections = List<AdminRejectionModel>.from(allRejections);
    sortedRejections.sort((a, b) {
      try {
        final aTime = DateTime.parse(a.createdAt);
        final bTime = DateTime.parse(b.createdAt);
        return aTime.compareTo(bTime);
      } catch (e) {
        return 0;
      }
    });

    return Scaffold(
      backgroundColor: cs.background,
      appBar: _buildAppBar(context, cs, isDark, allRejections.length),
      body: sortedRejections.isEmpty
          ? _buildEmptyState(context, cs)
          : _buildRejectionList(context, sortedRejections),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      ColorScheme cs,
      bool isDark,
      int count,
      ) {
    return AppBar(
      elevation: 0,
      backgroundColor: cs.surface,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _CircleAction(
          icon: Icons.arrow_back,
          bg: isDark ? Colors.white : Colors.black,
          fg: isDark ? Colors.black : Colors.white,
          onTap: () => Navigator.pop(context),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.admin_panel_settings,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Support',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onBackground,
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '$count ${count == 1 ? 'Rejection' : 'Rejections'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onBackground.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 50,
              color: cs.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Rejections',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: cs.onBackground,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All your stores and products are approved',
            style: TextStyle(
              fontSize: 14,
              color: cs.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionList(BuildContext context, List<AdminRejectionModel> rejections) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      itemCount: rejections.length,
      itemBuilder: (context, index) {
        final rejection = rejections[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.only(bottom: index == rejections.length - 1 ? 0 : 16),
          child: _buildRejectionMessage(context, rejection),
        );
      },
    );
  }

  Widget _buildRejectionMessage(BuildContext context, AdminRejectionModel rejection) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageUrl = rejection.type == 'store'
        ? (rejection.storeImage != null
        ? "${ApiService.ImagebaseUrl}${ApiService.store_logo_URL}${rejection.storeImage}"
        : null)
        : (rejection.productImage != null
        ? "${ApiService.ImagebaseUrl}${ApiService.product_images_URL}${rejection.productImage}"
        : null);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Admin Avatar with subtle animation
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: cs.primary.withOpacity(0.15),
              child: Icon(
                Icons.admin_panel_settings,
                size: 18,
                color: cs.primary,
              ),
            ),
          ),
        ),

        // Message Bubble
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Material(
              elevation: isDark ? 0 : 1,
              shadowColor: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(8),
                bottomRight: const Radius.circular(20),
              ),
              color: isDark ? Colors.grey.shade800 : cs.surfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Card with Image
                    _buildItemCard(
                      context,
                      rejection.type,
                      imageUrl,
                      rejection.storeName,
                      rejection.productName,
                    ),

                    const SizedBox(height: 12),

                    // Rejection Message
                    Text(
                      rejection.message,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : cs.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),

                    // Reason Card (if exists)
                    if (rejection.reason != null && rejection.reason!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildReasonCard(rejection.reason!),
                    ],

                    const SizedBox(height: 8),

                    // Timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 10,
                          color: cs.onSurfaceVariant.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(rejection.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(
      BuildContext context,
      String type,
      String? imageUrl,
      String? storeName,
      String? productName,
      ) {
    final isStore = type == 'store';
    final color = isStore ? Colors.blue : Colors.green;
    final name = isStore ? (storeName ?? 'Store') : (productName ?? 'Product');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Image with shadow
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? GestureDetector(
                  onTap: () => _showFullScreenImage(context, imageUrl),
                  child: Hero(
                    tag: imageUrl,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: color.withOpacity(0.1),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: color.withOpacity(0.1),
                        child: Icon(
                          isStore ? Icons.store : Icons.shopping_bag,
                          size: 28,
                          color: color.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                )
                    : Container(
                  color: color.withOpacity(0.1),
                  child: Icon(
                    isStore ? Icons.store : Icons.shopping_bag,
                    size: 28,
                    color: color.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name and Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isStore ? Icons.store_outlined : Icons.shopping_bag_outlined,
                          size: 10,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isStore ? 'Store' : 'Product',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: color,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Info icon
            Icon(
              Icons.info_outline,
              size: 16,
              color: color.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonCard(String reason) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.08),
            Colors.red.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rejection Reason',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? time) {
    if (time == null) return "";
    try {
      final date = DateTime.parse(time);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        // Today: show time
        return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      } else if (difference.inDays == 1) {
        return "Yesterday";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} days ago";
      } else {
        return "${date.day}/${date.month}/${date.year}";
      }
    } catch (e) {
      return "";
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => FullScreenImageViewer(imageUrl: imageUrl),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

// Enhanced Full Screen Image Viewer
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.96),
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: imageUrl,
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 48,
            right: 16,
            child: Material(
              color: Colors.white.withOpacity(0.2),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Circle Action Button
class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: bg.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: fg,
            size: 20,
          ),
        ),
      ),
    );
  }
}