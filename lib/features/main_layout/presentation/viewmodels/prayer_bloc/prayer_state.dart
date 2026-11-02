part of 'prayer_bloc.dart';
abstract class PrayerState {}
class PrayerInitial extends PrayerState {}
class PrayerLoaded extends PrayerState {
  final String currentNextPrayerName;
  final int remainingMinutes;
  final String nextPrayerTimeString;
  final String subtextString;
  PrayerLoaded({
    required this.currentNextPrayerName,
    required this.remainingMinutes,
    required this.nextPrayerTimeString,
    required this.subtextString,
  });
}
