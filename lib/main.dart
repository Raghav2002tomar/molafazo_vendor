import 'package:flutter/material.dart';
import 'package:molafzo_vendor/providers/theme_provider.dart';
import 'package:molafzo_vendor/providers/translate_provider.dart';
import 'package:molafzo_vendor/screens/Dashboard/main_bottom_bar.dart';
import 'package:molafzo_vendor/screens/onboarding/OnBoardingScreen.dart';
import 'package:molafzo_vendor/service/colors.dart' show AppTheme;
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/product_list_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ INIT HIVE
  await Hive.initFlutter();

  /// ✅ OPEN REQUIRED BOX BEFORE USE
  await Hive.openBox('app');

  /// OPTIONAL (keep if already used elsewhere)
  await StorageService.init();

  final translateProvider = TranslateProvider();
  await translateProvider.init();

  runApp(Root(translateProvider: translateProvider));
}

class Root extends StatelessWidget {
  final TranslateProvider translateProvider;
  const Root({super.key, required this.translateProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider.value(value: translateProvider),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeProvider>().mode;
    final langCode = context.watch<TranslateProvider>().locale; // String? like 'en'

    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        // ⏳ While loading prefs
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final prefs = snapshot.data!;
        final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

        return MaterialApp(
          title: 'ShopEase Professional',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,

          /// ✅ CORRECT Locale handling
          locale: langCode == null ? null : Locale(langCode),

          routes: {
            '/dashboard': (_) => const MainBottombarScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
          },

          /// ✅ LOGIN FLOW FIXED
          home: isLoggedIn
              ? const MainBottombarScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}
