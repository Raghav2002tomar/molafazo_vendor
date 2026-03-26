import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import '../products/screens/add_product_basic_info.dart';
import '../stores/screens/add_store_screen.dart';

class DashboardTab extends StatefulWidget {
  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String username = 'User';
  String profilestatus = '';
  String email = '';

  // Dashboard data variables
  bool _isLoading = true;
  bool _hasError = false;

  // Filter state
  String _selectedPeriod = 'daily'; // daily, weekly, monthly, yearly

  // Store data from API
  int _totalRevenue = 0;
  int _totalOrders = 0;
  int _totalCustomers = 0;
  int _totalProducts = 0;
  int _outOfStock = 0;

  // Additional data for UI
  List _recentOrders = [];
  List _todayOrders = [];
  List _mostPurchasedProducts = [];
  List _allProducts = [];
  List _dailyRevenue = [];
  int _weeklyRevenue = 0;
  int _monthlyRevenue = 0;
  int _yearlyRevenue = 0;

  bool get _isProfileIncomplete => email.isEmpty;

  String get _profileStatusMessage {
    if (_isProfileIncomplete) return "Complete your profile";
    if (profilestatus == '2') return "Profile under review";
    if (profilestatus == '1') return "Profile approved ✓";
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
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    await fetchUserFromPrefs();
    await fetchDashboardData();
  }

