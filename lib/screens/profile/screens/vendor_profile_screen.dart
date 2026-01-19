import 'package:flutter/material.dart';

import 'edit_profile_screen.dart';
class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Business Details"),),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Basic Information', icon: Icons.person_outline),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(label: 'Full Name', value: 'Raghav Kumar'),
                _InfoRow(label: 'Email', value: 'raghav@example.com'),
                _InfoRow(label: 'Mobile', value: '+91 98765 43210'),
                _InfoRow(label: 'Alternate Contact', value: '+91 98765 11111'),
              ],
            ),
            const SizedBox(height: 20),

            _SectionHeader(title: 'Government ID', icon: Icons.badge_outlined),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(label: 'ID Type', value: 'Aadhar Card'),
                _InfoRow(label: 'ID Number', value: 'XXXX XXXX 1234'),
                _DocumentRow(label: 'ID Proof', fileName: 'aadhar_proof.pdf'),
              ],
            ),
            const SizedBox(height: 20),

            _SectionHeader(title: 'Address', icon: Icons.location_on_outlined),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(label: 'City', value: 'Chandigarh'),
                _InfoRow(label: 'State', value: 'Chandigarh'),
                _InfoRow(label: 'Country', value: 'India'),
                _InfoRow(label: 'PIN Code', value: '160001'),
              ],
            ),
            const SizedBox(height: 20),

            // Edit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> EditProfileScreen()));
                },
                icon: Icon(Icons.edit),
                label: Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
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
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: children,
      ),
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
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.description, size: 16, color: scheme.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    fileName,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.visibility_outlined, size: 18, color: scheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}