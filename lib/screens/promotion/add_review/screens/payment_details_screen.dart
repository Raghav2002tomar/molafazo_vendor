import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../extensions/context_extension.dart';
import '../controller/vendor_api_service.dart';
import '../model/payment_details_model.dart';
import 'promotion_request_screen.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String token;
  final String productId;
  final String packageId;
  final String packageTitle;
  final String packagePrice;

  const PaymentDetailsScreen({
    Key? key,
    required this.token,
    required this.productId,
    required this.packageId,
    required this.packageTitle,
    required this.packagePrice,
  }) : super(key: key);

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  PaymentDetailsModel? _paymentDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPaymentDetails();
  }

  Future<void> _fetchPaymentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await VendorApiService.getPaymentDetails(
      token: widget.token,
    );

    if (result['status'] == true ||result['success'] == true) {
      setState(() {
        _paymentDetails = PaymentDetailsModel.fromJson(result['data']);
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
        title: Text(context.tr('txt_payment_details')),
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
              onPressed: _fetchPaymentDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelectedPackageCard(),
            const SizedBox(height: 24),
            _buildPaymentInfoCard(),
            const SizedBox(height: 24),
            _buildInstructionsCard(),
            const SizedBox(height: 32),
            _buildProceedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPackageCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.deepPurple.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(context.tr('txt_selected_package'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.packageTitle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${widget.packagePrice}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                Icon(Icons.payment, color: Colors.black),
                SizedBox(width: 8),
          Text(context.tr('txt_admin_payment_details'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(context.tr('txt_account_name'), _paymentDetails!.accountName),
            _buildInfoRow(context.tr('txt_account_number'), _paymentDetails!.accountNumber),
            _buildInfoRow(context.tr('txt_ifsc_code'), _paymentDetails!.ifsc),
            _buildInfoRow(context.tr('txt_upi_id'), _paymentDetails!.upiId),
            const SizedBox(height: 16),
            if (_paymentDetails!.qrCode.isNotEmpty)
              Column(
                children: [
              Text(context.tr('txt_scan_qr_code'),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      _paymentDetails!.fullQrCodeUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 8),
          Text(context.tr('txt_instructions'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(context.tr('txt_instruction_1')),
            Text(context.tr('txt_instruction_2')),
            Text(context.tr('txt_instruction_3')),
            Text(context.tr('txt_instruction_4'))
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _proceedToUpload,
        icon: const Icon(Icons.upload_file),
        label: Text(context.tr('txt_proceed_upload_screenshot')),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _proceedToUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromotionRequestScreen(
          token: widget.token,
          productId: widget.productId,
          packageId: widget.packageId,
          packageTitle: widget.packageTitle,
          packagePrice: widget.packagePrice,
          paymentDetails: _paymentDetails!,
        ),
      ),
    );
  }
}