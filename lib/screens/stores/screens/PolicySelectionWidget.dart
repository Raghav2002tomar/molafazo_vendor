import 'package:flutter/material.dart';

class PolicySelectionWidget extends StatefulWidget {
  final Map<String, dynamic>? initialPolicy;
  final Function(Map<String, dynamic>?) onPolicyChanged;

  const PolicySelectionWidget({
    super.key,
    this.initialPolicy,
    required this.onPolicyChanged,
  });

  @override
  State<PolicySelectionWidget> createState() => _PolicySelectionWidgetState();
}

class _PolicySelectionWidgetState extends State<PolicySelectionWidget> {
  String? _selectedPolicyType;
  int? _returnDays;
  final TextEditingController _daysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing policy if available
    if (widget.initialPolicy != null && widget.initialPolicy!.isNotEmpty) {
      final policy = widget.initialPolicy!;
      if (policy['type'] == 'no_return') {
        _selectedPolicyType = 'no_return';
      } else if (policy['type'] == 'supplier_return') {
        _selectedPolicyType = 'supplier_return';
        if (policy['days'] != null) {
          _returnDays = int.tryParse(policy['days'].toString());
          _daysController.text = policy['days'].toString();
        }
      }
    }
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  void _updatePolicy() {
    if (_selectedPolicyType == 'no_return') {
      widget.onPolicyChanged({
        'type': 'no_return',
        'message': 'This store does not accept returns.',
      });
    } else if (_selectedPolicyType == 'supplier_return' && _returnDays != null && _returnDays! > 0) {
      widget.onPolicyChanged({
        'type': 'supplier_return',
        'days': _returnDays,
        'message': 'Returns accepted up to $_returnDays days.',
      });
    } else if (_selectedPolicyType == null) {
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
          const Text(
            'Return Policy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // No Return Option
          RadioListTile<String>(
            title: const Text('No Returns Accepted'),
            subtitle: const Text(
              'Store does not accept returns',
              style: TextStyle(fontSize: 12),
            ),
            value: 'no_return',
            groupValue: _selectedPolicyType,
            onChanged: (value) {
              setState(() {
                _selectedPolicyType = value;
                _returnDays = null;
                _daysController.clear();
                _updatePolicy();
              });
            },
            activeColor: Colors.black,
            contentPadding: EdgeInsets.zero,
          ),

          // Supplier Return Option
          RadioListTile<String>(
            title: const Text('Supplier Return Policy'),
            subtitle: const Text(
              'Check with supplier for return policy',
              style: TextStyle(fontSize: 12),
            ),
            value: 'supplier_return',
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

          // Days Input (only shown when supplier_return is selected)
          if (_selectedPolicyType == 'supplier_return')
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Return period (days)',
                        hintText: 'e.g., 14',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _returnDays = int.tryParse(value);
                        } else {
                          _returnDays = null;
                        }
                        _updatePolicy();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'days',
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
                color: _selectedPolicyType == 'no_return'
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedPolicyType == 'no_return'
                      ? Colors.red.shade200
                      : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedPolicyType == 'no_return'
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline,
                    color: _selectedPolicyType == 'no_return'
                        ? Colors.red
                        : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedPolicyType == 'no_return'
                          ? 'This store does not accept returns.'
                          : 'Returns accepted up to $_returnDays days. Terms and conditions apply.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _selectedPolicyType == 'no_return'
                            ? Colors.red.shade800
                            : Colors.green.shade800,
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