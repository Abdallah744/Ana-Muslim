part of 'lessons_bloc.dart';

abstract class LessonsEvent {}

class FetchLessonsEvent extends LessonsEvent {}

class SearchLessonsEvent extends LessonsEvent {
  final String query;
  SearchLessonsEvent(this.query);
}
