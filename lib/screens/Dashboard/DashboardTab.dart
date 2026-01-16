import 'package:flutter/material.dart';

import '../products/screens/add_product_basic_info.dart';
import '../stores/screens/add_store_screen.dart';

class DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Quick Actions
            _buildHeader(context, scheme, textTheme),
            const SizedBox(height: 24),

            // Quick Action Buttons
            _buildQuickActions(context, scheme),
            const SizedBox(height: 24),

            // Metrics Grid
            Text(
              'Today\'s Overview',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildMetricsGrid(scheme),
            const SizedBox(height: 24),

            // Revenue Chart
            _buildRevenueChart(context, scheme, textTheme),
            const SizedBox(height: 24),

            // Two Column Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTopProducts(context, scheme, textTheme)),
                const SizedBox(width: 16),
                Expanded(child: _buildRecentOrders(context, scheme, textTheme)),
              ],
            ),
            const SizedBox(height: 24),

            // Low Stock Alert
            _buildLowStockAlert(context, scheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withOpacity(0.85)],
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.store, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Raghav!',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your store efficiently',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // IconButton(
          //   icon: Icon(Icons.notifications_outlined, color: Colors.white),
          //   onPressed: () {},
          // ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_box,
            label: 'Add Product',
            color: scheme.primary,
            onTap: () {


              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddProductBasicInfo()));

              // Navigate to add product screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Add Product clicked')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.store_outlined,
            label: 'Manage Store',
            color: scheme.secondary,
            onTap: () {
              // Navigate to store settings
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddStoreScreen()));
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('Manage Store clicked')),
              // );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            color: scheme.tertiary,
            onTap: () {
              // Navigate to inventory
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Inventory clicked')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(ColorScheme scheme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _MetricCard(
          icon: Icons.attach_money,
          title: 'Revenue',
          value: '₹1,23,456',
          change: '+12.5%',
          isPositive: true,
          color: scheme.primary,
        ),
        _MetricCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Orders',
          value: '45',
          change: '+8.0%',
          isPositive: true,
          color: scheme.secondary,
        ),
        _MetricCard(
          icon: Icons.people_outline,
          title: 'Customers',
          value: '128',
          change: '+3.2%',
          isPositive: true,
          color: scheme.tertiary,
        ),
        _MetricCard(
          icon: Icons.inventory_outlined,
          title: 'Products',
          value: '256',
          change: '-2',
          isPositive: false,
          color: Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildRevenueChart(BuildContext context, ColorScheme scheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue Trend',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This Week',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withOpacity(0.3),
                  scheme.secondary.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.show_chart,
                size: 48,
                color: scheme.primary.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Weekly', '₹56,789', textTheme, scheme),
              Container(width: 1, height: 30, color: scheme.outlineVariant),
              _buildStatColumn('Monthly', '₹2,43,567', textTheme, scheme),
              Container(width: 1, height: 30, color: scheme.outlineVariant),
              _buildStatColumn('Yearly', '₹28,45,678', textTheme, scheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, TextTheme textTheme, ColorScheme scheme) {
    return Column(
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTopProducts(BuildContext context, ColorScheme scheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Products',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Icon(Icons.trending_up, color: scheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          _ProductItem(
            name: 'iPhone 15 Pro',
            sales: '23',
            revenue: '₹34,500',
            iconColor: scheme.primary,
            icon: Icons.phone_iphone,
          ),
          const SizedBox(height: 8),
          _ProductItem(
            name: 'MacBook Air M2',
            sales: '15',
            revenue: '₹1,23,000',
            iconColor: scheme.secondary,
            icon: Icons.laptop_mac,
          ),
          const SizedBox(height: 8),
          _ProductItem(
            name: 'AirPods Pro',
            sales: '31',
            revenue: '₹24,800',
            iconColor: scheme.tertiary,
            icon: Icons.headphones,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context, ColorScheme scheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Orders',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Icon(Icons.receipt_long, color: scheme.secondary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          _OrderItem(
            orderId: '#2145',
            status: 'Delivered',
            amount: '₹2,450',
            statusColor: Colors.green,
            scheme: scheme,
          ),
          const SizedBox(height: 8),
          _OrderItem(
            orderId: '#2144',
            status: 'Processing',
            amount: '₹1,890',
            statusColor: Colors.orange,
            scheme: scheme,
          ),
          const SizedBox(height: 8),
          _OrderItem(
            orderId: '#2143',
            status: 'Shipped',
            amount: '₹3,200',
            statusColor: Colors.blue,
            scheme: scheme,
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert(BuildContext context, ColorScheme scheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Low Stock Alert',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
                Text(
                  '5 products are running low on stock',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('View'),
          ),
        ],
      ),
    );
  }
}

// Quick Action Button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Metric Card
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Product Item
class _ProductItem extends StatelessWidget {
  final String name;
  final String sales;
  final String revenue;
  final Color iconColor;
  final IconData icon;

  const _ProductItem({
    required this.name,
    required this.sales,
    required this.revenue,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$sales sales • $revenue',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Order Item
class _OrderItem extends StatelessWidget {
  final String orderId;
  final String status;
  final String amount;
  final Color statusColor;
  final ColorScheme scheme;

  const _OrderItem({
    required this.orderId,
    required this.status,
    required this.amount,
    required this.statusColor,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt, color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderId,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container(
                  //   width: 6,
                  //   height: 6,
                  //   decoration: BoxDecoration(
                  //     color: statusColor,
                  //     shape: BoxShape.circle,
                  //   ),
                  // ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$amount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}