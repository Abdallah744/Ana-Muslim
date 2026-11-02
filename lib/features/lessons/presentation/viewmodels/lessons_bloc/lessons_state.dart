part of 'lessons_bloc.dart';

abstract class LessonsState {}

class LessonsInitial extends LessonsState {}

class LessonsLoading extends LessonsState {}

class LessonsLoaded extends LessonsState {
  final List<LessonModel> lessons;
  LessonsLoaded(this.lessons);
}

class LessonsError extends LessonsState {
  final String message;
  LessonsError(this.message);
}
