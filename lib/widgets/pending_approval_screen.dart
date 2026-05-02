// import 'dart:math' as math;
// import 'package:flutter/material.dart';
//
// class PendingApprovalScreen extends StatefulWidget {
//   final String userName;
//   final String status;
//   final VoidCallback? onRefresh;
//
//   const PendingApprovalScreen({
//     super.key,
//     required this.userName,
//     required this.status,
//     this.onRefresh,
//   });
//
//   @override
//   State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
// }
//
// class _PendingApprovalScreenState extends State<PendingApprovalScreen>
//     with TickerProviderStateMixin {
//   late final AnimationController _floatController;
//   late final AnimationController _fadeController;
//   late final AnimationController _pulseController;
//
//   late final Animation<double> _fadeAnimation;
//   late final Animation<Offset> _slideAnimation;
//   late final Animation<double> _pulseAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _floatController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..repeat(reverse: true);
//
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1600),
//     )..repeat(reverse: true);
//
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeOutCubic,
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.08),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _fadeController,
//         curve: Curves.easeOutCubic,
//       ),
//     );
//
//     _pulseAnimation = Tween<double>(begin: 0.95, end: 1.06).animate(
//       CurvedAnimation(
//         parent: _pulseController,
//         curve: Curves.easeInOut,
//       ),
//     );
//
//     _fadeController.forward();
//   }
//
//   @override
//   void dispose() {
//     _floatController.dispose();
//     _fadeController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }
//
//   bool get _isRejected => widget.status == '3';
//   bool get _isPending => widget.status == '2';
//   bool get _isNotVerified => widget.status == '0';
//
//   String getStatusText() {
//     switch (widget.status) {
//       case '0':
//         return 'Account Not Verified';
//       case '2':
//         return 'Pending for Approval';
//       case '3':
//         return 'Profile Rejected';
//       default:
//         return 'Verification in Progress';
//     }
//   }
//
//   String getMessage() {
//     switch (widget.status) {
//       case '0':
//         return 'Your account was created successfully. Please complete your business profile and wait for admin approval.';
//       case '2':
//         return 'Our team is currently reviewing your submitted details. You will get full dashboard access after approval.';
//       case '3':
//         return 'Your profile was not approved at the moment. Please update the required details and submit again.';
//       default:
//         return 'Please wait while we complete your verification process.';
//     }
//   }
//
//   String getSmallNote() {
//     switch (widget.status) {
//       case '3':
//         return 'You may need to update your submitted information.';
//       case '2':
//         return 'Usually this takes a short review time from admin side.';
//       default:
//         return 'Complete profile details help speed up approval.';
//     }
//   }
//
//   Color getPrimaryColor() {
//     switch (widget.status) {
//       case '2':
//         return const Color(0xFFF59E0B); // amber
//       case '3':
//         return const Color(0xFFEF4444); // red
//       default:
//         return const Color(0xFF0F100F); // blue
//     }
//   }
//
//   Color getSecondaryColor() {
//     switch (widget.status) {
//       case '2':
//         return const Color(0xFFFFEDD5);
//       case '3':
//         return const Color(0xFFFEE2E2);
//       default:
//         return const Color(0xFFDBEAFE);
//     }
//   }
//
//   IconData getStatusIcon() {
//     switch (widget.status) {
//       case '2':
//         return Icons.hourglass_top_rounded;
//       case '3':
//         return Icons.gpp_bad_outlined;
//       default:
//         return Icons.verified_user_outlined;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final primary = getPrimaryColor();
//     final secondary = getSecondaryColor();
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       body: Container(
//         color: const Color(0xFFF8FAFC),
//         child: Stack(
//           children: [
//             Positioned(
//               top: -60,
//               right: -40,
//               child: _BlurCircle(
//                 size: 180,
//                 color: primary.withOpacity(0.14),
//               ),
//             ),
//             Positioned(
//               top: size.height * 0.25,
//               left: -50,
//               child: _BlurCircle(
//                 size: 140,
//                 color: primary.withOpacity(0.10),
//               ),
//             ),
//             Positioned(
//               bottom: -60,
//               right: -20,
//               child: _BlurCircle(
//                 size: 200,
//                 color: primary.withOpacity(0.08),
//               ),
//             ),
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: RefreshIndicator(
//                   onRefresh: () async {
//                     widget.onRefresh?.call();
//                     await Future.delayed(const Duration(milliseconds: 700));
//                   },
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 50),
//
//                         AnimatedBuilder(
//                           animation: Listenable.merge([
//                             _floatController,
//                             _pulseController,
//                           ]),
//                           builder: (context, child) {
//                             final floatY =
//                                 math.sin(_floatController.value * 2 * math.pi) * 8;
//
//                             return Transform.translate(
//                               offset: Offset(0, floatY),
//                               child: Transform.scale(
//                                 scale: _pulseAnimation.value,
//                                 child: child,
//                               ),
//                             );
//                           },
//                           child: Container(
//                             height: 108,
//                             width: 108,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: LinearGradient(
//                                 colors: [
//                                   primary,
//                                   primary.withOpacity(0.78),
//                                 ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: primary.withOpacity(0.30),
//                                   blurRadius: 26,
//                                   spreadRadius: 4,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: Icon(
//                               getStatusIcon(),
//                               size: 50,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//
//                         const SizedBox(height: 50),
//
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(24),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 Colors.white,
//                                 secondary.withOpacity(0.55),
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(28),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 18,
//                                 offset: const Offset(0, 8),
//                               ),
//                             ],
//                             border: Border.all(
//                               color: primary.withOpacity(0.10),
//                             ),
//                           ),
//                           child: Column(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 14,
//                                   vertical: 7,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: primary.withOpacity(0.10),
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                                 child: Text(
//                                   'Verification Status',
//                                   style: TextStyle(
//                                     color: primary,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 18),
//                               Text(
//                                 'Hello, ${widget.userName}',
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.w800,
//                                   color: Color(0xFF0F172A),
//                                 ),
//                               ),
//                               const SizedBox(height: 10),
//                               Text(
//                                 getStatusText(),
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700,
//                                   color: primary,
//                                 ),
//                               ),
//                               const SizedBox(height: 14),
//                               Text(
//                                 getMessage(),
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontSize: 14.5,
//                                   height: 1.6,
//                                   color: Colors.grey.shade700,
//                                 ),
//                               ),
//                               const SizedBox(height: 18),
//                               Container(
//                                 width: double.infinity,
//                                 padding: const EdgeInsets.all(14),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.75),
//                                   borderRadius: BorderRadius.circular(18),
//                                   border: Border.all(
//                                     color: primary.withOpacity(0.10),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       Icons.info_outline,
//                                       color: primary,
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Expanded(
//                                       child: Text(
//                                         getSmallNote(),
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: Colors.grey.shade700,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(height: 300),
//
//                         // _InfoCard(
//                         //   title: 'What happens next?',
//                         //   icon: Icons.timeline_rounded,
//                         //   color: primary,
//                         //   children: const [
//                         //     _StepRow(
//                         //       icon: Icons.fact_check_outlined,
//                         //       text: 'Admin will review your submitted business details.',
//                         //     ),
//                         //     _StepRow(
//                         //       icon: Icons.notifications_active_outlined,
//                         //       text: 'You can refresh this screen anytime to check latest approval status.',
//                         //     ),
//                         //     _StepRow(
//                         //       icon: Icons.lock_outline_rounded,
//                         //       text: 'Dashboard features will unlock automatically after approval.',
//                         //     ),
//                         //   ],
//                         // ),
//                         //
//                         // const SizedBox(height: 16),
//                         //
//                         // if (_isPending || _isNotVerified)
//                         //   _InfoCard(
//                         //     title: 'While you wait',
//                         //     icon: Icons.auto_awesome_outlined,
//                         //     color: primary,
//                         //     children: const [
//                         //       _StepRow(
//                         //         icon: Icons.person_outline,
//                         //         text: 'Keep your profile information complete and accurate.',
//                         //       ),
//                         //       _StepRow(
//                         //         icon: Icons.storefront_outlined,
//                         //         text: 'Make sure your business/store details are properly submitted.',
//                         //       ),
//                         //       _StepRow(
//                         //         icon: Icons.support_agent_outlined,
//                         //         text: 'Contact support if approval takes longer than expected.',
//                         //       ),
//                         //     ],
//                         //   ),
//                         //
//                         // if (_isRejected) ...[
//                         //   const SizedBox(height: 16),
//                         //   _InfoCard(
//                         //     title: 'What you should do',
//                         //     icon: Icons.edit_note_rounded,
//                         //     color: primary,
//                         //     children: const [
//                         //       _StepRow(
//                         //         icon: Icons.edit_outlined,
//                         //         text: 'Update incorrect or missing profile details.',
//                         //       ),
//                         //       _StepRow(
//                         //         icon: Icons.upload_file_outlined,
//                         //         text: 'Re-submit the required information properly.',
//                         //       ),
//                         //       _StepRow(
//                         //         icon: Icons.refresh_rounded,
//                         //         text: 'Check again after profile correction and review.',
//                         //       ),
//                         //     ],
//                         //   ),
//                         // ],
//
//                         // const SizedBox(height: 28),
//                         //
//                         // SizedBox(
//                         //   width: double.infinity,
//                         //   child: ElevatedButton.icon(
//                         //     onPressed: widget.onRefresh,
//                         //     icon: const Icon(Icons.refresh_rounded),
//                         //     label: const Text('Refresh Status'),
//                         //     style: ElevatedButton.styleFrom(
//                         //       backgroundColor: primary,
//                         //       foregroundColor: Colors.white,
//                         //       elevation: 0,
//                         //       padding: const EdgeInsets.symmetric(vertical: 16),
//                         //       shape: RoundedRectangleBorder(
//                         //         borderRadius: BorderRadius.circular(18),
//                         //       ),
//                         //       textStyle: const TextStyle(
//                         //         fontWeight: FontWeight.w700,
//                         //         fontSize: 15,
//                         //       ),
//                         //     ),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//     ));
//   }
// }
//
// class _InfoCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color color;
//   final List<Widget> children;
//
//   const _InfoCard({
//     required this.title,
//     required this.icon,
//     required this.color,
//     required this.children,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 14,
//             offset: const Offset(0, 6),
//           ),
//         ],
//         border: Border.all(color: color.withOpacity(0.08)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 height: 38,
//                 width: 38,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.10),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon, color: color, size: 20),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 15.5,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF0F172A),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           ...children,
//         ],
//       ),
//     );
//   }
// }
//
// class _StepRow extends StatelessWidget {
//   final IconData icon;
//   final String text;
//
//   const _StepRow({
//     required this.icon,
//     required this.text,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             icon,
//             size: 18,
//             color: const Color(0xFF475569),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 13.5,
//                 height: 1.5,
//                 color: Colors.grey.shade700,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _BlurCircle extends StatelessWidget {
//   final double size;
//   final Color color;
//
//   const _BlurCircle({
//     required this.size,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return IgnorePointer(
//       child: Container(
//         height: size,
//         width: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: color,
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../screens/profile/screens/edit_profile_screen.dart';
import '../didit_demo_screen.dart';
import '../services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PendingApprovalScreen extends StatefulWidget {
  final String userName;
  final String status;
  final VoidCallback? onRefresh;

  const PendingApprovalScreen({
    super.key,
    required this.userName,
    required this.status,
    this.onRefresh,
  });

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _pulseAnimation;

  bool _loadingProfile = true;

  String _savedName = '';
  String _savedEmail = '';
  String _savedStatusId = '';
  String _kycStatus = '';
  List<dynamic> _governmentDocuments = [];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.06).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
    _loadSavedProfile();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = prefs.getString("user");
    if (userJson != null) {
      final data = jsonDecode(userJson);

      List<dynamic> docs = [];
      if (data["government_id_documents"] is List) {
        docs = data["government_id_documents"];
      } else {
        final docsString = prefs.getString("government_id_documents");
        if (docsString != null && docsString.isNotEmpty) {
          docs = jsonDecode(docsString);
        }
      }

      setState(() {
        _savedName = data["name"]?.toString() ?? '';
        _savedEmail = data["email"]?.toString() ?? '';
        _savedStatusId = data["status_id"]?.toString() ?? '';
        _kycStatus = data["kyc_status"]?.toString() ?? '';
        _governmentDocuments = docs;
        _loadingProfile = false;
      });
    } else {
      setState(() {
        _loadingProfile = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("api_token");

    if (token == null || token.isEmpty) {
      await _loadSavedProfile();
      return;
    }

    try {
      final res = await ApiService.get(
        endpoint: "/get-profile",
        token: token,
      );

      if (res["success"] == true && res["data"] != null) {
        final profile = Map<String, dynamic>.from(res["data"]);

        await prefs.setString("user", jsonEncode(profile));

        if (profile["id"] != null) {
          await prefs.setInt("user_id", int.tryParse(profile["id"].toString()) ?? 0);
        }
        if (profile["name"] != null) {
          await prefs.setString("user_name", profile["name"]?.toString() ?? '');
        }
        if (profile["email"] != null) {
          await prefs.setString("user_email", profile["email"]?.toString() ?? '');
        }
        if (profile["mobile"] != null) {
          await prefs.setString("user_mobile", profile["mobile"]?.toString() ?? '');
        }
        if (profile["status_id"] != null) {
          await prefs.setString("user_status_id", profile["status_id"].toString());
        }
        if (profile["kyc_status"] != null) {
          await prefs.setString("kyc_status", profile["kyc_status"].toString());
        }
        if (profile["government_id_documents"] != null) {
          await prefs.setString(
            "government_id_documents",
            jsonEncode(profile["government_id_documents"]),
          );
        }
      }
    } catch (e) {
      debugPrint("Profile refresh error: $e");
    }

    await _loadSavedProfile();
    widget.onRefresh?.call();
  }

  bool get _isEmailMissing => _savedEmail.trim().isEmpty;
  bool get _isNameMissing => _savedName.trim().isEmpty;

  bool get _showPendingItems => _isEmailMissing || _isNameMissing;

  bool get _isRejected => widget.status == '3';
  bool get _isPending => widget.status == '2';
  bool get _isNotVerified => widget.status == '0';

  String getStatusText() {
    if (_showPendingItems) return 'Complete Your Profile';

    switch (widget.status) {
      case '0':
        return 'Account Not Verified';
      case '2':
        return 'Pending for Approval';
      case '3':
        return 'Profile Rejected';
      default:
        return 'Verification in Progress';
    }
  }

  String getMessage() {
    if (_showPendingItems) {
      return 'Some required profile details are missing. Please complete them to continue verification.';
    }

    switch (widget.status) {
      case '0':
        return 'Your account was created successfully. Please complete your business profile and wait for admin approval.';
      case '2':
        return 'Our team is currently reviewing your submitted details. You will get full dashboard access after approval.';
      case '3':
        return 'Your profile was not approved at the moment. Please update the required details and submit again.';
      default:
        return 'Please wait while we complete your verification process.';
    }
  }

  String getSmallNote() {
    if (_showPendingItems) {
      return 'Complete the missing fields below.';
    }

    switch (widget.status) {
      case '3':
        return 'You may need to update your submitted information.';
      case '2':
        return 'Usually this takes a short review time from admin side.';
      default:
        return 'Complete profile details help speed up approval.';
    }
  }

  Color getPrimaryColor() {
    if (_showPendingItems) {
      return const Color(0xFF2563EB);
    }

    switch (widget.status) {
      case '2':
        return const Color(0xFFF59E0B);
      case '3':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF0F100F);
    }
  }

  Color getSecondaryColor() {
    if (_showPendingItems) {
      return const Color(0xFFDBEAFE);
    }

    switch (widget.status) {
      case '2':
        return const Color(0xFFFFEDD5);
      case '3':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFDBEAFE);
    }
  }

  IconData getStatusIcon() {
    if (_showPendingItems) return Icons.assignment_late_outlined;

    switch (widget.status) {
      case '2':
        return Icons.hourglass_top_rounded;
      case '3':
        return Icons.gpp_bad_outlined;
      default:
        return Icons.verified_user_outlined;
    }
  }

  void _openEmailVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EmailVerificationScreen(),
      ),
    ).then((_) => _refreshProfile());
  }

  void _openDocumentVerification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VerificationScreen(),
      ),
    ).then((_) => _refreshProfile());
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final primary = getPrimaryColor();
    final secondary = getSecondaryColor();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: const Color(0xFFF8FAFC),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -40,
              child: _BlurCircle(
                size: 180,
                color: primary.withOpacity(0.14),
              ),
            ),
            Positioned(
              top: size.height * 0.25,
              left: -50,
              child: _BlurCircle(
                size: 140,
                color: primary.withOpacity(0.10),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -20,
              child: _BlurCircle(
                size: 200,
                color: primary.withOpacity(0.08),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
                  onRefresh: _refreshProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _floatController,
                            _pulseController,
                          ]),
                          builder: (context, child) {
                            final floatY =
                                math.sin(_floatController.value * 2 * math.pi) * 8;

                            return Transform.translate(
                              offset: Offset(0, floatY),
                              child: Transform.scale(
                                scale: _pulseAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            height: 108,
                            width: 108,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  primary,
                                  primary.withOpacity(0.78),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withOpacity(0.30),
                                  blurRadius: 26,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              getStatusIcon(),
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                secondary.withOpacity(0.55),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: primary.withOpacity(0.10),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  'Verification Status',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Hello, ${widget.userName}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                getStatusText(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                getMessage(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  height: 1.6,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: primary.withOpacity(0.10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        getSmallNote(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (_showPendingItems)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(color: primary.withOpacity(0.08)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pending Items',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                if (_isEmailMissing)
                                  _PendingItemTile(
                                    icon: Icons.email_outlined,
                                    title: 'Email Verification',
                                    subtitle: 'Email is missing',
                                    onTap: _openEmailVerification,
                                  ),

                                if (_isNameMissing)
                                  _PendingItemTile(
                                    icon: Icons.verified_user_outlined,
                                    title: 'Document Verification',
                                    subtitle: 'Name is missing',
                                    onTap: _openDocumentVerification,
                                  ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _refreshProfile,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Refresh Status'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PendingItemTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}



class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();

  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user");

    if (userJson != null) {
      final userData = jsonDecode(userJson);
      emailCtrl.text = userData["email"]?.toString() ?? '';
      setState(() {});
    }
  }

  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "";
    }
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^\S+@\S+\.\S+$');
    if (!regex.hasMatch(v.trim())) return 'Enter valid email';
    return null;
  }

  Future<void> _saveEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("api_token");

    if (token == null || token.isEmpty) {
      setState(() => saving = false);
      Fluttertoast.showToast(msg: "Session expired. Please login again.");
      return;
    }

    final userJson = prefs.getString("user");
    Map<String, dynamic> userData = {};

    if (userJson != null) {
      userData = jsonDecode(userJson);
    }

    final String deviceType = Platform.isAndroid ? "android" : "ios";
    final String deviceId = await getDeviceId();

    final res = await ApiService.multipart(
      endpoint: "/vendor/complete-profile",
      token: token,
      fields: {
        "name": userData["name"]?.toString() ?? "",
        "email": emailCtrl.text.trim(),
        "mobile": userData["mobile"]?.toString() ?? "",
        "password": "",
        "password_confirmation": "",
        "address_line1": userData["address_line1"]?.toString() ?? "",
        "address_line2": userData["address_line2"]?.toString() ?? "",
        "city": userData["city"]?.toString() ?? "",
        "state": userData["state"]?.toString() ?? "City",
        "country": userData["country"]?.toString() ?? "tajikistan",
        "postal_code": userData["postal_code"]?.toString() ?? "12232",
        "latitude": userData["latitude"]?.toString() ?? "",
        "longitude": userData["longitude"]?.toString() ?? "",
        "terms_accepted":  "1",
        "alt_mobile": userData["alt_mobile"]?.toString() ?? userData["mobile"]?.toString() ?? "",
        "device_id": deviceId,
        "device_type": deviceType,
        "fcm_token": userData["fcm_token"]?.toString() ?? "",
      },
      files: {},
    );

    setState(() => saving = false);

    if (res["success"] == true || res["status"] == true) {
      userData["email"] = emailCtrl.text.trim();

      await prefs.setString("user", jsonEncode(userData));
      await prefs.setString("user_email", emailCtrl.text.trim());

      Fluttertoast.showToast(msg: "Email updated successfully");
      if (mounted) Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(msg: res["message"] ?? "Failed to update email");
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verification"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Please add your email to complete your profile.",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: _emailValidator,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Enter your email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: saving ? null : _saveEmail,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Save Email",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}