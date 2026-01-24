import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/screens/bank_info.dart';
import '../profile/screens/edit_profile_screen.dart';
import '../profile/screens/store_list_screen.dart';
import '../profile/screens/vendor_profile_screen.dart';
import '../../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String _userName = 'User';
  String _userMobile = '';
  String? _profilePhotoUrl;
  int _statusId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("api_token");

      if (token != null) {
        // Fetch fresh profile data from API
        final res = await ApiService.get(endpoint: "/get-profile", token: token);
        if (res["success"] == true) {
          _userData = res["data"];
          _userName = _userData?["name"];
          _statusId = _userData?["status_id"];
          _profilePhotoUrl = _userData?["profile_photo"];
          await _saveUserData(_userData!);
        }

      } else {
        // Fallback to local data if no token
        await _loadLocalData();
      }
    } catch (e) {
      print("Error loading profile: $e");
      // Load from local storage on error
      await _loadLocalData();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user");

    if (userJson != null) {
      _userData = jsonDecode(userJson);
      _userName = prefs.getString("user_name") ?? 'User';
      _userMobile = prefs.getString("user_mobile") ?? '';
      _profilePhotoUrl = prefs.getString("user_profile_photo");
      _statusId = int.tryParse(prefs.getString("user_status_id") ?? '0') ?? 0;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("user", jsonEncode(userData));

    if (userData["id"] != null) {
      await prefs.setInt("user_id", int.tryParse(userData["id"].toString()) ?? 0);
    }
    if (userData["name"] != null) {
      await prefs.setString("user_name", userData["name"].toString());
    }
    if (userData["email"] != null) {
      await prefs.setString("user_email", userData["email"].toString());
    }
    if (userData["mobile"] != null) {
      await prefs.setString("user_mobile", userData["mobile"].toString());
    }
    if (userData["profile_photo"] != null) {
      await prefs.setString("user_profile_photo", userData["profile_photo"].toString());
    }
    if (userData["status_id"] != null) {
      await prefs.setString("user_status_id", userData["status_id"].toString());
    }
    if (userData["city"] != null) {
      await prefs.setString("user_city", userData["city"].toString());
    }
  }

  bool get _isProfileIncomplete {
    if (_userData == null) return true;
    final email = _userData?["email"]?.toString() ?? '';
    final name = _userData?["name"]?.toString() ?? '';
    return email.isEmpty || name.isEmpty;
  }


  String get _profileStatusMessage {
    if (_isProfileIncomplete) {
      return "Complete your profile";
    } else if (_statusId == 2) {
      return "Profile under review";
    } else if (_statusId == 1) {
      return "Profile approved ✓";
    }
    return "";
  }


  Color get _profileStatusColor {
    if (_isProfileIncomplete) return Colors.red;
    if (_statusId == 2) return Colors.orange;
    if (_statusId == 1) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Profile'),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Profile'),
        elevation: 0,
        foregroundColor: scheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Card
            Container(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  /// Profile Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      width: 48,
                      color: Colors.grey.shade200,
                      child: _profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty
                          ? Image.network(
                        _profilePhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person_outline,
                          color: scheme.onSurfaceVariant,
                        ),
                      )
                          : Icon(
                        Icons.person_outline,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// Name + Mobile + Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (_userMobile.isNotEmpty)
                          Text(
                            _userMobile,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),

                        // Profile Status
                        if (_profileStatusMessage.isNotEmpty)
                          InkWell(
                            onTap: _isProfileIncomplete
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(),
                                ),
                              ).then((_) => _loadUserData());
                            }
                                : null,
                            child: Row(
                              children: [
                                Text(
                                  _profileStatusMessage,
                                  style: TextStyle(
                                    color: _profileStatusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_isProfileIncomplete) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: _profileStatusColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Section Title
            Text(
              "Let's set up your business",
              style: textTheme.titleSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            /// Menu Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.description_outlined,
                    title: 'Business Details',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorProfileScreen(),
                        ),
                      ).then((_) => _loadUserData());
                    },
                  ),
                  const SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.storefront_outlined,
                    title: 'Store Management',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoreListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.account_balance,
                    title: 'Account Management',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BankInfoScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {},
                  ),
                  const SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Live Support',
                    onTap: () {},
                  ),
                  const SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.policy_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {},
                  ),
                  const SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();

                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/onboarding',
                                (_) => false,
                          );
                        }
                      }
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Reusable Menu Tile
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        size: 25,
        color: isDestructive ? scheme.error : scheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? scheme.error : scheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}