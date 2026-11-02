import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../data/datasources/audio_cache_service.dart';

part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioCacheService _audioCacheService = AudioCacheService();
  StreamSubscription? _playerStateSubscription;

  AudioBloc() : super(AudioInitial()) {
    on<CheckSurahDownloadStatusEvent>(_onCheckDownloadStatus);
    on<PlaySurahEvent>(_onPlaySurah);
    on<PauseSurahEvent>(_onPauseSurah);
    on<DownloadSurahEvent>(_onDownloadSurah);

    _playerStateSubscription = _audioCacheService.playerStateStream.listen((state) {
      add(_PlayerStateChangedEvent(state));
    });

    on<_PlayerStateChangedEvent>((event, emit) {
      if (state is AudioPlaying) {
        emit(AudioPlaying(isPlaying: event.state.playing, isDownloaded: (state as AudioPlaying).isDownloaded));
      }
    });

    on<_DownloadProgressUpdatedEvent>(_onDownloadProgressUpdated);
  }

  Future<void> _onCheckDownloadStatus(CheckSurahDownloadStatusEvent event, Emitter<AudioState> emit) async {
    bool isDownloaded = await _audioCacheService.isSurahDownloaded(event.reciterId, event.surahNumber);
    emit(AudioInitial(isDownloaded: isDownloaded));
  }

  Future<void> _onPlaySurah(PlaySurahEvent event, Emitter<AudioState> emit) async {
    bool isDownloaded = await _audioCacheService.isSurahDownloaded(event.reciterId, event.surahNumber);
    emit(AudioPlaying(isPlaying: true, isDownloaded: isDownloaded));
    
    try {
      await _audioCacheService.playSurah(
        reciterId: event.reciterId,
        surahNumber: event.surahNumber,
        apiUrl: event.apiUrl,
      );
    } catch (e) {
      emit(AudioError("فشل في التشغيل: $e"));
    }
  }

  Future<void> _onPauseSurah(PauseSurahEvent event, Emitter<AudioState> emit) async {
    await _audioCacheService.pauseSurah();
    if (state is AudioPlaying) {
      emit(AudioPlaying(isPlaying: false, isDownloaded: (state as AudioPlaying).isDownloaded));
    }
  }

  Future<void> _onDownloadSurah(DownloadSurahEvent event, Emitter<AudioState> emit) async {
    emit(AudioDownloading(progress: 0.0));
    try {
      await _audioCacheService.downloadSurah(
        reciterId: event.reciterId,
        surahNumber: event.surahNumber,
        apiUrl: event.apiUrl,
        onProgressChanged: (progress) {
          add(_DownloadProgressUpdatedEvent(progress));
        },
      );
      emit(AudioInitial(isDownloaded: true));
    } catch (e) {
      emit(AudioError("فشل التحميل: $e"));
    }
  }
  
  // دالة تحديث نسبة التحميل من البث
  void _onDownloadProgressUpdated(_DownloadProgressUpdatedEvent event, Emitter<AudioState> emit) {
    if (state is AudioDownloading) {
      emit(AudioDownloading(progress: event.progress));
    }
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _audioCacheService.dispose();
    return super.close();
  }
}
