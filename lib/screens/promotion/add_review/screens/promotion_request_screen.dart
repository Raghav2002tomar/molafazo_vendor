import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:molafzo_vendor/screens/promotion/add_review/screens/packages_screen.dart';
import '../../../../extensions/context_extension.dart';
import '../controller/vendor_api_service.dart';
import '../model/payment_details_model.dart';

class PromotionRequestScreen extends StatefulWidget {
  final String token;
  final String productId;
  final String packageId;
  final String packageTitle;
  final String packagePrice;
  final PaymentDetailsModel paymentDetails;

  const PromotionRequestScreen({
    Key? key,
    required this.token,
    required this.productId,
    required this.packageId,
    required this.packageTitle,
    required this.packagePrice,
    required this.paymentDetails,
  }) : super(key: key);

  @override
  State<PromotionRequestScreen> createState() => _PromotionRequestScreenState();
}

class _PromotionRequestScreenState extends State<PromotionRequestScreen> {
  File? _screenshot;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickScreenshot() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        _screenshot = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      setState(() {
        _screenshot = File(image.path);
      });
    }
  }

  Future<void> _submitPromotionRequest() async {
    if (_screenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('txt_payment_screenshot_required'))),      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final result = await VendorApiService.submitPromotionRequest(
        token: widget.token,
        productId: widget.productId,
        packageId: widget.packageId,
        screenshotImage: _screenshot!,
      );

      setState(() {
        _isUploading = false;
      });

      if (result['success'] == true) {
        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title:  Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(context.tr('txt_success_title'))
                ],
              ),
              content:  Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.tr('txt_promotion_submitted_success')),
                  SizedBox(height: 16),
                  Text(context.tr('txt_next_steps'),

            style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(context.tr('txt_wait_admin_approval')),
                  Text(context.tr('txt_notified_when_approved')),
                  Text(context.tr('txt_then_add_review'))
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    _navigateToPackagesScreen();
                  },
                  child: Text(context.tr('txt_ok'))
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? context.tr('txt_submission_failed')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr('txt_error_prefix')}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToPackagesScreen() {
    // Clear all routes and navigate to PackagesScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => PackagesScreen(
          token: widget.token,
          productId: widget.productId,
        ),
      ),
          (Route<dynamic> route) => false, // This removes all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When back button is pressed, go to PackagesScreen
        _navigateToPackagesScreen();
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('txt_upload_payment_screenshot')),          // backgroundColor: Colors.deepPurple,
          // foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _navigateToPackagesScreen();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              _buildScreenshotUploader(),
              const SizedBox(height: 24),
              _buildPaymentReminder(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(context.tr('txt_payment_summary'),

        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildSummaryRow(context.tr('txt_package'), widget.packageTitle.toUpperCase()),
            _buildSummaryRow(context.tr('txt_amount'), '\$${widget.packagePrice}'),
            _buildSummaryRow(
              context.tr('txt_pay_to'),
              widget.paymentDetails.accountName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotUploader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(context.tr('txt_upload_payment_screenshot'),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showImageSourceDialog(),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: _screenshot != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _screenshot!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 48,
                      color: Colors.black54,
                    ),
                    const SizedBox(height: 8),
                  Text(context.tr('txt_tap_upload_screenshot'),
                  style: TextStyle(color: Colors.grey),
                    ),
                  Text(context.tr('txt_jpg_png_accepted'),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            if (_screenshot != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _screenshot = null;
                      });
                    },
                    icon: const Icon(Icons.delete, size: 16),
    label: Text(context.tr('txt_remove')),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentReminder() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
                context.tr('txt_screenshot_clear_message'),
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _submitPromotionRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isUploading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(context.tr('txt_submit_promotion_request'),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.tr('txt_choose_from_gallery')),
            onTap: () {
                  Navigator.pop(context);
                  _pickScreenshot();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(context.tr('txt_take_photo')),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}