import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';

class BankInfoScreen extends StatefulWidget {
  const BankInfoScreen({Key? key}) : super(key: key);

  @override
  State<BankInfoScreen> createState() => _BankInfoScreenState();
}

class _BankInfoScreenState extends State<BankInfoScreen> with SingleTickerProviderStateMixin {
  bool isCodSelected = false;
  bool isDigitalSelected = false;

  List<BankModel> apiBankList = [];
  List<SavedBankModel> savedBanks = [];

  bool isLoading = false;
  bool isSaving = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    fetchBanks();
    fetchPaymentDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchBanks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/vendor/banks"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        List list = data["data"];
        setState(() {
          apiBankList = list.map((e) => BankModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint("Bank fetch error: $e");
    }
  }

  Future<void> fetchPaymentDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token == null) return;

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/vendor/payment/details"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == true) {
        setState(() {
          List paymentModes = data["payment_modes"] ?? [];
          isCodSelected = paymentModes.contains("cod");
          isDigitalSelected = paymentModes.contains("bank");

          if (data["bank_details"] != null) {
            savedBanks = (data["bank_details"] as List)
                .map((bank) => SavedBankModel.fromJson(bank))
                .toList();
          }

          if (isDigitalSelected) {
            _animationController.forward();
          }
        });
      }
    } catch (e) {
      debugPrint("Payment details fetch error: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> savePaymentDetails() async {
    if (!isDigitalSelected && !isCodSelected) {
      _showSnackBar(
        "Please select at least one payment mode",
        Colors.orange,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('api_token');

    if (token == null) return;

    setState(() => isSaving = true);

    try {
      List<String> paymentModes = [];
      if (isCodSelected) paymentModes.add("cod");
      if (isDigitalSelected) paymentModes.add("bank");

      List<Map<String, dynamic>> banks = [];
      if (isDigitalSelected) {
        for (var bank in savedBanks) {
          banks.add({
            "bank_id": bank.bankId,
            "account_holder_name": bank.accountHolderName ?? "",
            "account_number": bank.accountNumber ?? "",
          });
        }
      }

      Map<String, dynamic> requestBody = {
        "payment_modes": paymentModes,
        "banks": banks,
      };

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/vendor/payment/save"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData["status"] == true) {
        await fetchPaymentDetails();
        _showSnackBar(
          responseData["message"] ?? "Payment details saved successfully",
          Colors.green,
        );
      } else {
        throw Exception(responseData["message"] ?? "Failed to save");
      }
    } catch (e) {
      debugPrint("Save error: $e");
      _showSnackBar(
        "Error: ${e.toString().replaceAll('Exception: ', '')}",
        Colors.red,
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openAddBankSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SelectBankSheet(
          bankList: apiBankList,
          onSave: (bank, accountNumber, accountHolderName) {
            setState(() {
              savedBanks.add(SavedBankModel(
                bankId: int.parse(bank.id),
                bankName: bank.name,
                bankLogo: bank.logo,
                accountNumber: accountNumber,
                accountHolderName: accountHolderName,
              ));
            });
          },
        ),
      ),
    );
  }

  void _removeBank(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Bank'),
        content: Text('Are you sure you want to remove ${savedBanks[index].bankName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                savedBanks.removeAt(index);
              });
              Navigator.pop(context);
              _showSnackBar('Bank removed successfully', Colors.green);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _editBank(int index) {
    final bank = savedBanks[index];
    final selectedApiBank = apiBankList.firstWhere(
          (b) => b.id == bank.bankId.toString(),
      orElse: () => BankModel(
        id: bank.bankId.toString(),
        name: bank.bankName,
        logo: bank.bankLogo,
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SelectBankSheet(
          bankList: apiBankList,
          initialBank: selectedApiBank,
          initialAccountNumber: bank.accountNumber,
          initialHolderName: bank.accountHolderName,
          onSave: (updatedBank, accountNumber, accountHolderName) {
            setState(() {
              savedBanks[index] = SavedBankModel(
                bankId: int.parse(updatedBank.id),
                bankName: updatedBank.name,
                bankLogo: updatedBank.logo,
                accountNumber: accountNumber,
                accountHolderName: accountHolderName,
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Account Management",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: (isSaving || isLoading) ? null : savePaymentDetails,
                icon: isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.save, size: 20),
                label: Text(
                  isSaving ? "Saving..." : "Save",
                  style: const TextStyle(fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              "Loading your account details...",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Payment Mode Section
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Payment Methods',
                    subtitle: 'Choose how you want to receive payments',
                    icon: Icons.payment,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _PaymentModeTile(
                          value: isCodSelected,
                          onChanged: isSaving ? null : (value) {
                            setState(() {
                              isCodSelected = value ?? false;
                            });
                          },
                          title: "Cash on Delivery",
                          subtitle: "Get paid when delivering the order",
                          icon: Icons.money,
                        ),
                        const Divider(height: 1, indent: 56),
                        _PaymentModeTile(
                          value: isDigitalSelected,
                          onChanged: isSaving ? null : (value) {
                            setState(() {
                              isDigitalSelected = value ?? false;
                              if (isDigitalSelected) {
                                _animationController.forward();
                              } else {
                                _animationController.reverse();
                              }
                            });
                          },
                          title: "Digital Payment",
                          subtitle: "Get paid directly to your bank account",
                          icon: Icons.account_balance,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// Digital Payment Section
            if (isDigitalSelected)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Linked Banks',
                        subtitle: savedBanks.isEmpty
                            ? 'Add your bank accounts to receive digital payments'
                            : 'You have ${savedBanks.length} bank ${savedBanks.length == 1 ? 'account' : 'accounts'} linked',
                        icon: Icons.account_balance_wallet,
                      ),
                      const SizedBox(height: 16),

                      if (savedBanks.isEmpty)
                        _EmptyStateCard(
                          message: "No bank accounts added yet",
                          icon: Icons.account_balance,
                          onAdd: () => _openAddBankSheet(),
                        )
                      else
                        Column(
                          children: [
                            ...List.generate(
                              savedBanks.length,
                                  (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _BankCard(
                                  bank: savedBanks[index],
                                  index: index + 1,
                                  onDelete: isSaving ? null : () => _removeBank(index),
                                  onEdit: isSaving ? null : () => _editBank(index),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Add Bank Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: (apiBankList.isEmpty || isSaving)
                                    ? null
                                    : _openAddBankSheet,
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text(
                                  "Add Another Bank Account",
                                  style: TextStyle(fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: colorScheme.primary.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
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
}

/// ===============================
/// PAYMENT MODE TILE
/// ===============================
class _PaymentModeTile extends StatelessWidget {
  final bool? value;
  final Function(bool?)? onChanged;
  final String title;
  final String subtitle;
  final IconData icon;

  const _PaymentModeTile({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onChanged != null ? () => onChanged!(!value!) : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value ?? false,
              onChanged: onChanged,
              activeColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// EMPTY STATE CARD
/// ===============================
class _EmptyStateCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback onAdd;

  const _EmptyStateCard({
    required this.message,
    required this.icon,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Add Bank Account"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// BANK MODELS
/// ===============================
class BankModel {
  final String id;
  final String name;
  final String? logo;

  BankModel({
    required this.id,
    required this.name,
    this.logo,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      logo: json['logo'],
    );
  }
}

class SavedBankModel {
  final int bankId;
  final String bankName;
  final String? bankLogo;
  final String? accountNumber;
  final String? accountHolderName;

  SavedBankModel({
    required this.bankId,
    required this.bankName,
    this.bankLogo,
    this.accountNumber,
    this.accountHolderName,
  });

  factory SavedBankModel.fromJson(Map<String, dynamic> json) {
    return SavedBankModel(
      bankId: json['bank_id'] ?? 0,
      bankName: json['bank_name'] ?? '',
      bankLogo: json['bank_logo'],
      accountNumber: json['account_number'],
      accountHolderName: json['account_holder_name'],
    );
  }
}

/// ===============================
/// BANK CARD
/// ===============================
class _BankCard extends StatelessWidget {
  final SavedBankModel bank;
  final int index;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const _BankCard({
    required this.bank,
    required this.index,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiService.baseUrl;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bank Logo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: bank.bankLogo != null
                        ? Image.network(
                      "$baseUrl/storage/banks/${bank.bankLogo}",
                      width: 30,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.account_balance, color: Colors.grey.shade600),
                    )
                        : Icon(Icons.account_balance, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 16),

                // Bank Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Bank ${index}",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bank.bankName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (bank.accountHolderName != null && bank.accountHolderName!.isNotEmpty)
                        Text(
                          bank.accountHolderName!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      const SizedBox(height: 2),
                      if (bank.accountNumber != null && bank.accountNumber!.isNotEmpty)
                        Text(
                          "A/C: ${bank.accountNumber!}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),

                // Action Buttons
                Column(
                  children: [
                    // if (onEdit != null)
                    //   IconButton(
                    //     icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                    //     onPressed: onEdit,
                    //     padding: EdgeInsets.zero,
                    //     constraints: const BoxConstraints(),
                    //   ),
                    const SizedBox(height: 8),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// BANK SELECTION SHEET
/// ===============================
class SelectBankSheet extends StatefulWidget {
  final List<BankModel> bankList;
  final Function(BankModel, String, String) onSave;
  final BankModel? initialBank;
  final String? initialAccountNumber;
  final String? initialHolderName;

  const SelectBankSheet({
    Key? key,
    required this.bankList,
    required this.onSave,
    this.initialBank,
    this.initialAccountNumber,
    this.initialHolderName,
  }) : super(key: key);

  @override
  State<SelectBankSheet> createState() => _SelectBankSheetState();
}

class _SelectBankSheetState extends State<SelectBankSheet> {
  BankModel? selectedBank;
  late TextEditingController accountController;
  late TextEditingController holderNameController;

  @override
  void initState() {
    super.initState();
    selectedBank = widget.initialBank;
    accountController = TextEditingController(text: widget.initialAccountNumber ?? '');
    holderNameController = TextEditingController(text: widget.initialHolderName ?? '');
  }

  @override
  void dispose() {
    accountController.dispose();
    holderNameController.dispose();
    super.dispose();
  }

  void _save() {
    if (selectedBank != null &&
        accountController.text.isNotEmpty &&
        holderNameController.text.isNotEmpty) {
      widget.onSave(
        selectedBank!,
        accountController.text.trim(),
        holderNameController.text.trim(),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiService.baseUrl;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.initialBank == null ? "Add Bank Account" : "Edit Bank Account",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Select your bank and enter account details",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Bank Selection Label
          const Text(
            "Select Bank",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Bank Selection Grid
          SizedBox(
            height: 130,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.bankList.length,
              itemBuilder: (context, index) {
                final bank = widget.bankList[index];
                final isSelected = selectedBank?.id == bank.id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedBank = bank;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        bank.logo != null
                            ? Image.network(
                          "${ApiService.ImagebaseUrl}/assets/bank_images/${bank.logo}",
                          width: 50,
                          height: 80,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.account_balance, color: Colors.grey.shade600),
                        )
                            : Icon(Icons.account_balance, color: Colors.grey.shade600),
                        // const SizedBox(height: 6),
                        Text(
                          bank.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? colorScheme.primary : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 14,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Account Details Form
          if (selectedBank != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Account Details",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: holderNameController,
                    decoration: InputDecoration(
                      labelText: "Account Holder Name",
                      hintText: "Enter account holder name",
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: accountController,
                    decoration: InputDecoration(
                      labelText: "Account Number",
                      hintText: "Enter account number",
                      prefixIcon: const Icon(Icons.numbers, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.initialBank == null ? "Add Bank Account" : "Update Bank Account",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 50,)
        ],
      ),
    );
  }
}

/// ===============================
/// UI HELPERS
/// ===============================
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}