part of 'audio_bloc.dart';

abstract class AudioEvent {}

class CheckSurahDownloadStatusEvent extends AudioEvent {
  final String reciterId;
  final String surahNumber;
  CheckSurahDownloadStatusEvent({required this.reciterId, required this.surahNumber});
}

class PlaySurahEvent extends AudioEvent {
  final String reciterId;
  final String surahNumber;
  final String apiUrl;
  PlaySurahEvent({required this.reciterId, required this.surahNumber, required this.apiUrl});
}

class PauseSurahEvent extends AudioEvent {}

class DownloadSurahEvent extends AudioEvent {
  final String reciterId;
  final String surahNumber;
  final String apiUrl;
  DownloadSurahEvent({required this.reciterId, required this.surahNumber, required this.apiUrl});
}

class _PlayerStateChangedEvent extends AudioEvent {
  final PlayerState state;
  _PlayerStateChangedEvent(this.state);
}

class _DownloadProgressUpdatedEvent extends AudioEvent {
  final double progress;
  _DownloadProgressUpdatedEvent(this.progress);
}
