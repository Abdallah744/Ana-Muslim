part of 'quran_bloc.dart';
abstract class QuranEvent {}
class LoadQuranDataEvent extends QuranEvent {}
class SearchSurahEvent extends QuranEvent {
  final String query;
  SearchSurahEvent(this.query);
}
class SaveLastReadSurahEvent extends QuranEvent {
  final String surahName;
  final String surahDetails;
  SaveLastReadSurahEvent(this.surahName, this.surahDetails);
}
