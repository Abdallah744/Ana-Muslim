part of 'habit_bloc.dart';

abstract class HabitEvent {}

class LoadHabitsEvent extends HabitEvent {}

class ToggleHabitEvent extends HabitEvent {
  final String id;
  ToggleHabitEvent(this.id);
}

class IncrementQuitHabitEvent extends HabitEvent {
  final String id;
  IncrementQuitHabitEvent(this.id);
}

class ResetQuitHabitEvent extends HabitEvent {
  final String id;
  ResetQuitHabitEvent(this.id);
}

class AddQuitHabitEvent extends HabitEvent {
  final String title;
  final String subtitle;
  AddQuitHabitEvent({required this.title, required this.subtitle});
}
