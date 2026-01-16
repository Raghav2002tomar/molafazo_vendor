// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
//
// class ProfileTab extends StatefulWidget {
//   @override
//   State<ProfileTab> createState() => _ProfileTabState();
// }
//
// class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//
//     return Scaffold(
//       body: NestedScrollView(
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             SliverAppBar(
//               expandedHeight: 280,
//               pinned: true,
//               backgroundColor: scheme.primary,
//               flexibleSpace: FlexibleSpaceBar(
//                 background: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [scheme.primary, scheme.primary.withOpacity(0.85)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: SafeArea(
//                     child: Column(
//                       children: [
//                         // Settings Icon
//                         Padding(
//                           padding: const EdgeInsets.only(right: 16),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Container(decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(50),
//                                 border: Border.all(color: Colors.white,width: 2),
//                               ),
//
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: SvgPicture.asset("assets/images/setting.svg",height: 26,color: Colors.white,),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                         // Profile Image
//                         Container(
//                           padding: const EdgeInsets.all(3),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 2.5),
//                           ),
//                           child: CircleAvatar(
//                             radius: 40,
//                             backgroundColor: Colors.white,
//                             child: Icon(Icons.person, size: 45, color: scheme.primary),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         // Name
//                         Text(
//                           'Raghav Kumar',
//                           style: textTheme.titleLarge?.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         // Mobile Number
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.phone_outlined, color: Colors.white70, size: 15),
//                             const SizedBox(width: 6),
//                             Text(
//                               '+91 98765 43210',
//                               style: textTheme.bodyMedium?.copyWith(
//                                 color: Colors.white.withOpacity(0.9),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               bottom: PreferredSize(
//                 preferredSize: Size.fromHeight(1),
//                 child: Container(
//                   color: scheme.surface,
//                   child: TabBar(
//                     controller: _tabController,
//                     labelColor: scheme.primary,
//                     unselectedLabelColor: scheme.onSurfaceVariant,
//                     indicatorColor: scheme.primary,
//                     indicatorWeight: 3,
//                     labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
//                     tabs: const [
//                       Tab(text: 'Personal'),
//                       Tab(text: 'Store'),
//                       Tab(text: 'Bank'),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ];
//         },
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             _PersonalInfoTab(),
//             _StoreInfoTab(),
//             _BankInfoTab(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Personal Info Tab
// class _PersonalInfoTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _SectionHeader(title: 'Basic Information', icon: Icons.person_outline),
//           const SizedBox(height: 12),
//           _InfoCard(
//             children: [
//               _InfoRow(label: 'Full Name', value: 'Raghav Kumar'),
//               _InfoRow(label: 'Email', value: 'raghav@example.com'),
//               _InfoRow(label: 'Mobile', value: '+91 98765 43210'),
//               _InfoRow(label: 'Alternate Contact', value: '+91 98765 11111'),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           _SectionHeader(title: 'Government ID', icon: Icons.badge_outlined),
//           const SizedBox(height: 12),
//           _InfoCard(
//             children: [
//               _InfoRow(label: 'ID Type', value: 'Aadhar Card'),
//               _InfoRow(label: 'ID Number', value: 'XXXX XXXX 1234'),
//               _DocumentRow(label: 'ID Proof', fileName: 'aadhar_proof.pdf'),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           _SectionHeader(title: 'Address', icon: Icons.location_on_outlined),
//           const SizedBox(height: 12),
//           _InfoCard(
//             children: [
//               _InfoRow(label: 'City', value: 'Chandigarh'),
//               _InfoRow(label: 'State', value: 'Chandigarh'),
//               _InfoRow(label: 'Country', value: 'India'),
//               _InfoRow(label: 'PIN Code', value: '160001'),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           // Edit Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {},
//               icon: Icon(Icons.edit),
//               label: Text('Edit Profile'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Store Info Tab
// class _StoreInfoTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Add New Store Button
//           InkWell(
//             onTap: () {
//               // Navigate to add store screen
//             },
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: scheme.primaryContainer,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: scheme.primary, width: 1.5),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.add_business, color: scheme.primary),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Add New Store',
//                     style: textTheme.titleSmall?.copyWith(
//                       color: scheme.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           // Store List
//           _SectionHeader(title: 'My Stores', icon: Icons.store),
//           const SizedBox(height: 12),
//
//           _StoreCard(
//             storeName: 'TechWorld Electronics',
//             storeType: 'Retail',
//             isActive: true,
//           ),
//           const SizedBox(height: 12),
//
//           _StoreCard(
//             storeName: 'Mobile Hub',
//             storeType: 'Wholesale',
//             isActive: false,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Bank Info Tab
// class _BankInfoTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _SectionHeader(title: 'Bank Account Details', icon: Icons.account_balance),
//           const SizedBox(height: 12),
//           _InfoCard(
//             children: [
//               _InfoRow(label: 'Account Holder', value: 'Raghav Kumar'),
//               _InfoRow(label: 'Account Number', value: 'XXXX XXXX 5678'),
//               _InfoRow(label: 'IFSC Code', value: 'SBIN0001234'),
//               _InfoRow(label: 'Bank Name', value: 'State Bank of India'),
//               _InfoRow(label: 'Branch', value: 'Sector 17, Chandigarh'),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           _SectionHeader(title: 'Payment Details', icon: Icons.payment),
//           const SizedBox(height: 12),
//           _InfoCard(
//             children: [
//               _InfoRow(label: 'UPI ID', value: 'raghav@paytm'),
//               _InfoRow(label: 'PAN Number', value: 'ABCDE1234F'),
//               _InfoRow(label: 'GST Number', value: '29ABCDE1234F1Z5'),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           _SectionHeader(title: 'Documents', icon: Icons.description_outlined),
//           const SizedBox(height: 12),
//           _InfoCard(
//             children: [
//               _DocumentRow(label: 'Cancelled Cheque', fileName: 'cheque.pdf'),
//               _DocumentRow(label: 'PAN Card', fileName: 'pan_card.pdf'),
//               _DocumentRow(label: 'GST Certificate', fileName: 'gst_cert.pdf'),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           // Edit Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {},
//               icon: Icon(Icons.edit),
//               label: Text('Edit Bank Details'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Reusable Widgets
//
// class _SectionHeader extends StatelessWidget {
//   final String title;
//   final IconData icon;
//
//   const _SectionHeader({required this.title, required this.icon});
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final scheme = Theme.of(context).colorScheme;
//
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: scheme.primary),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }
// }
//
// class _InfoCard extends StatelessWidget {
//   final List<Widget> children;
//
//   const _InfoCard({required this.children});
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: scheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: scheme.outlineVariant),
//       ),
//       child: Column(
//         children: children,
//       ),
//     );
//   }
// }
//
// class _InfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//
//   const _InfoRow({required this.label, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final scheme = Theme.of(context).colorScheme;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: textTheme.bodyMedium?.copyWith(
//                 color: scheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _DocumentRow extends StatelessWidget {
//   final String label;
//   final String fileName;
//
//   const _DocumentRow({required this.label, required this.fileName});
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final scheme = Theme.of(context).colorScheme;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: textTheme.bodyMedium?.copyWith(
//                 color: scheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Icon(Icons.description, size: 16, color: scheme.primary),
//                 const SizedBox(width: 4),
//                 Flexible(
//                   child: Text(
//                     fileName,
//                     style: textTheme.bodySmall?.copyWith(
//                       color: scheme.primary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     textAlign: TextAlign.end,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(Icons.visibility_outlined, size: 18, color: scheme.primary),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _StoreCard extends StatelessWidget {
//   final String storeName;
//   final String storeType;
//   final bool isActive;
//
//   const _StoreCard({
//     required this.storeName,
//     required this.storeType,
//     required this.isActive,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: scheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isActive ? scheme.primary : scheme.outlineVariant,
//           width: isActive ? 1.5 : 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: scheme.primaryContainer,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(Icons.store, color: scheme.primary, size: 24),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       storeName,
//                       style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(height: 2),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: isActive
//                                 ? Colors.green.withOpacity(0.1)
//                                 : Colors.grey.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             isActive ? 'Active' : 'Inactive',
//                             style: textTheme.bodySmall?.copyWith(
//                               color: isActive ? Colors.green : Colors.grey,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           storeType,
//                           style: textTheme.bodySmall?.copyWith(
//                             color: scheme.onSurfaceVariant,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(Icons.arrow_forward_ios, size: 16),
//                 onPressed: () {
//                   // Navigate to store details
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Divider(height: 1),
//           const SizedBox(height: 12),
//           _InfoRow(label: 'Store Email', value: 'techworld@store.com'),
//           _InfoRow(label: 'Store Phone', value: '+91 98765 99999'),
//           _InfoRow(label: 'Address', value: 'Sector 17, Chandigarh'),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () {},
//                   icon: Icon(Icons.edit, size: 16),
//                   label: Text('Edit', style: TextStyle(fontSize: 13)),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: () {},
//                   icon: Icon(Icons.visibility, size: 16),
//                   label: Text('View', style: TextStyle(fontSize: 13)),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';

import '../profile/screens/bank_info.dart';
import '../profile/screens/store_list_screen.dart';
import '../profile/screens/vendor_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final File? profileImage;
  final String businessName;
  final String businessLocation;

  const ProfileScreen({
    super.key,
    this.profileImage,
    this.businessName = 'Raghav Tomar',
    this.businessLocation = '6261767826',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Profile'),
        elevation: 0,
        // backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  /// Profile Image (Square, not circle)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      width: 48,
                      color: Colors.grey.shade200,
                      child: profileImage != null
                          ? Image.file(profileImage!, fit: BoxFit.cover)
                          : Icon(
                              Icons.person_outline,
                              color: scheme.onSurfaceVariant,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// Name + Location
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        businessName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        businessLocation,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// Section Title
            Text(
              "Let’s set up your business",
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
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>VendorProfileScreen()));
                    },
                  ),
                  SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.storefront_outlined,
                    title: 'Store Management',
                    onTap: () {

                      Navigator.push(context, MaterialPageRoute(builder: (context)=>StoreListScreen()));

                    },
                  ),
                  SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.account_balance,
                    title: 'Account Management',
                    onTap: () {

                      Navigator.push(context, MaterialPageRoute(builder: (context)=>BankInfoScreen()));

                    },
                  ),
                  SizedBox(height: 4),

                  _MenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {},
                  ),
                  SizedBox(height: 4),

                  _MenuTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Live Support',
                    onTap: () {},
                  ),
                  SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.policy_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  SizedBox(height: 4),
                  _MenuTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Tearms & Coundation',
                    onTap: () {},
                  ),
                  SizedBox(height: 4),

                  _MenuTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: () {},
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
