// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../quran_islamic/presentation/views/tasbeeh_screen.dart';
import '../../../quran_islamic/presentation/views/azkar_screen.dart';
import '../../../quran_islamic/presentation/views/qibla_screen.dart';
import '../../../profile/presentation/views/profile_screen.dart';
import '../../../lessons/presentation/views/lessons_screen.dart';
import '../viewmodels/prayer_bloc/prayer_bloc.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PrayerBloc(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _cityName = 'الرياض';

  @override
  void initState() {
    super.initState();
    _getLocationAndCity();
  }

  Future<void> _getLocationAndCity() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 10),
        );

        List<geocoding.Placemark> placemarks = await geocoding.Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final detectedCity = place.locality?.isNotEmpty == true
              ? place.locality
              : (place.subAdministrativeArea?.isNotEmpty == true
                  ? place.subAdministrativeArea
                  : (place.administrativeArea?.isNotEmpty == true
                      ? place.administrativeArea
                      : 'موقعك'));

          if (mounted && detectedCity != null) {
            setState(() {
              _cityName = detectedCity;
            });
          }
        }
      }
    } catch (e) {
      // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeBloc>().isDark;

    // Fetch username from Supabase
    final user = Supabase.instance.client.auth.currentUser;
    final String userName = user?.userMetadata?['full_name']?.toString().split(' ')[0] ?? 'ضيف';

    // Hijri date
    HijriCalendar.setLocal('ar');
    final hijriDate = HijriCalendar.now();
    final String todayDate = '${hijriDate.dayWeName} ${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear} هـ - $_cityName';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode_outlined),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleThemeEvent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'السلام عليكم، $userName',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: context.respFont(22),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                todayDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: context.respFont(12),
                ),
              ),
              const SizedBox(height: 20),

              // Prayer Card
              BlocBuilder<PrayerBloc, PrayerState>(
                builder: (context, state) {
                  String prayerName = 'المغرب';
                  String timeStr = '٦:١٨ م';
                  String remaining = '٤٥:٠٠';
                  String subtext = 'العشاء - ٧:٤٥ م';

                  if (state is PrayerLoaded) {
                    prayerName = state.currentNextPrayerName;
                    timeStr = state.nextPrayerTimeString;

                    int hrs = state.remainingMinutes ~/ 60;
                    int mins = state.remainingMinutes % 60;
                    remaining = hrs > 0
                        ? '$hrs:${mins.toString().padLeft(2, '0')}'
                        : '${mins.toString().padLeft(2, '0')}:٠٠';

                    subtext = state.subtextString;
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Countdown Ring
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondaryColor,
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    remaining,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.respFont(16),
                                    ),
                                  ),
                                ),
                                const Text(
                                  'متبقي للصلاة',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Prayer Info
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'الصلاة القادمة',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: context.respFont(13),
                                ),
                              ),
                              Text(
                                prayerName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.respFont(26),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    timeStr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.respFont(15),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtext,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: context.respFont(11.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Daily Companion (رفيق يومك)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'رفيق يومك',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.respFont(16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCompanionItem(context, Icons.book_outlined, 'الأذكار', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AzkarScreen(),
                      ),
                    );
                  }),
                  _buildCompanionItem(
                    context,
                    Icons.circle_outlined,
                    'السبحة',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TasbeehScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCompanionItem(
                    context,
                    Icons.explore_outlined,
                    'اتجاه القبلة',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QiblaScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCompanionItem(
                    context,
                    Icons.school_outlined,
                    'الدروس',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LessonsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Lessons section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المكتبة الدعوية والدروس',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.respFont(16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LessonsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'تصفح الكل',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: context.respFont(13),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLessonItem(
                context,
                'الخشوع في الصلاة',
                'الشيخ عمر عبد الكافي',
                'اضغط للاستماع والتحميل',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LessonsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildLessonItem(
                context,
                'معاني أسماء الله الحسنى',
                'الشيخ عبد الرزاق البدر',
                'محفوظ من حلقات • ١٥ دقيقة',
              ),
              const SizedBox(height: 12),
              _buildLessonItem(
                context,
                'فقه الأذكار اليومية',
                'الشيخ خالد الشايع',
                'محفوظ من مقاطع • ١٢ دقيقة',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanionItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 5,
                )
              ],
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: context.respFont(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(
    BuildContext context,
    String title,
    String subtitle,
    String duration,
    [VoidCallback? onTap]
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.play_circle_fill, color: AppColors.primaryColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: context.respFont(14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: context.respFont(12),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    duration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: context.respFont(10.5),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: AppColors.primaryColor),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
