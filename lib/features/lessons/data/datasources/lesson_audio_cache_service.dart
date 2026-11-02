import 'dart:io';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class LessonAudioCacheService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Dio _dio = Dio();

  AudioPlayer get audioPlayer => _audioPlayer;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  /// Get local file path for a lesson audio file
  Future<String> _getLocalPath(int lessonId) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/lessons_audio';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '$path/lesson_$lessonId.mp3';
  }

  /// Check if lesson audio is downloaded locally
  Future<bool> isLessonDownloaded(int lessonId) async {
    final localFilePath = await _getLocalPath(lessonId);
    return File(localFilePath).existsSync();
  }

  /// Play lesson audio (offline from file if downloaded, or stream online if not)
  Future<void> playLesson({
    required int lessonId,
    required String audioUrl,
  }) async {
    final localFilePath = await _getLocalPath(lessonId);
    final fileExists = File(localFilePath).existsSync();

    if (fileExists) {
      await _audioPlayer.setFilePath(localFilePath);
    } else {
      await _audioPlayer.setUrl(audioUrl);
    }
    _audioPlayer.play();
  }

  /// Pause current audio
  Future<void> pauseLesson() async {
    await _audioPlayer.pause();
  }

  /// Download lesson audio file for offline listening
  Future<void> downloadLesson({
    required int lessonId,
    required String audioUrl,
    required Function(double progress) onProgress,
  }) async {
    if (audioUrl.isEmpty) {
      throw Exception('رابط الصوت غير متاح لهذا الدرس');
    }

    try {
      final localFilePath = await _getLocalPath(lessonId);
      await _dio.download(
        audioUrl,
        localFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total);
            onProgress(progress);
          }
        },
      );
    } catch (e) {
      throw Exception('فشل تحميل ملف الدرس الصوتي: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
