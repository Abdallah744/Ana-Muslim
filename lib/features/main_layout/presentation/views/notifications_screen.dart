import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/azan_notification_service.dart';
import '../../../../core/utils/responsive_utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _fajrEnabled = true;
  bool _dhuhrEnabled = true;
  bool _asrEnabled = true;
  bool _maghribEnabled = true;
  bool _ishaEnabled = true;

  bool _morningAzkarEnabled = true;
  bool _eveningAzkarEnabled = true;

  String _calculationMethod = 'أم القرى (مكة المكرمة)';
  bool _isPlayingAdhan = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _fajrEnabled = prefs.getBool('fajr_enabled') ?? true;
          _dhuhrEnabled = prefs.getBool('dhuhr_enabled') ?? true;
          _asrEnabled = prefs.getBool('asr_enabled') ?? true;
          _maghribEnabled = prefs.getBool('maghrib_enabled') ?? true;
          _ishaEnabled = prefs.getBool('isha_enabled') ?? true;

          _morningAzkarEnabled = prefs.getBool('morning_azkar_enabled') ?? true;
          _eveningAzkarEnabled = prefs.getBool('evening_azkar_enabled') ?? true;

          _calculationMethod = prefs.getString('calc_method') ?? 'أم القرى (مكة المكرمة)';
        });
      }
    } catch (_) {}
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _togglePlayAdhan() async {
    if (_isPlayingAdhan) {
      await AzanNotificationService.stopAdhan();
      setState(() {
        _isPlayingAdhan = false;
      });
    } else {
      await AzanNotificationService.playAdhanInApp();
      setState(() {
        _isPlayingAdhan = true;
      });
    }
  }

  void _testNotification() async {
    await AzanNotificationService.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال إشعار تجريبي مع الأذان 🕌'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إعدادات الإشعارات والأذان'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: Responsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تنبيهات الأذان مفعّلة 🕌',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                                fontSize: context.respFont(15),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'يتم إرسال الإشعارات وتنبيهات الأذان في مواعيد الصلوات الخمس بدقة.',
                              style: TextStyle(
                                fontSize: context.respFont(12),
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: Prayer Toggles
                Text(
                  'تنبيهات الصلوات الخمس',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.respFont(16),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildPrayerSwitch(
                        title: 'صلاة الفجر',
                        subtitle: 'تنبيه وأذان الفجر',
                        icon: Icons.wb_twilight,
                        value: _fajrEnabled,
                        onChanged: (val) {
                          setState(() => _fajrEnabled = val);
                          _saveBool('fajr_enabled', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildPrayerSwitch(
                        title: 'صلاة الظهر',
                        subtitle: 'تنبيه وأذان الظهر',
                        icon: Icons.wb_sunny_outlined,
                        value: _dhuhrEnabled,
                        onChanged: (val) {
                          setState(() => _dhuhrEnabled = val);
                          _saveBool('dhuhr_enabled', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildPrayerSwitch(
                        title: 'صلاة العصر',
                        subtitle: 'تنبيه وأذان العصر',
                        icon: Icons.wb_sunny,
                        value: _asrEnabled,
                        onChanged: (val) {
                          setState(() => _asrEnabled = val);
                          _saveBool('asr_enabled', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildPrayerSwitch(
                        title: 'صلاة المغرب',
                        subtitle: 'تنبيه وأذان المغرب',
                        icon: Icons.nights_stay_outlined,
                        value: _maghribEnabled,
                        onChanged: (val) {
                          setState(() => _maghribEnabled = val);
                          _saveBool('maghrib_enabled', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildPrayerSwitch(
                        title: 'صلاة العشاء',
                        subtitle: 'تنبيه وأذان العشاء',
                        icon: Icons.dark_mode_outlined,
                        value: _ishaEnabled,
                        onChanged: (val) {
                          setState(() => _ishaEnabled = val);
                          _saveBool('isha_enabled', val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Section 2: Calculation Method
                Text(
                  'طريقة حساب مواقيت الصلاة',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.respFont(16),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryColor,
                      child: Icon(Icons.calculate_outlined, color: Colors.white, size: 20),
                    ),
                    title: const Text('طريقة الحساب المعتمدة'),
                    subtitle: Text(_calculationMethod),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showCalculationMethodDialog,
                  ),
                ),
                const SizedBox(height: 28),

                // Section 3: Daily Azkar Reminders
                Text(
                  'تنبيهات الأذكار اليومية',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.respFont(16),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildPrayerSwitch(
                        title: 'تنبيه أذكار الصباح',
                        subtitle: 'تذكير يومي بأذكار الصباح بعد صلاة الفجر',
                        icon: Icons.sunny,
                        value: _morningAzkarEnabled,
                        onChanged: (val) {
                          setState(() => _morningAzkarEnabled = val);
                          _saveBool('morning_azkar_enabled', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildPrayerSwitch(
                        title: 'تنبيه أذكار المساء',
                        subtitle: 'تذكير يومي بأذكار المساء بعد صلاة العصر',
                        icon: Icons.bedtime_outlined,
                        value: _eveningAzkarEnabled,
                        onChanged: (val) {
                          setState(() => _eveningAzkarEnabled = val);
                          _saveBool('evening_azkar_enabled', val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Section 4: Sound Testing & Actions
                Text(
                  'اختبار الصوت والتنبيهات المباشرة',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.respFont(16),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber.shade100,
                          child: Icon(
                            Icons.volume_up_rounded,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        title: const Text('إرسال إشعار تجريبي الآن'),
                        subtitle: const Text('اختبار ظهور الإشعار وصوت الأذان'),
                        trailing: ElevatedButton.icon(
                          onPressed: _testNotification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text('تجربة'),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _isPlayingAdhan
                              ? Colors.red.shade100
                              : AppColors.primaryColor.withOpacity(0.15),
                          child: Icon(
                            _isPlayingAdhan
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            color: _isPlayingAdhan
                                ? Colors.red
                                : AppColors.primaryColor,
                          ),
                        ),
                        title: Text(
                          _isPlayingAdhan
                              ? 'إيقاف صوت الأذان'
                              : 'استماع لصوت الأذان الكامل',
                        ),
                        subtitle: const Text('تشغيل الأذان بصوت الحرم المكي'),
                        trailing: OutlinedButton(
                          onPressed: _togglePlayAdhan,
                          child: Text(_isPlayingAdhan ? 'إيقاف' : 'تشغيل'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.primaryColor,
      activeThumbColor: Colors.white,
      secondary: CircleAvatar(
        backgroundColor: value
            ? AppColors.primaryColor.withOpacity(0.15)
            : Colors.grey.shade200,
        child: Icon(
          icon,
          color: value ? AppColors.primaryColor : Colors.grey,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: context.respFont(14),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: context.respFont(12),
          color: Colors.grey,
        ),
      ),
    );
  }

  void _showCalculationMethodDialog() {
    final methods = [
      'أم القرى (مكة المكرمة)',
      'الهيئة المصرية العامة للمساحة',
      'رابطة العالم الإسلامي',
      'جامعة العلوم الإسلامية بكراتشي',
      'الاتحاد الإسلامي بأمريكا الشمالية (ISNA)',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SimpleDialog(
            title: const Text('اختر طريقة حساب المواقيت'),
            children: methods.map((method) {
              final isSelected = method == _calculationMethod;
              return SimpleDialogOption(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                onPressed: () {
                  setState(() {
                    _calculationMethod = method;
                  });
                  _saveString('calc_method', method);
                  Navigator.pop(dialogContext);
                },
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? AppColors.primaryColor : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        method,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryColor : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
