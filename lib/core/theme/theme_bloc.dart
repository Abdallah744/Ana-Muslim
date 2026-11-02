import 'package:flutter_bloc/flutter_bloc.dart';
part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  bool isDark = false;
  ThemeBloc() : super(ThemeChanged(false)) {
    on<ToggleThemeEvent>((event, emit) {
      isDark = !isDark;
      emit(ThemeChanged(isDark));
    });
  }
}
