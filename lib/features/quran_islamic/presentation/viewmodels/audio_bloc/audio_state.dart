part of 'audio_bloc.dart';

abstract class AudioState {}

class AudioInitial extends AudioState {
  final bool isDownloaded;
  AudioInitial({this.isDownloaded = false});
}

class AudioPlaying extends AudioState {
  final bool isPlaying;
  final bool isDownloaded;
  AudioPlaying({required this.isPlaying, required this.isDownloaded});
}

class AudioDownloading extends AudioState {
  final double progress;
  AudioDownloading({required this.progress});
}

class AudioError extends AudioState {
  final String message;
  AudioError(this.message);
}
