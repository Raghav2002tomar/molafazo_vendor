// VariantManagerScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contreller.dart';
import 'model.dart';

class VariantManagerScreen extends StatefulWidget {
  final AddProductControllernew controller;
  const VariantManagerScreen({super.key, required this.controller});

  @override
  State<VariantManagerScreen> createState() => _VariantManagerScreenState();
}

class _VariantManagerScreenState extends State<VariantManagerScreen> {
  String? _currentEditingVariantType;
  final TextEditingController _customVariantNameController = TextEditingController();
  final TextEditingController _customVariantValueController = TextEditingController();
  bool _isCustomVariantTypeActive = false;
  bool _isCustomValueActive = false;
  String? _currentVariantForCustomValue;
  final List<String> _tempCustomValues = [];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Consumer<AddProductControllernew>(
        builder: (context, c, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              title: const Text(
                'Manage Variants',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context, true),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: const Text('Done', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Variants',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure product variants by selecting options below',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _buildAddNewVariantSection(c),
                  const SizedBox(height: 16),
                  if (c.selectedVariants.any((v) => v.values.isNotEmpty))
                    _buildSelectedVariantsSummary(c),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddNewVariantSection(AddProductControllernew c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.add_circle, color: Colors.black, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'Add New Variant',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVariantTypeSelector(c),
          const SizedBox(height: 12),
          if (_isCustomVariantTypeActive)
            _buildCustomVariantTypeInput(c),
          if (_currentEditingVariantType != null || _isCustomVariantTypeActive)
            _buildVariantValueSection(c),
          const SizedBox(height: 12),
          if (_currentEditingVariantType != null || _isCustomVariantTypeActive)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveCurrentVariant(c),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text('Done Adding This Variant', style: TextStyle(fontSize: 13)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVariantTypeSelector(AddProductControllernew c) {
    final selectedAttributeNames = c.selectedVariants
        .where((v) => v.values.isNotEmpty)
        .map((v) => v.attributeName)
        .toList();

    final availableAttributes = c.attributes
        .where((attr) => !selectedAttributeNames.contains(attr.name))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Variant Type:',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),

        InkWell(
          onTap: () {
            setState(() {
              _isCustomVariantTypeActive = true;
              _currentEditingVariantType = null;
              _tempCustomValues.clear();
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isCustomVariantTypeActive ? Colors.black : Colors.grey.shade300,
                width: _isCustomVariantTypeActive ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(6),
              color: _isCustomVariantTypeActive ? Colors.black.withOpacity(0.02) : Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: _isCustomVariantTypeActive ? Colors.black : Colors.grey.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '+ Add Custom Variant Type',
                  style: TextStyle(
                    color: _isCustomVariantTypeActive ? Colors.black : Colors.grey.shade700,
                    fontWeight: _isCustomVariantTypeActive ? FontWeight.w500 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 4),

        ...availableAttributes.map((attr) => InkWell(
          onTap: () {
            setState(() {
              _currentEditingVariantType = attr.name;
              _isCustomVariantTypeActive = false;
              _currentVariantForCustomValue = attr.name;
              _tempCustomValues.clear();
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: _currentEditingVariantType == attr.name ? Colors.black : Colors.grey.shade300,
                width: _currentEditingVariantType == attr.name ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(6),
              color: _currentEditingVariantType == attr.name ? Colors.black.withOpacity(0.02) : Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.label_outline,
                  color: _currentEditingVariantType == attr.name ? Colors.black : Colors.grey.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attr.name,
                        style: TextStyle(
                          color: _currentEditingVariantType == attr.name ? Colors.black : Colors.grey.shade700,
                          fontWeight: _currentEditingVariantType == attr.name ? FontWeight.w500 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${attr.values.length} values',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )).toList(),

        if (availableAttributes.isEmpty && !_isCustomVariantTypeActive)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'All variant types are already selected',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),

        if (c.loadingAttributes)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildCustomVariantTypeInput(AddProductControllernew c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _customVariantNameController,
            style: const TextStyle(color: Colors.black, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Custom Variant Name',
              labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              hintText: 'e.g., Size, Material, Pattern',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _currentVariantForCustomValue = value;
              });
            },
          ),
          const SizedBox(height: 8),
          if (_tempCustomValues.isNotEmpty) ...[
            const Text(
              'Added Values:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tempCustomValues.map((value) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(value, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _tempCustomValues.remove(value);
                          });
                        },
                        child: const Icon(Icons.close, size: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariantValueSection(AddProductControllernew c) {
    String? variantName = _isCustomVariantTypeActive
        ? _customVariantNameController.text
        : _currentEditingVariantType;

    if (variantName == null || variantName.isEmpty) {
      return const SizedBox.shrink();
    }

    AttributeModel? currentAttribute;
    List<AttributeValue> availableAttributeValues = [];

    if (!_isCustomVariantTypeActive) {
      try {
        currentAttribute = c.attributes.firstWhere(
              (attr) => attr.name == variantName,
        );
        availableAttributeValues = currentAttribute.values;
      } catch (e) {
        currentAttribute = AttributeModel(id: 0, name: variantName, values: []);
      }
    }

    final selectedVariant = !_isCustomVariantTypeActive
        ? c.selectedVariants.firstWhere(
          (v) => v.attributeName == variantName,
      orElse: () => SelectedVariant(
        attributeName: variantName,
        values: [],
        isCustomAttribute: false,
        attributeId: currentAttribute?.id,
      ),
    )
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Values for: $variantName',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    if (!_isCustomVariantTypeActive && currentAttribute?.id != 0)
                      Text(
                        'ID: ${currentAttribute?.id}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _isCustomVariantTypeActive
                      ? '${_tempCustomValues.length} selected'
                      : '${selectedVariant?.values.length ?? 0} selected',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (!_isCustomValueActive)
            InkWell(
              onTap: () {
                setState(() {
                  _isCustomValueActive = true;
                  _currentVariantForCustomValue = variantName;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_circle_outline, color: Colors.black, size: 14),
                    SizedBox(width: 4),
                    Text('Add New Value', style: TextStyle(color: Colors.black, fontSize: 12)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          if (_isCustomValueActive && _currentVariantForCustomValue == variantName)
            _buildCustomValueInput(c, variantName, currentAttribute),

          if (!_isCustomVariantTypeActive && availableAttributeValues.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Available Values:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: availableAttributeValues.map((attrValue) {
                final isSelected = selectedVariant?.values
                    .any((v) => v.value == attrValue.value) ?? false;

                return FilterChip(
                  label: Text(
                    attrValue.value,
                    style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : Colors.black
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    c.toggleVariantValue(
                      variantName!,
                      attrValue.value,
                      isCustom: false,
                      attributeId: currentAttribute?.id,
                      valueId: attrValue.id,
                    );
                    setState(() {});
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.black,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  tooltip: 'ID: ${attrValue.id}',
                );
              }).toList(),
            ),
          ],

          if (!_isCustomVariantTypeActive &&
              selectedVariant != null &&
              selectedVariant.values.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Selected Values:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selectedVariant.values.map((value) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: value.isCustom
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: value.isCustom
                          ? Colors.orange.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value.value,
                        style: TextStyle(
                          fontSize: 12,
                          color: value.isCustom ? Colors.orange.shade900 : Colors.black,
                        ),
                      ),
                      if (!value.isCustom && value.valueId != null) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ID: ${value.valueId}',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                      if (value.isCustom) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Custom',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          c.toggleVariantValue(
                            variantName!,
                            value.value,
                            isCustom: value.isCustom,
                            attributeId: selectedVariant.attributeId,
                            valueId: value.valueId,
                          );
                          setState(() {});
                        },
                        child: const Icon(Icons.close, size: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          if (_isCustomVariantTypeActive && _tempCustomValues.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Added Values:',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tempCustomValues.map((value) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Custom',
                          style: TextStyle(fontSize: 8, color: Colors.orange),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _tempCustomValues.remove(value);
                          });
                        },
                        child: const Icon(Icons.close, size: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomValueInput(AddProductControllernew c, String variantName, AttributeModel? attribute) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customVariantValueController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Enter value',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    border: InputBorder.none,
                    // contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onFieldSubmitted: (value) {
                    _addValue(c, variantName, attribute);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.black, size: 22),
                onPressed: () {
                  _addValue(c, variantName, attribute);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black54, size: 22),
                onPressed: () {
                  setState(() {
                    _isCustomValueActive = false;
                    _customVariantValueController.clear();
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          if (attribute != null && attribute.id != 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tip: Select from available values above for preset options',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addValue(AddProductControllernew c, String variantName, AttributeModel? attribute) {
    String value = _customVariantValueController.text.trim();
    if (value.isEmpty) return;

    if (_isCustomVariantTypeActive) {
      setState(() {
        _tempCustomValues.add(value);
        _customVariantValueController.clear();
      });
      _showSnackBar('Custom value added: $value');
    } else {
      if (attribute != null && attribute.id != 0) {
        try {
          final presetValue = attribute.values.firstWhere(
                (v) => v.value.toLowerCase() == value.toLowerCase(),
          );

          c.toggleVariantValue(
            variantName,
            value,
            isCustom: false,
            attributeId: attribute.id,
            valueId: presetValue.id,
          );
          _showSnackBar('Preset value added: $value (ID: ${presetValue.id})');
        } catch (e) {
          c.toggleVariantValue(
            variantName,
            value,
            isCustom: true,
            attributeId: attribute.id,
          );
          _showSnackBar('Custom value added: $value');
        }
      } else {
        c.toggleVariantValue(variantName, value, isCustom: true);
        _showSnackBar('Value added: $value');
      }
      _customVariantValueController.clear();
    }
  }

  void _saveCurrentVariant(AddProductControllernew c) {
    if (_isCustomVariantTypeActive) {
      String customName = _customVariantNameController.text.trim();
      if (customName.isNotEmpty && _tempCustomValues.isNotEmpty) {
        for (String value in _tempCustomValues) {
          c.toggleVariantValue(customName, value, isCustom: true);
        }
        _showSnackBar('Custom variant "${customName}" added successfully');
      } else if (customName.isEmpty) {
        _showSnackBar('Please enter a variant name');
        return;
      } else if (_tempCustomValues.isEmpty) {
        _showSnackBar('Please add at least one value');
        return;
      }
    }

    setState(() {
      _currentEditingVariantType = null;
      _isCustomVariantTypeActive = false;
      _isCustomValueActive = false;
      _currentVariantForCustomValue = null;
      _customVariantNameController.clear();
      _customVariantValueController.clear();
      _tempCustomValues.clear();
    });

    c.autoGenerateCombinations();
  }

  Widget _buildSelectedVariantsSummary(AddProductControllernew c) {
    final selectedVariants = c.selectedVariants
        .where((v) => v.values.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.black, size: 16),
              const SizedBox(width: 6),
              Text(
                'Selected Variants (${selectedVariants.length})',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...selectedVariants.map((v) {
            int customCount = v.values.where((val) => val.isCustom).length;
            int presetCount = v.values.length - customCount;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              v.attributeName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12
                              ),
                            ),
                            const SizedBox(width: 4),
                            if (v.isCustomAttribute) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  'Custom Type',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ] else if (v.attributeId != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  'ID: ${v.attributeId}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 2),

                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: v.values.map((val) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: val.isCustom
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    val.value,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: val.isCustom
                                          ? Colors.orange.shade700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                  if (!val.isCustom && val.valueId != null) ...[
                                    const SizedBox(width: 2),
                                    Text(
                                      '(${val.valueId})',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.green.shade500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                        if (presetCount > 0 || customCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${presetCount} preset, ${customCount} custom',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.black54, size: 16),
                    onPressed: () {
                      c.removeVariant(v.attributeName);
                      setState(() {});
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13)),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  void dispose() {
    _customVariantNameController.dispose();
    _customVariantValueController.dispose();
    super.dispose();
  }
}