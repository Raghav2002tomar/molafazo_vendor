import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:molafzo_vendor/extensions/context_extension.dart';
import '../controller/enquiry_api_service.dart';
import '../model/enquiry_model.dart';


class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  final EnquiryApiService _api = EnquiryApiService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  bool _isLoading = true;
  List<EnquiryModel> _enquiries = [];

  @override
  void initState() {
    super.initState();
    _loadEnquiries();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadEnquiries() async {
    setState(() => _isLoading = true);

    try {
      final data = await _api.fetchEnquiries();
      setState(() {
        _enquiries = data;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: context.tr('txt_failed_to_load_enquiries'));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitEnquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final res = await _api.createEnquiry(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (res["success"] == true) {
        Fluttertoast.showToast(
          msg: res["message"]?.toString() ?? context.tr('txt_query_submitted'),
        );

        _titleController.clear();
        _descriptionController.clear();

        await _loadEnquiries();
      } else {
        Fluttertoast.showToast(
          msg: res["message"]?.toString() ?? context.tr('txt_failed_to_submit_query'),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: context.tr('txt_failed_to_submit_query'));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'answered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (_) {
      return raw;
    }
  }

  Widget _buildHeader(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.primary.withOpacity(0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.support_agent, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(
            context.tr('txt_support_queries'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('txt_send_question_to_admin'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('txt_create_new_query'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: context.tr('txt_title'),
                hintText: context.tr('txt_enter_query_title'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return context.tr('txt_title_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.tr('txt_description'),
                hintText: context.tr('txt_describe_your_problem'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return context.tr('txt_description_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitEnquiry,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  context.tr('txt_submit_query'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnquiryItem(EnquiryModel item) {
    final color = _statusColor(item.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status == 'answered'
                      ? context.tr('txt_answered')
                      : context.tr('txt_pending'),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${context.tr('txt_created')}: ${_formatDate(item.createdAt)}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          if ((item.answer ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('txt_admin_reply'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.answer ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_enquiries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                context.tr('txt_no_queries_found'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('txt_your_queries_will_appear_here'),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _enquiries.map(_buildEnquiryItem).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(context.tr('txt_support_queries')),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadEnquiries,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(scheme),
              const SizedBox(height: 16),
              _buildFormCard(scheme),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    context.tr('txt_my_queries'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildListSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}