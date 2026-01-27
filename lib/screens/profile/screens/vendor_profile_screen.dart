import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import 'edit_profile_screen.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("api_token");

      if (token != null) {
        final res = await ApiService.get(endpoint: "/get-profile", token: token);

        if (res["success"] == true) {
          _profileData = res["data"];
          await _saveUserData(res["data"]);

        } else {
          // Optional: fallback to local storage
          final localData = prefs.getString("user");
          if (localData != null) _profileData = jsonDecode(localData);
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }

    setState(() => _isLoading = false);
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


    print("✅ User data saved and state updated");
  }

  String _getValue(String key) {
    final val = _profileData?[key];
    if (val == null || val.toString().isEmpty) return "-";
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Details"),
        backgroundColor: Colors.white,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Basic Information', icon: Icons.person_outline),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(label: 'Full Name', value: _getValue("name")),
                _InfoRow(label: 'Email', value: _getValue("email")),
                _InfoRow(label: 'Mobile', value: _getValue("mobile")),
                _InfoRow(label: 'Alternate Contact', value: _getValue("alt_mobile")),
              ],
            ),
            const SizedBox(height: 20),

            _SectionHeader(title: 'Government ID', icon: Icons.badge_outlined),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(label: 'ID Type', value: _getValue("gov_id_type")),
                _InfoRow(label: 'ID Number', value: _getValue("gov_id_number")),
                _DocumentRow(label: 'ID Proof', fileName: _getValue("gov_id_document")),
              ],
            ),
            const SizedBox(height: 20),

            _SectionHeader(title: 'Address', icon: Icons.location_on_outlined),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(label: 'City', value: _getValue("city")),
                _InfoRow(label: 'State', value: _getValue("state")),
                _InfoRow(label: 'Country', value: _getValue("country")),
                _InfoRow(label: 'PIN Code', value: _getValue("pincode")),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  ).then((_) => _fetchProfile());
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ UI Widgets ------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))),
          Expanded(flex: 3, child: Text(value, textAlign: TextAlign.end, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final String label;
  final String fileName;

  const _DocumentRow({required this.label, required this.fileName});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.description, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(fileName, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.visibility_outlined, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
