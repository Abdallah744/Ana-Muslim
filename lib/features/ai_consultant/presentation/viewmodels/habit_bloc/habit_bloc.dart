import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/services/background_sync_service.dart';

part 'habit_event.dart';
part 'habit_state.dart';

class Habit {
  final String id;
  final String title;
  final String subtitle;
  bool isCompleted;
  final IconData icon;

  Habit({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    required this.icon,
  });
}

class QuitHabit {
  final String id;
  final String title;
  int streakDays;
  final String subtitle;
  final IconData icon;

  QuitHabit({
    required this.id,
    required this.title,
    required this.streakDays,
    required this.subtitle,
    required this.icon,
  });
}

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  List<Habit> _goodHabits = [];
  List<QuitHabit> _quitHabits = [];

  HabitBloc() : super(HabitInitial()) {
    on<LoadHabitsEvent>(_onLoadHabits);
    on<ToggleHabitEvent>(_onToggleHabit);
    on<IncrementQuitHabitEvent>(_onIncrementQuitHabit);
    on<ResetQuitHabitEvent>(_onResetQuitHabit);
    on<AddQuitHabitEvent>(_onAddQuitHabit);
    add(LoadHabitsEvent());
  }

  Future<void> _onLoadHabits(
    LoadHabitsEvent event,
    Emitter<HabitState> emit,
  ) async {
    _goodHabits = [
      Habit(
        id: '1',
        title: 'حفظ ورد القرآن',
        subtitle: 'مراجعة صفحة يومياً',
        icon: Icons.menu_book,
      ),
      Habit(
        id: '2',
        title: 'أذكار الصباح',
        subtitle: 'حماية وتحصين ليومك',
        icon: Icons.wb_sunny,
      ),
      Habit(
        id: '3',
        title: 'الاستغفار ١٠٠ مرة',
        subtitle: 'تغسل ذنوب اليوم',
        icon: Icons.favorite,
      ),
      Habit(
        id: '4',
        title: 'صلاة الوتر',
        subtitle: 'ركعات ختامية لليلة',
        icon: Icons.nights_stay,
      ),
    ];

    _quitHabits = [
      QuitHabit(
        id: '1',
        title: 'ترك الغيبة',
        streakDays: 1,
        subtitle: 'التزام وحفظ للسان',
        icon: Icons.record_voice_over,
      ),
      QuitHabit(
        id: '2',
        title: 'تقليل التصفح',
        streakDays: 1,
        subtitle: 'استثمار للوقت والجهد',
        icon: Icons.phonelink_erase,
      ),
    ];

    final prefs = await SharedPreferences.getInstance();

    // Load good habits state
    for (var habit in _goodHabits) {
      habit.isCompleted = prefs.getBool('habit_${habit.id}') ?? false;
    }

    // Load quit habits real streak counters
    for (var qHabit in _quitHabits) {
      qHabit.streakDays = prefs.getInt('quit_habit_${qHabit.id}') ?? (qHabit.id == '1' ? 12 : 7);
    }

    _emitLoadedState(emit);
  }

  Future<void> _onToggleHabit(
    ToggleHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    final index = _goodHabits.indexWhere((h) => h.id == event.id);
    if (index != -1) {
      _goodHabits[index].isCompleted = !_goodHabits[index].isCompleted;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('habit_${event.id}', _goodHabits[index].isCompleted);
      _emitLoadedState(emit);
    }
  }

  Future<void> _onIncrementQuitHabit(
    IncrementQuitHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    final index = _quitHabits.indexWhere((q) => q.id == event.id);
    if (index != -1) {
      _quitHabits[index].streakDays += 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quit_habit_${event.id}', _quitHabits[index].streakDays);
      _emitLoadedState(emit);
    }
  }

  Future<void> _onResetQuitHabit(
    ResetQuitHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    final index = _quitHabits.indexWhere((q) => q.id == event.id);
    if (index != -1) {
      _quitHabits[index].streakDays = 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quit_habit_${event.id}', 1);
      _emitLoadedState(emit);
    }
  }

  Future<void> _onAddQuitHabit(
    AddQuitHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    final newId = (DateTime.now().millisecondsSinceEpoch % 10000).toString();
    final newHabit = QuitHabit(
      id: newId,
      title: event.title,
      streakDays: 1,
      subtitle: event.subtitle.isNotEmpty ? event.subtitle : 'عزيمة وتغيير جديد',
      icon: Icons.shield_outlined,
    );
    _quitHabits.add(newHabit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quit_habit_$newId', 1);
    _emitLoadedState(emit);
  }

  void _emitLoadedState(Emitter<HabitState> emit) {
    int completedCount = _goodHabits.where((h) => h.isCompleted).length;
    double progress =
        _goodHabits.isEmpty ? 0 : completedCount / _goodHabits.length;

    // Trigger silent background sync to Supabase via Workmanager
    BackgroundSyncService.triggerOneOffSync();

    emit(HabitLoaded(
      goodHabits: List.from(_goodHabits),
      quitHabits: List.from(_quitHabits),
      progress: progress,
      completedCount: completedCount,
      totalCount: _goodHabits.length,
    ));
  }
}
