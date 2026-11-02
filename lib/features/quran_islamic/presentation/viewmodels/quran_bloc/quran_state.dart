part of 'quran_bloc.dart';
abstract class QuranState {}
class QuranInitial extends QuranState {}
class QuranLoading extends QuranState {}
class QuranLoaded extends QuranState {
  final List<SurahModel> surahs;
  final String lastReadSurahName;
  final String lastReadSurahDetails;
  QuranLoaded(this.surahs, this.lastReadSurahName, this.lastReadSurahDetails);
}
class QuranError extends QuranState {
  final String message;
  QuranError(this.message);
}
