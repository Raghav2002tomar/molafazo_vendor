import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:molafzo_vendor/extensions/context_extension.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../didit_demo_screen.dart';
import '../../providers/translate_provider.dart';
import '../../services/local_user_storage.dart';
import '../../services/storage_service.dart';
import '../profile/screens/Policy_Conten_Screen.dart';
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
                // Fetch latest profile data from API
                final res = await ApiService.get(endpoint: "/get-profile", token: token);

                if (res["success"] == true && res["data"] != null) {
                    // Save and update SharedPreferences + UI
                    await _saveUserData(res["data"]);
                } else {
                    // API failed, fallback to local storage
                    await _loadLocalData();
                }
            } else {
                // No token, fallback
                await _loadLocalData();
            }
        } catch (e) {
            print("Error loading profile: $e");
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

        // Save complete user data
        await prefs.setString("user", jsonEncode(userData));

        // Save individual fields
        await prefs.setInt("user_id", int.tryParse(userData["id"].toString()) ?? 0);
        await prefs.setString("user_name", userData["name"]?.toString() ?? '');
        await prefs.setString("user_email", userData["email"]?.toString() ?? '');
        await prefs.setString("user_mobile", userData["mobile"]?.toString() ?? '');
        await prefs.setString("user_profile_photo", userData["profile_photo"]?.toString() ?? '');
        await prefs.setString("user_status_id", userData["status_id"]?.toString() ?? '');
        await prefs.setString("user_city", userData["city"]?.toString() ?? '');

        // Mark user as logged in
        await prefs.setBool("is_logged_in", true);

        // 🔹 Update UI state immediately
        setState(() {
                _userData = userData;
                _userName = userData["name"] ?? 'User';
                _userMobile = userData["mobile"] ?? '';
                _profilePhotoUrl = userData["profile_photo"];
                _statusId = userData["status_id"] ?? 0;
            });

        print("✅ User data saved and state updated");
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
                    title: Text(context.tr('profile')),
                    elevation: 0
                ),
                body: const Center(child: CircularProgressIndicator())
            );
        }

        return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                backgroundColor: Colors.white,
                title: Text(context.tr('profile')),
                elevation: 0,
                foregroundColor: scheme.onSurface,
                actions: [
                    IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadUserData
                    )
                ]
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
                                border: Border.all(color: Colors.grey.shade200)
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
                                                        color: scheme.onSurfaceVariant
                                                    )
                                                )
                                                : Icon(
                                                    Icons.person_outline,
                                                    color: scheme.onSurfaceVariant
                                                )
                                        )
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
                                                        fontSize: 14
                                                    )
                                                ),
                                                if (_userMobile.isNotEmpty)
                                                Text(
                                                    _userMobile,
                                                    style: textTheme.bodyMedium?.copyWith(
                                                        color: scheme.onSurfaceVariant,
                                                        fontSize: 12
                                                    )
                                                ),

                                                // Profile Status
                                                if (_profileStatusMessage.isNotEmpty)
                                                InkWell(
                                                    onTap: _isProfileIncomplete
                                                        ? () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => EditProfileScreen()
                                                                )
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
                                                                    fontWeight: FontWeight.w500
                                                                )
                                                            ),
                                                            if (_isProfileIncomplete) ...[
                                                                const SizedBox(width: 8),
                                                                Icon(
                                                                    Icons.edit,
                                                                    size: 12,
                                                                    color: _profileStatusColor
                                                                )
                                                            ]
                                                        ]
                                                    )
                                                )
                                            ]
                                        )
                                    )
                                ]
                            )
                        ),

                        const SizedBox(height: 24),

                        /// Section Title
                        Text(
                            context.tr('setup_business'),
                            style: textTheme.titleSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600
                            )
                        ),

                        const SizedBox(height: 12),

                        /// Menu Card
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                                color: scheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200)
                            ),
                            child: Column(
                                children: [
                                    _MenuTile(
                                        icon: Icons.description_outlined,
                                        title: context.tr('business_details'),
                                        onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => VendorProfileScreen()
                                                )
                                            ).then((_) => _loadUserData());
                                        }
                                    ),
                                    const SizedBox(height: 4),
                                    _MenuTile(
                                        icon: Icons.storefront_outlined,
                                        title: context.tr('store_management'),
                                        onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => StoreListScreen()
                                                )
                                            );
                                        }
                                    ),
                                    const SizedBox(height: 4),
                                    _MenuTile(
                                        icon: Icons.account_balance,
                                        title: context.tr('payment_mode'),
                                        onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => BankInfoScreen()
                                                )
                                            );
                                        }
                                    ),
                                    const SizedBox(height: 4),
                                    _MenuTile(
                                        icon: Icons.settings_outlined,
                                        title: context.tr('settings'),
                                        onTap: () {}
                                    ),
                                    const SizedBox(height: 4),
                                    _MenuTile(
                                        icon: Icons.language,
                                        title: context.tr('language'),
                                        onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                    return Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                            ListTile(
                                                                title: const Text('English'),
                                                                onTap: () {
                                                                    context.read<TranslateProvider>().setLocale('en');
                                                                    Navigator.pop(context);
                                                                }
                                                            ),
                                                            ListTile(
                                                                title: const Text('Русский'),
                                                                onTap: () {
                                                                    context.read<TranslateProvider>().setLocale('ru');
                                                                    Navigator.pop(context);
                                                                }
                                                            ),
                                                            ListTile(
                                                                title: const Text('Тоҷикӣ'),
                                                                onTap: () {
                                                                    context.read<TranslateProvider>().setLocale('tg');
                                                                    Navigator.pop(context);
                                                                }
                                                            )
                                                        ]
                                                    );
                                                }
                                            );
                                        }
                                    ),
                                    const SizedBox(height: 4),
                                    _MenuTile(
                                        icon: Icons.headset_mic_outlined,
                                        title: context.tr('live_support'),
                                        onTap: () {}
                                    ),
                                    const SizedBox(height: 4),
                                    _MenuTile(
                                        icon: Icons.policy_outlined,
                                        title: context.tr('privacy_policy'),
                                        onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => PolicyContentScreen(
                                                        title: context.tr('privacy_policy'),
                                                        endpoint: '/privacy-policy'
                                                    )
                                                )
                                            );
                                        }
                                    ),
                                    const SizedBox(height: 4),
                                    _MenuTile(
                                        icon: Icons.privacy_tip_outlined,
                                        title: context.tr('terms_conditions'),
                                        onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => PolicyContentScreen(
                                                        title: context.tr('terms_conditions'),
                                                        endpoint: '/terms-conditions'
                                                    )
                                                )
                                            );
                                        }
                                    ),
                                    const SizedBox(height: 4),
                                    _MenuTile(
                                        icon: Icons.logout,
                                        title: context.tr('logout'),
                                        onTap: () async {
                                            final confirmed = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                    title: Text(context.tr('logout_title')),
                                                    content: Text(context.tr('logout_message')),
                                                    actions: [
                                                        TextButton(
                                                            onPressed: () => Navigator.pop(context, false),
                                                            child: Text(context.tr('cancel'))
                                                        ),
                                                        TextButton(
                                                            onPressed: () => Navigator.pop(context, true),
                                                            child: Text(context.tr('logout_title'))
                                                        )
                                                    ]
                                                )
                                            );

                                            if (confirmed == true) {

                                                final success = await logout();

                                                if (success) {

                                                    // Optional: delete FCM token
                                                    // await FirebaseMessaging.instance.deleteToken();

                                                    final prefs = await SharedPreferences.getInstance();
                                                    await prefs.clear();

                                                    if (mounted) {
                                                        Navigator.pushNamedAndRemoveUntil(
                                                            context,
                                                            '/onboarding',
                                                            (_) => false
                                                        );
                                                    }

                                                } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text(context.tr('logout_failed')))
                                                    );
                                                }
                                            }
                                        },
                                        isDestructive: true
                                    )
                                ]
                            )
                        )
                    ]
                )
            )
        );
    }

    static Future<bool> logout() async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('api_token');
        try {
            final response = await http.post(
                Uri.parse('${ApiService.baseUrl}/logout'),
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token'
                }
            );

            if (response.statusCode == 200) {
                return true;
            } else {
                print("Logout failed: ${response.body}");
                return false;
            }

        } catch (e) {
            print("Logout error: $e");
            return false;
        }
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
        this.isDestructive = false
    });

    @override
    Widget build(BuildContext context) {
        final scheme = Theme.of(context).colorScheme;
        String t(String key) =>
        Provider.of<TranslateProvider>(context, listen: false).t(key);

        return ListTile(
            leading: Icon(
                icon,
                size: 25,
                color: isDestructive ? scheme.error : scheme.onSurface
            ),
            title: Text(
                title,
                style: TextStyle(
                    color: isDestructive ? scheme.error : scheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14
                )
            ),
            onTap: onTap,
            dense: true,
            visualDensity: VisualDensity.compact
        );
    }
}