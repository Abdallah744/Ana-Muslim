import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/lesson_model.dart';
import '../../../domain/usecases/get_lessons_usecase.dart';

part 'lessons_event.dart';
part 'lessons_state.dart';

class LessonsBloc extends Bloc<LessonsEvent, LessonsState> {
  final GetLessonsUseCase getLessonsUseCase;
  List<LessonModel> _allLessons = [];

  LessonsBloc({required this.getLessonsUseCase}) : super(LessonsInitial()) {
    on<FetchLessonsEvent>(_onFetchLessons);
    on<SearchLessonsEvent>(_onSearchLessons);
  }

  Future<void> _onFetchLessons(FetchLessonsEvent event, Emitter<LessonsState> emit) async {
    emit(LessonsLoading());
    try {
      _allLessons = await getLessonsUseCase.call();
      emit(LessonsLoaded(_allLessons));
    } catch (e) {
      emit(LessonsError(e.toString()));
    }
  }

  void _onSearchLessons(SearchLessonsEvent event, Emitter<LessonsState> emit) {
    if (event.query.isEmpty) {
      emit(LessonsLoaded(_allLessons));
      return;
    }
    final filtered = _allLessons.where((lesson) {
      return lesson.title.contains(event.query) || lesson.author.contains(event.query);
    }).toList();
    emit(LessonsLoaded(filtered));
  }
}
