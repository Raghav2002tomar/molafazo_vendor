// lib/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:molafzo_vendor/extensions/context_extension.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../auth/screens/SignInScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  late final _pages =  [
    _OnbPageData(
      image: 'assets/images/onb_3.jpg',
      title: context.tr('txt_onboard_1_title'),
      subtitle:
      context.tr('txt_onboard_1_desc'),
    ),
    _OnbPageData(
      image: 'assets/images/onb_2.jpg',
      title: context.tr('txt_onboard_2_title'),
      subtitle:
      context.tr('txt_onboard_2_desc'),
    ),
    _OnbPageData(
      image: 'assets/images/onb_1.jpg',
      title: context.tr('txt_onboard_3_title'),
      subtitle:
      context.tr('txt_onboard_3_desc'),
    ),
  ];

  void _finish() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInScreen()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // PAGES
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => _OnbPage(data: _pages[i]),
          ),

          // Top-right Skip
          Positioned(
            right: 16,
            top: 24,
            child: TextButton(
              onPressed: _finish,
              child: Row(
                children: [
                   Text(
                     context.tr('txt_skip'),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600,fontSize: 16),
                  ),
                  SizedBox(width: 5,),
                  Container(decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),color: Colors.white
                  ), child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(Icons.arrow_forward_ios_rounded,color: Colors.black,size: 12,),
                  ))
                ],
              ),
            ),
          ),

          // Bottom content: indicator + button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bars look
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 6,
                      dotWidth: 22,
                      spacing: 8,
                      radius: 6,
                      dotColor: Colors.white.withOpacity(0.35),
                      activeDotColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CTA
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // green from mock
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _index == _pages.length - 1
                          ? _finish
                          : () => _controller.nextPage(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOut,
                      ),
                      child: Text(_index == _pages.length - 1 ? context.tr('txt_get_started') : context.tr('txt_get_started'),style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnbPageData {
  final String image;
  final String title;
  final String subtitle;
  const _OnbPageData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class _OnbPage extends StatelessWidget {
  final _OnbPageData data;
  const _OnbPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image with dark overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(data.image),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.45),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
        ),
        // Bottom-left texts
        Positioned(bottom: 100,
          // alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: size.width * 0.85),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                ],

              ),
            ),

          ),
        ),
        SizedBox(height: 30,)
      ],
    );
  }
}
