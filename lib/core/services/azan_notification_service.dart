import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:adhan/adhan.dart';
import 'package:just_audio/just_audio.dart';

class AzanNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();
      try {
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint('Error setting local timezone: $e');
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          await stopAdhan();
        },
      );

      // Create Notification Channel for Android 8.0+
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'azan_channel_v2',
        'تنبيهات الأذان',
        description: 'قناة إشعارات تنبيهات الصلوات الخمس مع صوت الأذان',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
      );

      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.createNotificationChannel(channel);

      // Request notifications permission safely without blocking
      try {
        await androidImplementation?.requestNotificationsPermission();
      } catch (_) {}
    } catch (e) {
      debugPrint('AzanNotificationService init error: $e');
    }
  }

  static Future<void> schedulePrayerNotifications({
    required Coordinates coordinates,
    required CalculationParameters params,
  }) async {
    try {
      await _notificationsPlugin.cancelAll();

      final now = DateTime.now();
      int notificationId = 1;

      for (int i = 0; i < 7; i++) {
        final date = now.add(Duration(days: i));
        final dateComponents = DateComponents(date.year, date.month, date.day);
        final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

        final List<Map<String, dynamic>> prayers = [
          {'id': notificationId++, 'name': 'صلاة الفجر', 'time': prayerTimes.fajr},
          {'id': notificationId++, 'name': 'صلاة الظهر', 'time': prayerTimes.dhuhr},
          {'id': notificationId++, 'name': 'صلاة العصر', 'time': prayerTimes.asr},
          {'id': notificationId++, 'name': 'صلاة المغرب', 'time': prayerTimes.maghrib},
          {'id': notificationId++, 'name': 'صلاة العشاء', 'time': prayerTimes.isha},
        ];

        for (var prayer in prayers) {
          final DateTime time = prayer['time'];
          if (time.isAfter(now)) {
            await _scheduleSingleNotification(
              id: prayer['id'],
              title: 'حان الآن وقت ${prayer['name']} 🕌',
              body: 'الله أكبر الله أكبر - حان وقت ${prayer['name']}',
              scheduledTime: time,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error scheduling prayer notifications: $e');
    }
  }

  static Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'azan_channel_v2',
        'تنبيهات الأذان',
        channelDescription: 'قناة إشعارات تنبيهات الصلوات الخمس مع صوت الأذان',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('adhan'),
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        fullScreenIntent: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          sound: 'adhan.mp3',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error scheduling single notification: $e');
    }
  }

  static Future<void> showTestNotification() async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'azan_channel_v2',
        'تنبيهات الأذان',
        channelDescription: 'قناة إشعارات تنبيهات الصلوات الخمس مع صوت الأذان',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('adhan'),
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          sound: 'adhan.mp3',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.show(
        id: 999,
        title: 'تجربة إشعار الأذان 🕌',
        body: 'الله أكبر الله أكبر - تجربة صوت الأذان الإشعاري',
        notificationDetails: notificationDetails,
      );

      await playAdhanInApp();
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }

  static Future<void> playAdhanInApp() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset('assets/audio/adhan.mp3');
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing Adhan in app: $e');
    }
  }

  static Future<void> stopAdhan() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping Adhan: $e');
    }
  }

  static bool isAdhanPlaying() {
    return _audioPlayer.playing;
  }
}
