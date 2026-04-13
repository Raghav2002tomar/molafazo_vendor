import 'package:flutter/material.dart';
import '../controller/vendor_api_service.dart';
import '../model/package_model.dart';
import 'payment_details_screen.dart';
import 'add_review_screen.dart';

class PackagesScreen extends StatefulWidget {
  final String token;
  final String productId;

  const PackagesScreen({
    Key? key,
    required this.token,
    required this.productId,
  }) : super(key: key);

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  List<PackageModel> _packages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await VendorApiService.getPackages(
        token: widget.token,
        pID: widget.productId
    );

    if (result['success'] == true) {
      List<dynamic> data = result['data'];
      setState(() {
        _packages = data.map((json) => PackageModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotion Packages'),
        // backgroundColor: Colors.deepPurple,
        // foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPackages,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchPackages, // Pull to refresh
        child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
            final package = _packages[index];
            return _buildPackageCard(package);
                    },
                  ),
          ),
    );
  }

  Widget _buildPackageCard(PackageModel package) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    package.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: package.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: package.statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(package.statusIcon, size: 16, color: package.statusColor),
                      const SizedBox(width: 4),
                      Text(
                        package.displayStatus,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: package.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reviews Count and Remaining Reviews Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${package.reviewCount} reviews',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (package.isApplied && package.isApproved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: package.remainingReviews > 0
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.reviews,
                          size: 16,
                          color: package.remainingReviews > 0 ? Colors.blue : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${package.remainingReviews} remaining',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: package.remainingReviews > 0 ? Colors.blue : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Price and Action Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Package Price',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      '\$${package.price}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                // Status-based Action Button
                _buildActionButton(package),
              ],
            ),

            // Show additional info for pending status
            if (package.isPending) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your request is pending admin approval. You will be notified once approved.',
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Show message when no remaining reviews
            if (package.isApproved && package.isApplied && package.remainingReviews == 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You have used all reviews for this package. Please select a new plan to continue.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(PackageModel package) {
    // Common button builder
    Widget buildButton({
      required String text,
      required IconData icon,
      required Color bgColor,
      required Color textColor,
      VoidCallback? onTap,
      bool isBorder = false,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isBorder ? Colors.transparent : bgColor,
            borderRadius: BorderRadius.circular(8),
            border: isBorder ? Border.all(color: Colors.grey.shade300) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Case 1: Approved + Applied + Has remaining reviews
// In _buildActionButton method, update the Case 1 section:
    if (package.canAddReview) {
      // Check if we have promotionRequestId
      if (package.promotionRequestId == null || package.promotionRequestId!.isEmpty) {
        return buildButton(
          text: 'Request ID Missing',
          icon: Icons.error_outline,
          bgColor: Colors.transparent,
          textColor: Colors.grey.shade600,
          onTap: null,
          isBorder: true,
        );
      }

      return buildButton(
        text: 'Add Review (${package.remainingReviews} left)',
        icon: Icons.rate_review,
        bgColor: Colors.green,
        textColor: Colors.white,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddReviewScreen(
                token: widget.token,
                promotionRequestId: package.promotionRequestId!,
                packageTitle: package.title,
              ),
            ),
          );
          _fetchPackages(); // Refresh after returning
        },
      );
    }

    // Case 2: Approved + Applied + No remaining reviews - Show Select Plan
    else if (package.isApproved && package.isApplied && package.remainingReviews == 0) {
      return buildButton(
        text: 'Select New Plan',
        icon: Icons.shopping_cart,
        bgColor: Colors.black,
        textColor: Colors.white,
        onTap: () => _selectPackage(package),
      );
    }

    // Case 3: Pending
    else if (package.isPending) {
      return buildButton(
        text: 'Pending Approval',
        icon: Icons.pending,
        bgColor: Colors.transparent,
        textColor: Colors.grey.shade600,
        onTap: null, // disabled
        isBorder: true,
      );
    }

    // Case 4: Default (Not applied or status is null)
    else {
      return buildButton(
        text: 'Select Plan',
        icon: Icons.shopping_cart,
        bgColor: Colors.black,
        textColor: Colors.white,
        onTap: () => _selectPackage(package),
      );
    }
  }

  void _selectPackage(PackageModel package) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailsScreen(
          token: widget.token,
          productId: widget.productId,
          packageId: package.id.toString(),
          packageTitle: package.title,
          packagePrice: package.price,
        ),
      ),
    ).then((_) {
      // Refresh packages when coming back from payment screen
      _fetchPackages();
    });
  }

  void _addReview(PackageModel package) {
    // Check if we have promotionRequestId
    if (package.promotionRequestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to add review: Promotion request ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate and wait for result
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(
          token: widget.token,
          promotionRequestId: package.promotionRequestId!,
          packageTitle: package.title,
        ),
      ),
    ).then((_) {
      // Refresh packages when coming back
      _fetchPackages();
    });
  }
}