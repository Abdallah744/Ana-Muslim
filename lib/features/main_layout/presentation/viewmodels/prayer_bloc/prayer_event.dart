part of 'prayer_bloc.dart';
abstract class PrayerEvent {}
class InitPrayersEvent extends PrayerEvent {}
class UpdatePrayerInfoEvent extends PrayerEvent {}
