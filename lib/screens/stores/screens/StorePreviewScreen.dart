import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOR CUSTOMIZATION MODEL
// ─────────────────────────────────────────────────────────────────────────────
// Update the StoreColorCustomization class in StorePreviewScreen
class StoreColorCustomization {
  Color backgroundColor;

  StoreColorCustomization({required this.backgroundColor});

  factory StoreColorCustomization.defaultColors() =>
      StoreColorCustomization(backgroundColor: const Color(0xFFF5F0EB));
}

// Update the _saveColors method

// ─────────────────────────────────────────────────────────────────────────────
// WATER RIPPLE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _RippleData {
  Offset center;
  double radius;
  double maxRadius;
  double opacity;

  _RippleData({
    required this.center,
    required this.radius,
    required this.maxRadius,
    required this.opacity,
  });
}

class WaterRipplePainter extends CustomPainter {
  final List<_RippleData> ripples;
  final Color color;

  WaterRipplePainter({required this.ripples, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in ripples) {
      final progress = r.radius / r.maxRadius;
      final paint = Paint()
        ..color = color.withOpacity(r.opacity * (1 - progress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1 - progress * 0.5);

      canvas.drawCircle(r.center, r.radius, paint);

      // Inner ring
      if (r.radius > 20) {
        final innerPaint = Paint()
          ..color = color.withOpacity(r.opacity * (1 - progress) * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawCircle(r.center, r.radius * 0.65, innerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(WaterRipplePainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// STORE PREVIEW SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class StorePreviewScreen extends StatefulWidget {
  final String storeName;
  final String storeMobile;
  final String storeDescription;
  final String storeCity;
  final String storeAddress;
  final String storeLandmark;
  final bool sellOffline;
  final bool selfPickup;
  final bool deliveryBySeller;
  final String workingHours;
  final XFile? logoImage;
  final XFile? backgroundImage;
  final Map<String, dynamic>? storePolicy;
  final List<Map<String, String>> socialLinks;
  final Function(Color)? onColorSaved;

  const StorePreviewScreen({
    super.key,
    required this.storeName,
    required this.storeMobile,
    required this.storeDescription,
    required this.storeCity,
    required this.storeAddress,
    required this.storeLandmark,
    required this.sellOffline,
    required this.selfPickup,
    required this.deliveryBySeller,
    required this.workingHours,
    this.logoImage,
    this.backgroundImage,
    this.storePolicy,
    this.socialLinks = const [],
    this.onColorSaved,
  });

  @override
  State<StorePreviewScreen> createState() => _StorePreviewScreenState();
}

class _StorePreviewScreenState extends State<StorePreviewScreen>
    with TickerProviderStateMixin {
  late StoreColorCustomization _colors;
  bool _showColorPanel = false;
  String _selectedCategory = 'Shop all';

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Water ripple
  final List<_RippleData> _ripples = [];
  late AnimationController _rippleCtrl;

  final List<Map<String, String>> _sampleProducts = [
    {'name': 'Premium Product', 'price': '1,299 c.', 'original': '1,999 c,', 'discount': '35%'},
    {'name': 'Featured Item', 'price': '899 c.', 'original': '1,499 c.', 'discount': '40%'},
    {'name': 'Best Seller', 'price': '2,499 c.', 'original': '3,499 c.', 'discount': '28%'},
    {'name': 'New Arrival', 'price': '599 c.', 'original': '999 c.', 'discount': '40%'},
    {'name': 'Trending Item', 'price': '1,799 c.', 'original': '2,499 c.', 'discount': '28%'},
    {'name': 'Limited Edition', 'price': '3,299 c.', 'original': '4,999 c.', 'discount': '34%'},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Shop all', 'icon': null},
    {'label': 'Notions', 'icon': null},
    {'label': 'Books', 'icon': null},
    {'label': 'Fabric', 'icon': null},
    {'label': 'On Sale', 'icon': null},
  ];
// Add this method to _StorePreviewScreenState class

  Widget _buildBackButton() {
    return Positioned(
      bottom: 24,
      left: 20,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isDark
                  ? [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.85),
              ]
                  : [
                Colors.black.withOpacity(0.85),
                Colors.black.withOpacity(0.75),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: (_isDark ? Colors.black : Colors.white).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _isDark ? Colors.black87 : Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _colors = StoreColorCustomization.defaultColors();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _rippleCtrl.addListener(_updateRipples);
  }

  void _updateRipples() {
    setState(() {
      for (final r in _ripples) {
        r.radius += 2.8;
      }
      _ripples.removeWhere((r) => r.radius >= r.maxRadius);
    });
  }

  void _addRipple(Offset position) {
    setState(() {
      _ripples.add(_RippleData(
        center: position,
        radius: 0,
        maxRadius: 160,
        opacity: 0.6,
      ));
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _rippleCtrl.dispose();
    super.dispose();
  }

  void _saveColors() {
    widget.onColorSaved?.call(_colors.backgroundColor);
    Fluttertoast.showToast(msg: "Background color saved!");
    setState(() => _showColorPanel = false);
  }

  // ── Detect if bg is dark
  bool get _isDark =>
      _colors.backgroundColor.computeLuminance() < 0.4;

  Color get _textColor => _isDark ? Colors.white : Colors.black87;
  Color get _subTextColor =>
      _isDark ? Colors.white.withOpacity(0.7) : Colors.black54;
  Color get _cardColor =>
      _isDark ? Colors.white.withOpacity(0.12) : Colors.white;
  Color get _chipColor =>
      _isDark ? Colors.white.withOpacity(0.15) : Colors.white;
  Color get _selectedChipColor =>
      _isDark ? Colors.white : Colors.black87;
  Color get _selectedChipTextColor =>
      _isDark ? Colors.black87 : Colors.white;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _colors.backgroundColor,
        body: Stack(
          children: [
            // Background ripple layer
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (d) => _addRipple(d.localPosition),
                child: CustomPaint(
                  painter: WaterRipplePainter(
                    ripples: _ripples,
                    color: _isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                  ),
                ),
              ),
            ),

            FadeTransition(
              opacity: _fadeAnim,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeroSliver(),
                  SliverToBoxAdapter(child: _buildCategoryStrip()),
                  SliverToBoxAdapter(child: _buildProductsHeader()),
                  _buildProductsGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),

            // Back Button - Bottom Left
            _buildBackButton(),

            // Color Picker FAB - Bottom Right
            Positioned(
              bottom: 24,
              right: 20,
              child: GestureDetector(
                onTap: () => setState(() => _showColorPanel = !_showColorPanel),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isDark ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    _showColorPanel ? Icons.close : Icons.palette_outlined,
                    color: _isDark ? Colors.black : Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Color Panel
            if (_showColorPanel)
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                child: _buildColorPanel(),
              ),
          ],
        ),
      ),
    );
  }
  // ─────────────────────────────────────────────────────────────────────────
  // HERO — Shopify-style with parallax
  // ─────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────
// HERO SLIVER with bottom gradient
// ─────────────────────────────────────────────────────────────────────────
// Alternative with stronger bottom gradient
  Widget _buildHeroSliver() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      backgroundColor: _colors.backgroundColor, // Set app bar background to theme color
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
        child: GestureDetector(
          onTap: _showStoreDetailsPage,
          child: _glassIconBtn(Icons.menu_rounded),
        ),
      ),
      actions: [
        _glassChipBtn('Follow'),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: _glassIconBtn(Icons.ios_share_rounded),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          color: _colors.backgroundColor, // Background color shows through at bottom
          child: _HeroBannerLocal(
            backgroundImage: widget.backgroundImage,
            logoImage: widget.logoImage,
            storeName: widget.storeName,
            backgroundColor: _colors.backgroundColor,
            isDark: _isDark,
          ),
        ),
      ),
    );
  }

  Widget _glassIconBtn(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _glassChipBtn(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showStoreDetailsPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => FadeTransition(
          opacity: a,
          child: StoreDetailsPage(
            storeName: widget.storeName,
            storeMobile: widget.storeMobile,
            storeDescription: widget.storeDescription,
            storeCity: widget.storeCity,
            storeAddress: widget.storeAddress,
            storeLandmark: widget.storeLandmark,
            sellOffline: widget.sellOffline,
            selfPickup: widget.selfPickup,
            deliveryBySeller: widget.deliveryBySeller,
            workingHours: widget.workingHours,
            storePolicy: widget.storePolicy,
            socialLinks: widget.socialLinks,
            backgroundColor: _colors.backgroundColor,
            logoImage: widget.logoImage,
            storeName2: widget.storeName,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CATEGORY STRIP
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCategoryStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      child: Wrap(
        spacing: 10,  // Horizontal gap between items
        runSpacing: 10,  // Vertical gap between rows
        alignment: WrapAlignment.start,
        children: [
          // Search icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _chipColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.search_rounded, size: 20, color: _subTextColor),
          ),
          // Categories
          ..._categories.map((cat) {
            final sel = _selectedCategory == cat['label'];
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['label']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? _selectedChipColor : _chipColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: sel
                        ? Colors.transparent
                        : (_isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.shade200),
                  ),
                  boxShadow: sel
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                      : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel ? _selectedChipTextColor : _subTextColor,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCTS HEADER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProductsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(
            'All products',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textColor,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _chipColor,
              shape: BoxShape.circle,
              border: Border.all(
                  color: _isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.shade200),
            ),
            child: Icon(Icons.tune_rounded, size: 18, color: _textColor),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCTS GRID
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildProductsGrid() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.66,
        ),
        delegate: SliverChildBuilderDelegate(
              (_, i) => _buildProductCard(i),
          childCount: _sampleProducts.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final p = _sampleProducts[index];
    return GestureDetector(
      onTapDown: (d) => _addRipple(d.globalPosition),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isDark
                ? Colors.white.withOpacity(0.12)
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isDark ? 0.25 : 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: _isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade100,
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 44,
                        color: _isDark
                            ? Colors.white.withOpacity(0.3)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  // Discount badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isDark ? Colors.white : Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${p['discount']} off',
                        style: TextStyle(
                          color: _isDark ? Colors.black87 : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  // Heart
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6)
                        ],
                      ),
                      child: const Icon(Icons.favorite_border_rounded,
                          size: 16, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['name']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(
                          i < 4
                              ? Icons.star_rounded
                              : Icons.star_half_rounded,
                          size: 11,
                          color: Colors.amber.shade600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          p['price']!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _textColor,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          p['original']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: _subTextColor,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: _subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COLOR PANEL
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildColorPanel() {
    final presets = [
      // Warm Colors
      {'color': const Color(0xFFF5F0EB), 'label': 'Warm'},
      {'color': const Color(0xFFFCE4D6), 'label': 'Peach'},
      {'color': const Color(0xFFFFE4B5), 'label': 'Moccasin'},
      {'color': const Color(0xFFFFDAB9), 'label': 'Apricot'},
      {'color': const Color(0xFFFADADD), 'label': 'Blush'},
      {'color': const Color(0xFFFFC2B4), 'label': 'Coral'},

      // Brown & Earth Tones
      {'color': const Color(0xFF6B3A2A), 'label': 'Brown'},
      {'color': const Color(0xFF8B5A2B), 'label': 'Saddle'},
      {'color': const Color(0xFFA0522D), 'label': 'Sienna'},
      {'color': const Color(0xFFCD853F), 'label': 'Peru'},
      {'color': const Color(0xFFD2B48C), 'label': 'Tan'},
      {'color': const Color(0xFFBC9A6C), 'label': 'Taupe'},
      {'color': const Color(0xFF4A3728), 'label': 'Coffee'},
      {'color': const Color(0xFF8B4513), 'label': 'Saddle Brown'},

      // Green & Sage
      {'color': const Color(0xFFB8C4C2), 'label': 'Sage'},
      {'color': const Color(0xFF2D4A3E), 'label': 'Forest'},
      {'color': const Color(0xFF98A886), 'label': 'Moss'},
      {'color': const Color(0xFF9CB071), 'label': 'Olive'},
      {'color': const Color(0xFF6B8E23), 'label': 'Olive Drab'},
      {'color': const Color(0xFF5F8575), 'label': 'Jade'},
      {'color': const Color(0xFF2E5C4E), 'label': 'Teal Green'},
      {'color': const Color(0xFFA7C5BD), 'label': 'Seafoam'},
      {'color': const Color(0xFFEAF2F0), 'label': 'Mint'},
      {'color': const Color(0xFFC1E1C1), 'label': 'Celadon'},

      // Blue & Navy
      {'color': const Color(0xFF1A1A2E), 'label': 'Navy'},
      {'color': const Color(0xFF2C3E50), 'label': 'Midnight'},
      {'color': const Color(0xFF2B3B4C), 'label': 'Dark Slate'},
      {'color': const Color(0xFF4B6A8B), 'label': 'Steel Blue'},
      {'color': const Color(0xFF5D8AA8), 'label': 'Air Force'},
      {'color': const Color(0xFF7CB9E8), 'label': 'Aero'},
      {'color': const Color(0xFF89CFF0), 'label': 'Baby Blue'},
      {'color': const Color(0xFFB0E0E6), 'label': 'Powder Blue'},
      {'color': const Color(0xFFE0F0FF), 'label': 'Ice Blue'},

      // Purple & Lavender
      {'color': const Color(0xFFF2EFF4), 'label': 'Lavender'},
      {'color': const Color(0xFFE6E6FA), 'label': 'Lavender Mist'},
      {'color': const Color(0xFFD8BFD8), 'label': 'Thistle'},
      {'color': const Color(0xFFC3B1E1), 'label': 'Wisteria'},
      {'color': const Color(0xFF9B59B6), 'label': 'Amethyst'},
      {'color': const Color(0xFF8E44AD), 'label': 'Purple'},
      {'color': const Color(0xFF6C3483), 'label': 'Deep Purple'},
      {'color': const Color(0xFF4A235A), 'label': 'Dark Violet'},

      // Pink & Rose
      {'color': const Color(0xFFFFC0CB), 'label': 'Pink'},
      {'color': const Color(0xFFFFB6C1), 'label': 'Light Pink'},
      {'color': const Color(0xFFFF69B4), 'label': 'Hot Pink'},
      {'color': const Color(0xFFF4C2C2), 'label': 'Rose'},
      {'color': const Color(0xFFE6A8D7), 'label': 'Orchid'},
      {'color': const Color(0xFFDB7093), 'label': 'Pale Violet'},

      // Red & Burgundy
      {'color': const Color(0xFFCD5C5C), 'label': 'Indian Red'},
      {'color': const Color(0xFFB22234), 'label': 'Burgundy'},
      {'color': const Color(0xFFA52A2A), 'label': 'Red Brown'},
      {'color': const Color(0xFFDC143C), 'label': 'Crimson'},
      {'color': const Color(0xFFFF6B6B), 'label': 'Coral Red'},
      {'color': const Color(0xFFFF7F7F), 'label': 'Salmon'},

      // Yellow & Gold
      {'color': const Color(0xFFFFFACD), 'label': 'Lemon'},
      {'color': const Color(0xFFFAF0E6), 'label': 'Linen'},
      {'color': const Color(0xFFFFF0DB), 'label': 'Vanilla'},
      {'color': const Color(0xFFF5E6D3), 'label': 'Beige'},
      {'color': const Color(0xFFE8E0D5), 'label': 'Ivory'},
      {'color': const Color(0xFFFFD700), 'label': 'Gold'},
      {'color': const Color(0xFFF4A460), 'label': 'Sandy Brown'},

      // Gray & Neutral
      {'color': Colors.white, 'label': 'White'},
      {'color': const Color(0xFFF5F5F5), 'label': 'White Smoke'},
      {'color': const Color(0xFFF0F0F0), 'label': 'Ghost White'},
      {'color': const Color(0xFFE8E8E8), 'label': 'Light Gray'},
      {'color': const Color(0xFFD3D3D3), 'label': 'Silver'},
      {'color': const Color(0xFFA9A9A9), 'label': 'Dark Gray'},
      {'color': const Color(0xFF808080), 'label': 'Gray'},
      {'color': const Color(0xFF4A4A4A), 'label': 'Charcoal'},
      {'color': const Color(0xFF2C2C2C), 'label': 'Dark Charcoal'},
      {'color': const Color(0xFF1A1A1A), 'label': 'Almost Black'},
      {'color': Colors.black, 'label': 'Black'},

      // Pastel Colors
      {'color': const Color(0xFFFFE5E5), 'label': 'Pastel Pink'},
      {'color': const Color(0xFFFFF0E0), 'label': 'Pastel Peach'},
      {'color': const Color(0xFFFFF5E0), 'label': 'Pastel Yellow'},
      {'color': const Color(0xFFE0FFE0), 'label': 'Pastel Green'},
      {'color': const Color(0xFFE0F0FF), 'label': 'Pastel Blue'},
      {'color': const Color(0xFFF0E0FF), 'label': 'Pastel Purple'},
      {'color': const Color(0xFFFFE0F0), 'label': 'Pastel Rose'},

      // Vibrant Colors
      {'color': const Color(0xFFFF4500), 'label': 'Orange Red'},
      {'color': const Color(0xFF32CD32), 'label': 'Lime Green'},
      {'color': const Color(0xFF00CED1), 'label': 'Dark Turquoise'},
      {'color': const Color(0xFF1E90FF), 'label': 'Dodger Blue'},
      {'color': const Color(0xFFFF1493), 'label': 'Deep Pink'},
      {'color': const Color(0xFFFFD700), 'label': 'Gold'},
      {'color': const Color(0xFFFF8C00), 'label': 'Dark Orange'},
    ];

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        const BorderRadius.horizontal(left: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(-4, 0))
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Store Theme',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showColorPanel = false),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade100),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Background Color',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                      children: presets.map((p) {
                        final color = p['color'] as Color;
                        final isSel =
                            _colors.backgroundColor.value == color.value;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _colors.backgroundColor = color),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSel
                                        ? Colors.black
                                        : Colors.grey.shade200,
                                    width: isSel ? 2.5 : 1,
                                  ),
                                  boxShadow: isSel
                                      ? [
                                    BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.2),
                                        blurRadius: 8)
                                  ]
                                      : null,
                                ),
                                child: isSel
                                    ? Icon(
                                  Icons.check_rounded,
                                  color:
                                  color.computeLuminance() > 0.5
                                      ? Colors.black87
                                      : Colors.white,
                                  size: 20,
                                )
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p['label'] as String,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.blue.shade600, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tap anywhere to see water ripple effect!',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.blue.shade700,
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(
                              () => _colors = StoreColorCustomization.defaultColors()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reset',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveColors,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Save',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STORE DETAILS PAGE — Shopify menu slide-in style
// ─────────────────────────────────────────────────────────────────────────────
class StoreDetailsPage extends StatefulWidget {
  final String storeName;
  final String storeName2;
  final String storeMobile;
  final String storeDescription;
  final String storeCity;
  final String storeAddress;
  final String storeLandmark;
  final bool sellOffline;
  final bool selfPickup;
  final bool deliveryBySeller;
  final String workingHours;
  final Map<String, dynamic>? storePolicy;
  final List<Map<String, String>> socialLinks;
  final Color backgroundColor;
  final XFile? logoImage;

  const StoreDetailsPage({
    super.key,
    required this.storeName,
    required this.storeName2,
    required this.storeMobile,
    required this.storeDescription,
    required this.storeCity,
    required this.storeAddress,
    required this.storeLandmark,
    required this.sellOffline,
    required this.selfPickup,
    required this.deliveryBySeller,
    required this.workingHours,
    this.storePolicy,
    this.socialLinks = const [],
    required this.backgroundColor,
    this.logoImage,
  });

  @override
  State<StoreDetailsPage> createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  bool get _isDark => widget.backgroundColor.computeLuminance() < 0.4;
  Color get _textColor => _isDark ? Colors.white : Colors.black87;
  Color get _subTextColor =>
      _isDark ? Colors.white.withOpacity(0.65) : Colors.black54;
  Color get _cardColor =>
      _isDark ? Colors.white.withOpacity(0.1) : Colors.white;
  Color get _dividerColor =>
      _isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              // Top bar — exactly like Shopify screenshots
              _buildTopBar(context),
              // Store mini header
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                  child: Column(
                    children: [
                      SizedBox(height: 16,),

                      _buildStoreHeader(),
                       SizedBox(height: 16,),
                      // Reviews card (like MeUndies)
                      _buildReviewsCard(),
                      const SizedBox(height: 12),
                      // Policies card
                      _buildPoliciesCard(),
                      const SizedBox(height: 12),
                      // Contact card
                      _buildContactCard(),
                      const SizedBox(height: 12),
                      // Store Info
                      if (widget.storeDescription.isNotEmpty ||
                          widget.storeAddress.isNotEmpty)
                        _buildStoreInfoCard(),
                      const SizedBox(height: 12),
                      // Delivery
                      if (widget.deliveryBySeller || widget.selfPickup)
                        _buildDeliveryCard(),
                      const SizedBox(height: 20),
                      // Visit Online Store Button (like Shopify)
                      _buildVisitStoreBtn(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.black.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded,
                  color: _textColor, size: 20),
            ),
          ),
          const Spacer(),
          // Follow button
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.07),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Follow',
              style: TextStyle(
                  color: _textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.ios_share_rounded,
                color: _textColor, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
                color: _isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade200,
                width: 1.5),
          ),
          clipBehavior: Clip.hardEdge,
          child: widget.logoImage != null
              ? Image.file(File(widget.logoImage!.path), fit: BoxFit.cover)
              : Center(
            child: Text(
              widget.storeName.isNotEmpty
                  ? widget.storeName[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.storeName.isEmpty ? 'Your Store' : widget.storeName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                const SizedBox(width: 3),
                Text(
                  '4.8 (2.5K ratings)',
                  style: TextStyle(fontSize: 12, color: _subTextColor),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ─── Reviews card (MeUndies style) ───────────────────────────────────────
  Widget _buildReviewsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Reviews',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _textColor)),
              const Spacer(),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    color: _textColor, size: 17),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('4.8',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: _textColor,
                          height: 1)),
                  const SizedBox(height: 4),
                  Text('2.5K ratings',
                      style: TextStyle(fontSize: 13, color: _subTextColor)),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: List.generate(
                  5,
                      (i) => Icon(
                    i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                    size: 30,
                    color: Colors.amber.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Sample review
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amazing store! Great quality products and fast delivery...',
                        style: TextStyle(
                            fontSize: 13,
                            color: _subTextColor,
                            height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(
                              5,
                                  (_) => Icon(Icons.star_rounded,
                                  size: 12, color: Colors.amber)),
                          const SizedBox(width: 6),
                          Text('Customer · 2 days ago',
                              style: TextStyle(
                                  fontSize: 11, color: _subTextColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.shopping_bag_outlined,
                      size: 20, color: _subTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Policies card (Shopify style) ───────────────────────────────────────
  Widget _buildPoliciesCard() {
    final policies = [
      {'label': 'Refund policy', 'icon': Icons.assignment_return_outlined},
      {'label': 'Shipping policy', 'icon': Icons.local_shipping_outlined},
      {'label': 'Privacy policy', 'icon': Icons.security_outlined},
      {'label': 'Terms and conditions', 'icon': Icons.info_outlined},
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Policies',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textColor)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two items per row
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.6, // Adjust this ratio to control height
            ),
            itemCount: policies.length,
            itemBuilder: (context, index) {
              final policy = policies[index];
              return _policyGridItem(
                  policy['label'] as String,
                  policy['icon'] as IconData
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _policyGridItem(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: _subTextColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  Widget _policyRow(String label, IconData icon) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      color: _subTextColor,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15, color: _subTextColor),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: _dividerColor),
      ],
    );
  }

  // ─── Contact card (Shopify style) ────────────────────────────────────────
  Widget _buildContactCard() {
    final List<Map<String, dynamic>> contacts = [
      {
        'label': 'Website',
        'icon': Icons.chat_bubble_outline_rounded,
        'show': true
      },
      {
        'label': widget.storeMobile.isNotEmpty ? widget.storeMobile : '—',
        'icon': Icons.phone_outlined,
        'show': widget.storeMobile.isNotEmpty
      },
      {
        'label': 'Instagram',
        'icon': Icons.camera_alt_outlined,
        'show': widget.socialLinks.any((l) => l['type'] == 'instagram')
      },
      {
        'label': 'Facebook',
        'icon': Icons.facebook_outlined,
        'show': widget.socialLinks.any((l) => l['type'] == 'facebook')
      },
      {
        'label': 'YouTube',
        'icon': Icons.play_circle_outline_rounded,
        'show': widget.socialLinks.any((l) => l['type'] == 'youtube')
      },
    ];

    final visible = contacts.where((c) => c['show'] == true).toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textColor)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two items per row
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8, // Adjust this ratio to control height
            ),
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final contact = visible[index];
              return _contactGridItem(
                  contact['label'] as String,
                  contact['icon'] as IconData
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _contactGridItem(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: _subTextColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About Store',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textColor)),
          const SizedBox(height: 10),

          // Store Description with See More/See Less
          if (widget.storeDescription.isNotEmpty) ...[
            _ExpandableText(  // This is correct - using the widget
              text: widget.storeDescription,
              style: TextStyle(
                fontSize: 14,
                color: _subTextColor,
                height: 1.6,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
          ],

          // Address and City in 2-column grid
          if (widget.storeAddress.isNotEmpty || widget.storeCity.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.storeAddress.isNotEmpty)
                  Expanded(
                    child: _storeInfoGridItem(
                      widget.storeAddress,
                      Icons.location_on_outlined,
                    ),
                  ),
                if (widget.storeAddress.isNotEmpty && widget.storeCity.isNotEmpty)
                  const SizedBox(width: 12),
                if (widget.storeCity.isNotEmpty)
                  Expanded(
                    child: _storeInfoGridItem(
                      widget.storeCity,
                      Icons.location_city_outlined,
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 12),

          // Working Hours - Full width
          _storeInfoFullWidthItem(
            widget.workingHours,
            Icons.schedule_rounded,
          ),
        ],
      ),
    );
  }


  Widget _storeInfoGridItem(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: _subTextColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeInfoFullWidthItem(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: _subTextColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDeliveryCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textColor)),
          const SizedBox(height: 10),
          if (widget.deliveryBySeller)
            _policyRow('Home Delivery Available', Icons.local_shipping_outlined),
          if (widget.selfPickup)
            _policyRow('Self Pickup Available', Icons.storefront_outlined),
        ],
      ),
    );
  }

  // ─── Visit Online Store button (Shopify style) ───────────────────────────
  Widget _buildVisitStoreBtn() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _isDark ? Colors.white.withOpacity(0.12) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Visit Online Store',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textColor),
          ),
          const SizedBox(width: 8),
          Icon(Icons.open_in_new_rounded, size: 16, color: _textColor),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: _isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER with bottom gradient background color
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBannerLocal extends StatelessWidget {
  final XFile? backgroundImage;
  final XFile? logoImage;
  final String storeName;
  final Color backgroundColor;
  final bool isDark;

  const _HeroBannerLocal({
    required this.backgroundImage,
    required this.logoImage,
    required this.storeName,
    required this.backgroundColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Create gradient that transitions from transparent to the background color
    final bottomGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: const [0.65, 0.75, 1.0],
      colors: [
        Colors.transparent,
        backgroundColor.withOpacity(0.5),
        backgroundColor,
      ],
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        if (backgroundImage != null)
          Image.file(
            File(backgroundImage!.path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.grey.shade900, Colors.black87]
                      : [Colors.grey.shade300, Colors.grey.shade100],
                ),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.grey.shade900, Colors.black87]
                    : [Colors.grey.shade300, Colors.grey.shade100],
              ),
            ),
          ),

        // Top dark gradient for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              stops: const [0.0, 0.3],
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Bottom gradient that transitions to background color
        Container(
          decoration: BoxDecoration(
            gradient: bottomGradient,
          ),
        ),

        // Logo + name centered
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: logoImage != null
                    ? Image.file(
                  File(logoImage!.path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _LetterFallback(name: storeName),
                )
                    : _LetterFallback(name: storeName),
              ),
              const SizedBox(height: 14),
              // Store Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  storeName.isEmpty ? 'Your Store Name' : storeName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 12)],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Rating chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded,
                        size: 15, color: Colors.amber.shade400),
                    const SizedBox(width: 4),
                    const Text(
                      '4.8',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 6)
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(2.5K ratings)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LetterFallback extends StatelessWidget {
  final String name;
  const _LetterFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'S',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const _ExpandableText({
    required this.text,
    this.style,
    this.maxLines = 2,
  });

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _isExpanded = false;
  bool _isOverflow = false;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverflow();
    });
  }

  void _checkOverflow() {
    final textWidget = _textKey.currentContext?.findRenderObject() as RenderParagraph?;
    if (textWidget != null) {
      final bool overflow = textWidget.text.style!.fontSize != null &&
          textWidget.size.height > (textWidget.text.style!.fontSize! * widget.maxLines * 1.5);
      if (_isOverflow != overflow) {
        setState(() {
          _isOverflow = overflow;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          key: _textKey,
          style: widget.style,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: TextOverflow.ellipsis,
        ),
        if (_isOverflow)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _isExpanded ? 'See less' : 'See more',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

