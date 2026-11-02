import 'dart:io';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioCacheService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Dio _dio = Dio();

  // 1. دالة لجلب المسار الداخلي للهاتف وحفظ السورة بداخل مجلد خاص بالتطبيق
  Future<String> _getLocalPath(String reciterId, String surahNumber) async {
    final directory = await getApplicationDocumentsDirectory();
    // إنشاء مجلد مخصص للشيخ لمنع تداخل الملفات
    final path = '${directory.path}/quran_audio/$reciterId';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '$path/$surahNumber.mp3';
  }

  // 2. دالة التحقق: هل السورة محملة مسبقاً على جهاز المستخدم أوفلاين؟
  Future<bool> isSurahDownloaded(String reciterId, String surahNumber) async {
    final localFilePath = await _getLocalPath(reciterId, surahNumber);
    return File(localFilePath).existsSync();
  }

  // 3. دالة التشغيل الذكية (تشغل أوفلاين لو الملف موجود، أو تبث أونلاين لو مش موجود)
  Future<void> playSurah({
    required String reciterId,
    required String surahNumber,
    required String apiUrl, // رابط السورة المباشر المأخوذ من MP3Quran API
  }) async {
    final localFilePath = await _getLocalPath(reciterId, surahNumber);
    final fileExists = File(localFilePath).existsSync();

    if (fileExists) {
      // إذا كان الملف موجوداً محلياً، قم بتشغيله فوراً (أوفلاين بالكامل)
      await _audioPlayer.setFilePath(localFilePath);
    } else {
      // إذا لم يكن موجوداً، قم ببثه مباشرة من خوادم MP3Quran (أونلاين)
      await _audioPlayer.setUrl(apiUrl);
    }
    _audioPlayer.play();
  }

  // دالة الإيقاف المؤقت
  Future<void> pauseSurah() async {
    await _audioPlayer.pause();
  }

  // حالة المشغل
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  // 4. دالة تحميل السورة من MP3Quran وحفظها للعمل في وضع عدم الاتصال
  Future<void> downloadSurah({
    required String reciterId,
    required String surahNumber,
    required String apiUrl,
    required Function(double progress) onProgressChanged, // لعرض نسبة التحميل بالواجهة
  }) async {
    try {
      final localFilePath = await _getLocalPath(reciterId, surahNumber);

      // بدء تحميل الملف عبر حزمة Dio وحفظه في المسار المحلي المخصص للوضع أوفلاين
      await _dio.download(
        apiUrl,
        localFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total);
            onProgressChanged(progress); // إرسال التحديث لـ ViewModel لتحديث الـ UI
          }
        },
      );
    } catch (e) {
      throw Exception("فشل تحميل السورة الصوتيّة من خوادم MP3Quran: $e");
    }
  }

  // إغلاق المشغل عند الاستغناء عنه لتوفير موارد الجهاز
  void dispose() {
    _audioPlayer.dispose();
  }
}