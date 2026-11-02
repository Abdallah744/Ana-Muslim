import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ana_muslim/core/constants/app_colors.dart';
import 'package:ana_muslim/features/auth/data/supabase_auth_remote_data_source.dart';
import 'package:ana_muslim/features/auth/presentation/views/login_screen.dart';
import 'package:ana_muslim/features/main_layout/presentation/views/main_layout_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    bool isGuest = await SupabaseAuthRemoteDataSource.isGuestUser();
    final session = Supabase.instance.client.auth.currentSession;

    Widget nextScreen = const LoginScreen();
    if (session != null || isGuest) {
      nextScreen = const MainLayoutScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B5345),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: LottieBuilder.asset(
                'assets/animations/splash_animation.json',
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.brightness_7,
                      color: AppColors.secondaryColor,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'أنا مسلم',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
