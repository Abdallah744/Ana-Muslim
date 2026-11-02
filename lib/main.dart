import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_bloc.dart';
import 'core/services/azan_notification_service.dart';
import 'core/services/background_sync_service.dart';
import 'features/main_layout/intro_pages/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run App UI immediately so first frame renders instantly without black screen
  runApp(
    BlocProvider(
      create: (context) => ThemeBloc(),
      child: const MyApp(),
    ),
  );

  // Initialize native services in background asynchronously
  _initServicesAsync();
}

Future<void> _initServicesAsync() async {
  try {
    await Supabase.initialize(
      url: 'https://mxjkazhwrknrxinlpaza.supabase.co',
      publishableKey: 'sb_publishable_xQ8IHjas-4QtiEcpD2hnYg_EsRAnvfs',
    );
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  try {
    await AzanNotificationService.init();
  } catch (e) {
    debugPrint('AzanNotificationService init error: $e');
  }

  try {
    await BackgroundSyncService.init();
  } catch (e) {
    debugPrint('BackgroundSyncService init error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = context.read<ThemeBloc>().isDark;
        return MaterialApp(
          title: 'أنا مسلم',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
