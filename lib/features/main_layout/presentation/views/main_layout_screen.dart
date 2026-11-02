import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../auth/data/supabase_auth_remote_data_source.dart';
import '../../../auth/presentation/views/login_screen.dart';
import '../../../quran_islamic/presentation/views/quran_tools_screen.dart';
import '../../../ai_consultant/presentation/views/ai_consultant_screen.dart';
import '../../../ai_consultant/presentation/views/habit_tracker_screen.dart';
import '../../../ai_consultant/presentation/viewmodels/chat_bloc/chat_bloc.dart';
import '../../../ai_consultant/domain/usecases/get_ai_response_usecase.dart';
import '../../../ai_consultant/data/repositories/ai_consultant_repository_impl.dart';
import '../../../ai_consultant/data/datasources/gemini_remote_data_source.dart';
import 'home_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  bool _isGuest = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
    _screens = [
      const HomeScreen(),
      const QuranToolsScreen(),
      BlocProvider(
        create: (context) => ChatBloc(
          getAiResponseUseCase: GetAiResponseUseCase(
            AiConsultantRepositoryImpl(
              remoteDataSource: GeminiRemoteDataSource(),
            ),
          ),
        ),
        child: const AiConsultantScreen(),
      ),
      const HabitTrackerScreen(),
    ];
  }

  Future<void> _checkGuestStatus() async {
    final isGuest = await SupabaseAuthRemoteDataSource.isGuestUser();
    if (mounted) {
      setState(() {
        _isGuest = isGuest;
      });
    }
  }

  void _onTabTapped(int index) {
    if (_isGuest && (index == 2 || index == 3)) {
      _showGuestLoginPrompt(index == 2 ? 'المستشار الذكي' : 'لوحة العادات');
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showGuestLoginPrompt(String featureName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.lock_outline, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'خاصية تتطلب حساباً',
                  style: TextStyle(fontSize: dialogContext.respFont(17)),
                ),
              ],
            ),
            content: Text(
              'خاصية "$featureName" مخصصة للمستخدمين المسجلين لحفظ السجلات وتطوير العادات والإرشادات الشخصية.\n\nسجل الدخول الآن مجاناً للاستمتاع بكافة الميزات!',
              style: TextStyle(fontSize: dialogContext.respFont(13.5), height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 42),
                ),
                child: const Text('تسجيل الدخول الآن'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens.map((screen) {
            final screenIndex = _screens.indexOf(screen);
            if (_isGuest && (screenIndex == 2 || screenIndex == 3)) {
              return _buildGuestRestrictedScreen(
                screenIndex == 2 ? 'المستشار الذكي' : 'لوحة العادات',
              );
            }
            return screen;
          }).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'المصحف والأدوات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'المستشار AI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart_outlined),
              activeIcon: Icon(Icons.insert_chart),
              label: 'لوحة العادات',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestRestrictedScreen(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: Responsive.pagePadding(context),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    size: 64,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'متاحة للمستخدمين المسجلين 🔒',
                  style: TextStyle(
                    fontSize: context.respFont(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'قم بتسجيل الدخول للاستفادة من ميزة $title وحفظ تقدمك وعاداتك في حسابك.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: context.respFont(13.5),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('تسجيل الدخول / إنشاء حساب'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(220, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
