import 'package:flutter/material.dart';

class ProfileNotEligibleWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onUpdateTap;

  const ProfileNotEligibleWidget({
    super.key,
    this.title = "Profile not eligible",
    this.subtitle = "Please update your profile to continue",
    this.onUpdateTap,
  });

  @override
  State<ProfileNotEligibleWidget> createState() =>
      _ProfileNotEligibleWidgetState();
}

class _ProfileNotEligibleWidgetState extends State<ProfileNotEligibleWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    // Shake animation
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shake = Tween<double>(begin: -8, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(shake.value, 0),
                  child: ScaleTransition(
                    scale: _pulseController,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        size: 80,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            if (widget.onUpdateTap != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: widget.onUpdateTap,
                icon: const Icon(Icons.edit),
                label: const Text("Update Profile"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