  Future<void> fetchUserFromPrefs() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final userData = jsonDecode(userJson);
      if (mounted) {
        setState(() {
          username = userData['name'] ?? 'User';
          email = userData['email'] ?? '';
          profilestatus = userData['status_id']?.toString() ?? '';
        });
      }
    }
  }

  // Mock data for testing - with actual image paths
  void _loadMockData() {
    _totalRevenue;
    _totalOrders  ;
    _totalCustomers ;
    _totalProducts ;
    _outOfStock ;
    _dailyRevenue = [];
    _weeklyRevenue ;
    _monthlyRevenue ;
    _yearlyRevenue ;


    _recentOrders = [

    ];

    _mostPurchasedProducts = [

    ];

    _allProducts = [];

  }

  Future<void> fetchDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');

      if (token == null || token.isEmpty) {
        Fluttertoast.showToast(msg: "Authentication token missing");
        if (!mounted) return;
        setState(() {
          _loadMockData();
          _isLoading = false;
        });
        return;
      }

      // Make direct HTTP call instead of using ApiService
      final url = Uri.parse('https://grantoma.lt/api/vendor/dashboard');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("Direct API Response: $jsonResponse");

        if (jsonResponse['status'] == true) {
          final data = jsonResponse;

          print("=== DASHBOARD DATA RECEIVED ===");
          print("Total Products from API: ${data['products']?['total_products']}");
          print("Total Revenue from API: ${data['revenue']?['total_revenue']}");
          print("Total Orders from API: ${data['orders']?['total_orders']}");

          /// ----------- REVENUE -----------
          final revenue = data['revenue'] ?? {};
          int totalRevenue = int.tryParse(revenue['total_revenue']?.toString() ?? '0') ?? 0;
          int weeklyRevenue = int.tryParse(revenue['weekly_revenue']?.toString() ?? '0') ?? 0;
          int monthlyRevenue = int.tryParse(revenue['monthly_revenue']?.toString() ?? '0') ?? 0;
          int yearlyRevenue = int.tryParse(revenue['yearly_revenue']?.toString() ?? '0') ?? 0;
          List dailyRevenue = List.from(revenue['daily_revenue'] ?? []);

          /// ----------- ORDERS -----------
          final orders = data['orders'] ?? {};
          int totalOrders = int.tryParse(orders['total_orders']?.toString() ?? '0') ?? 0;
          List recentOrders = List.from(orders['recent_orders'] ?? []);

          // Sort orders by latest date
          recentOrders.sort((a, b) {
            DateTime dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
            DateTime dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
            return dateB.compareTo(dateA);
          });

          /// ----------- PRODUCTS -----------
          final products = data['products'] ?? {};
          int totalProducts = int.tryParse(products['total_products']?.toString() ?? '0') ?? 0;
          int outOfStock = int.tryParse(products['out_of_stock']?.toString() ?? '0') ?? 0;
          List allProducts = List.from(products['all_products'] ?? []);
          List mostPurchased = List.from(products['most_purchased'] ?? []);

          /// ----------- CUSTOMERS -----------
          final customers = data['customers'] ?? {};
          int totalCustomers = int.tryParse(customers['total_customers']?.toString() ?? '0') ?? 0;

          /// ----------- TODAY ORDERS -----------
          List todayOrders = List.from(data['today_orders'] ?? []);

          /// ----------- UPDATE UI -----------
          if (!mounted) return;

          setState(() {
            // Revenue
            _totalRevenue = totalRevenue;
            _weeklyRevenue = weeklyRevenue;
            _monthlyRevenue = monthlyRevenue;
            _yearlyRevenue = yearlyRevenue;
            _dailyRevenue = dailyRevenue;

            // Orders
            _totalOrders = totalOrders;
            _recentOrders = recentOrders;

            // Products
            _totalProducts = totalProducts;
            _outOfStock = outOfStock;
            _allProducts = allProducts;
            _mostPurchasedProducts = mostPurchased;

            // Customers
            _totalCustomers = totalCustomers;

            // Today Orders
            _todayOrders = todayOrders;

            _isLoading = false;
          });

          Fluttertoast.showToast(
            msg: "Dashboard loaded: $_totalProducts products, $_totalOrders orders",
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          throw Exception("API returned status false");
        }
      } else {
        throw Exception("HTTP Error: ${response.statusCode}");
      }

    } catch (e) {
      print("Dashboard API Error: $e");
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loadMockData();
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: "Failed to load dashboard. Showing sample data.");
    }
  }


  String formatRevenue(dynamic revenue) {
    if (revenue == null) return 'c. 0';
    num rev = revenue is num ? revenue : num.tryParse(revenue.toString()) ?? 0;
    return 'c. ${NumberFormat('#,##0').format(rev)}';
  }

  String getPeriodRevenue() {
    switch (_selectedPeriod) {

      case 'daily':
        int dailyTotal = _dailyRevenue.fold(
            0, (sum, item) => sum + (item is int ? item : int.tryParse(item.toString()) ?? 0));
        return formatRevenue(dailyTotal);

      case 'weekly':
        return formatRevenue(_weeklyRevenue);

      case 'monthly':
        return formatRevenue(_monthlyRevenue);

      case 'yearly':
        return formatRevenue(_yearlyRevenue);

      default:
        return formatRevenue(_totalRevenue);
    }
  }

  String _getProductImageUrl(String? imageName) {
    if (imageName == null || imageName.isEmpty) {
      return 'https://via.placeholder.com/150';
    }

    return 'https://grantoma.lt/assets/product_images/$imageName';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchDashboardData,
        color: scheme.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading dashboard...',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 20),
          _buildPeriodFilter(),
          const SizedBox(height: 20),
          _buildMetricsGrid(),
          const SizedBox(height: 24),

          if (_dailyRevenue.isNotEmpty) ...[
            sectionTitle('Revenue Trend'),
            const SizedBox(height: 12),
            _buildSimpleRevenueChart(),
            const SizedBox(height: 24),
          ],

          if (_todayOrders.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sectionTitle("Today's Orders"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_todayOrders.length} orders',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTodayOrders(),
            const SizedBox(height: 24),
          ],

          if (_mostPurchasedProducts.isNotEmpty) ...[
            sectionTitle('Most Purchased Products'),
            const SizedBox(height: 12),
            _buildMostPurchasedProducts(),
            const SizedBox(height: 24),
          ],

          if (_recentOrders.isNotEmpty) ...[
            sectionTitle('Recent Orders'),
            const SizedBox(height: 12),
            _buildRecentOrders(),
            const SizedBox(height: 24),
          ],

          if (_outOfStock > 0) _buildLowStockAlert(),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.store, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $username!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _profileStatusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _profileStatusMessage,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Revenue',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getPeriodRevenue(),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Orders',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_totalOrders',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildFilterChip('Daily', 'daily', scheme),
          _buildFilterChip('Weekly', 'weekly', scheme),
          _buildFilterChip('Monthly', 'monthly', scheme),
          _buildFilterChip('Yearly', 'yearly', scheme),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, ColorScheme scheme) {
    final isSelected = _selectedPeriod == value;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (mounted) setState(() => _selectedPeriod = value);
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6, // Increased to fix overflow
      children: [
        _buildMetricCard(
          icon: Icons.attach_money,
          iconColor: Colors.green,
          title: 'Revenue',
          value: getPeriodRevenue(),
          bgColor: Colors.green.withOpacity(0.1),
        ),
        _buildMetricCard(
          icon: Icons.shopping_bag_outlined,
          iconColor: Colors.blue,
          title: 'Orders',
          value: '$_totalOrders',
          bgColor: Colors.blue.withOpacity(0.1),
        ),
        _buildMetricCard(
          icon: Icons.people_outline,
          iconColor: Colors.purple,
          title: 'Customers',
          value: '$_totalCustomers',
          bgColor: Colors.purple.withOpacity(0.1),
        ),
        _buildMetricCard(
          icon: Icons.inventory_outlined,
          iconColor: Colors.orange,
          title: 'Products',
          value: '$_totalProducts',
          subtitle: '$_outOfStock low stock',
          bgColor: Colors.orange.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? subtitle,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6), // Smaller padding
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconColor, size: 16), // Smaller icon
          ),
          const SizedBox(height: 8), // Reduced spacing
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Smaller text
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  Widget _buildSimpleRevenueChart() {
    if (_dailyRevenue.isEmpty) return const SizedBox();

    double maxValue = _dailyRevenue.isNotEmpty
        ? _dailyRevenue.reduce((a, b) => a > b ? a : b).toDouble()
        : 100;
    if (maxValue == 0) maxValue = 100;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_dailyRevenue.length, (index) {
                double barHeight = (_dailyRevenue[index] / maxValue) * 150;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'c. ${NumberFormat.compact().format(_dailyRevenue[index])}',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: barHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Day ${index + 1}', style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayOrders() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _todayOrders.length,
        itemBuilder: (context, index) {
          final order = _todayOrders[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['status_id']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.shopping_bag, size: 14, color: _getStatusColor(order['status_id'])),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('#${order['id']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
                Text(
                  'c. ${NumberFormat('#,##0').format(double.tryParse(order['total_amount'].toString()) ?? 0)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status_id']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order['status_id']),
                    style: TextStyle(fontSize: 10, color: _getStatusColor(order['status_id']), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentOrders() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentOrders.length > 5 ? 5 : _recentOrders.length,
      itemBuilder: (context, index) {
        final order = _recentOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(order['status_id']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.receipt, size: 16, color: _getStatusColor(order['status_id'])),
              ),
              const SizedBox(width: 12),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order['id']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'c. ${order['total_amount']} • ${order['payment_type']?.toUpperCase()}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order['status_id']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(order['status_id']),
                  style: TextStyle(fontSize: 10, color: _getStatusColor(order['status_id'])),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMostPurchasedProducts() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mostPurchasedProducts.length,
        itemBuilder: (context, index) {
          final item = _mostPurchasedProducts[index];
          final product = item['product'] ?? {};
          final totalSold = item['total_sold'] ?? '0';

          String imageUrl = '';
          if (product['primary_image'] != null &&
              product['primary_image']['image'] != null &&
              product['primary_image']['image'].isNotEmpty) {
            imageUrl = _getProductImageUrl(product['primary_image']['image']);
          }

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print("Image error for ${product['name']}: $error");
                        return Container(
                          color: Colors.grey.shade200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey.shade400, size: 30),
                              Text('Error', style: TextStyle(fontSize: 8, color: Colors.grey.shade500)),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                        : Icon(Icons.image, color: Colors.grey.shade400, size: 40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? 'Product',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalSold sold',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLowStockAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Low Stock Alert', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange)),
                Text(
                  '$_outOfStock product${_outOfStock > 1 ? 's are' : ' is'} running low on stock',
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('View')),
        ],
      ),
    );
  }

  String _getStatusText(int statusId) {
    switch(statusId) {
      case 1: return 'Pending';
      case 2: return 'Confirmed';
      case 3: return 'Processing';
      case 4: return 'Shipped';
      case 5: return 'Delivered';
      case 6: return 'Cancelled';
      default: return 'Unknown';
    }
  }

  Color _getStatusColor(int statusId) {
    switch(statusId) {
      case 1: return Colors.orange;
      case 2: return Colors.blue;
      case 3: return Colors.purple;
      case 4: return Colors.indigo;
      case 5: return Colors.green;
      case 6: return Colors.red;
      default: return Colors.grey;
    }
  }
}