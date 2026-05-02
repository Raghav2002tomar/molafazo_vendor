import 'package:flutter/material.dart';

import '../../../extensions/context_extension.dart';

class DeliveryPolicyWidget extends StatefulWidget {
  final Map<String, dynamic>? initialPolicy;
  final String? initialDays;
  final Function(Map<String, dynamic>?) onPolicyChanged;
  final Function(String) onDaysChanged;

  const DeliveryPolicyWidget({
    super.key,
    this.initialPolicy,
    this.initialDays,
    required this.onPolicyChanged,
    required this.onDaysChanged,
  });

  @override
  State<DeliveryPolicyWidget> createState() => _DeliveryPolicyWidgetState();
}

class _DeliveryPolicyWidgetState extends State<DeliveryPolicyWidget> {
  String? _selectedPolicyType;
  String _deliveryDays = '3-5';
  final TextEditingController _daysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing policy if available
    if (widget.initialPolicy != null && widget.initialPolicy!.isNotEmpty) {
      final policy = widget.initialPolicy!;
      if (policy['type'] == 'standard') {
        _selectedPolicyType = 'standard';
        _deliveryDays = '3-5';
        _daysController.text = '3-5';
      } else if (policy['type'] == 'custom') {
        _selectedPolicyType = 'custom';
        if (policy['days'] != null) {
          _deliveryDays = policy['days'].toString();
          _daysController.text = policy['days'].toString();
        }
      }
    } else if (widget.initialDays != null && widget.initialDays!.isNotEmpty) {
      _selectedPolicyType = 'custom';
      _deliveryDays = widget.initialDays!;
      _daysController.text = widget.initialDays!;
    }

    // Don't call _updatePolicy here, let the parent handle it
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  void _updatePolicy() {
    if (_selectedPolicyType == 'standard') {
      widget.onPolicyChanged({
        'type': 'standard',
        'message': context.tr('txt_standard_delivery_message'),
        'days': '3-5',
      });
      widget.onDaysChanged('3-5');
    } else if (_selectedPolicyType == 'custom' && _deliveryDays.isNotEmpty) {
      widget.onPolicyChanged({
        'type': 'custom',
        'message': context.tr('txt_delivery_in_days').replaceAll('{days}', _deliveryDays),
        'days': _deliveryDays,
      });
      widget.onDaysChanged(_deliveryDays);
    } else {
      widget.onPolicyChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(context.tr('txt_delivery_policy_title'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Standard Delivery Option
          RadioListTile<String>(
            title: Text(context.tr('txt_standard_delivery')),
            subtitle: Text(context.tr('txt_free_shipping_above'),
              style: TextStyle(fontSize: 12),
            ),
            value: 'standard',
            groupValue: _selectedPolicyType,
            onChanged: (value) {
              setState(() {
                _selectedPolicyType = value;
                _deliveryDays = '3-5';
                _daysController.text = '3-5';
                _updatePolicy();
              });
            },
            activeColor: Colors.black,
            contentPadding: EdgeInsets.zero,
          ),

          // Custom Delivery Option
          RadioListTile<String>(
            title: Text(context.tr('txt_custom_delivery_timeline')),
            subtitle:  Text(
              context.tr('txt_set_own_delivery_days'),
              style: TextStyle(fontSize: 12),
            ),
            value: 'custom',
            groupValue: _selectedPolicyType,
            onChanged: (value) {
              setState(() {
                _selectedPolicyType = value;
                _updatePolicy();
              });
            },
            activeColor: Colors.black,
            contentPadding: EdgeInsets.zero,
          ),

          // Days Input (only shown when custom is selected)
          if (_selectedPolicyType == 'custom')
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _daysController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: context.tr('txt_delivery_timeline'),
                        hintText: context.tr('txt_delivery_hint'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        _deliveryDays = value;
                        _updatePolicy();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                   Text(
    context.tr('txt_days'),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

          // Show policy message preview
          if (_selectedPolicyType != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedPolicyType == 'standard'
                          ? context.tr('txt_standard_delivery_message')
                          : context.tr('txt_delivery_in_days').replaceAll('{days}', _deliveryDays),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}