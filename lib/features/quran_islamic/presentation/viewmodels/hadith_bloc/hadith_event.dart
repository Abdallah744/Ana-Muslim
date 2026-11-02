part of 'hadith_bloc.dart';
abstract class HadithEvent {}
class LoadHadithDataEvent extends HadithEvent {}
class SearchHadithEvent extends HadithEvent {
  final String query;
  SearchHadithEvent(this.query);
}
