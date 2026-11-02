import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
part 'tasbeeh_event.dart';
part 'tasbeeh_state.dart';

class TasbeehBloc extends Bloc<TasbeehEvent, TasbeehState> {
  int _count = 0;
  static const String _countKey = 'tasbeeh_count';
  int get count => _count;

  TasbeehBloc() : super(TasbeehInitial()) {
    on<LoadTasbeehEvent>(_onLoad);
    on<IncrementTasbeehEvent>(_onIncrement);
    on<ResetTasbeehEvent>(_onReset);
    add(LoadTasbeehEvent());
  }

  Future<void> _onLoad(LoadTasbeehEvent event, Emitter<TasbeehState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    _count = prefs.getInt(_countKey) ?? 0;
    emit(TasbeehUpdated(_count));
  }

  Future<void> _onIncrement(IncrementTasbeehEvent event, Emitter<TasbeehState> emit) async {
    _count++;
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, _count);
    emit(TasbeehUpdated(_count));
  }

  Future<void> _onReset(ResetTasbeehEvent event, Emitter<TasbeehState> emit) async {
    _count = 0;
    HapticFeedback.vibrate();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, _count);
    emit(TasbeehUpdated(_count));
  }
}
