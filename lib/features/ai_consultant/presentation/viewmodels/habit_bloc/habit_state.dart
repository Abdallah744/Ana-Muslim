part of 'habit_bloc.dart';
abstract class HabitState {}
class HabitInitial extends HabitState {}
class HabitLoaded extends HabitState {
  final List<Habit> goodHabits;
  final List<QuitHabit> quitHabits;
  final double progress;
  final int completedCount;
  final int totalCount;
  HabitLoaded({required this.goodHabits, required this.quitHabits, required this.progress, required this.completedCount, required this.totalCount});
}
