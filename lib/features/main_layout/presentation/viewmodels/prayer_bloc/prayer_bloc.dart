import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/services/azan_notification_service.dart';

part 'prayer_event.dart';
part 'prayer_state.dart';

class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  Timer? _timer;
  PrayerTimes? _prayerTimes;
  Coordinates? _userCoordinates;
  CalculationParameters? _calculationParams;
  String? _lastPlayedPrayerKey;

  PrayerBloc() : super(PrayerInitial()) {
    on<InitPrayersEvent>(_onInitPrayers);
    on<UpdatePrayerInfoEvent>(_onUpdatePrayerInfo);
    add(InitPrayersEvent());
  }

  Future<void> _onInitPrayers(InitPrayersEvent event, Emitter<PrayerState> emit) async {
    Coordinates myCoordinates = Coordinates(24.7136, 46.6753);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition();
          myCoordinates = Coordinates(position.latitude, position.longitude);
        }
      }
    } catch (e) {
      // default coordinates
    }
    
    _userCoordinates = myCoordinates;
    _calculationParams = CalculationMethod.umm_al_qura.getParameters();
    _calculationParams!.madhab = Madhab.shafi;

    _prayerTimes = PrayerTimes.today(_userCoordinates!, _calculationParams!);

    // Schedule 7-day automatic Adhan notifications
    try {
      await AzanNotificationService.schedulePrayerNotifications(
        coordinates: _userCoordinates!,
        params: _calculationParams!,
      );
    } catch (e) {
      // Error scheduling
    }

    add(UpdatePrayerInfoEvent());
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      add(UpdatePrayerInfoEvent());
    });
  }

  void _onUpdatePrayerInfo(UpdatePrayerInfoEvent event, Emitter<PrayerState> emit) {
    if (_prayerTimes == null || _userCoordinates == null || _calculationParams == null) return;
    
    final now = DateTime.now();
    // Refresh prayer times if date changed
    if (_prayerTimes!.fajr.day != now.day) {
      _prayerTimes = PrayerTimes.today(_userCoordinates!, _calculationParams!);
    }

    final nextPrayer = _prayerTimes!.nextPrayer();
    final nextPrayerTime = _prayerTimes!.timeForPrayer(nextPrayer);
    String prayerName = _getPrayerName(nextPrayer);
    
    int remainingMinutes = 0;
    if (nextPrayerTime != null) {
      remainingMinutes = nextPrayerTime.difference(now).inMinutes;
    }

    String nextNextPrayerTimeStr = '';
    if (nextPrayer == Prayer.maghrib) {
      final ishaTime = _prayerTimes!.isha;
      nextNextPrayerTimeStr = 'العشاء - ${_formatTime(ishaTime)}';
    } else {
      nextNextPrayerTimeStr = 'التالية - بعد حين';
    }

    // Check if current minute matches any prayer time for in-app Adhan playback
    _checkAndPlayInAppAdhan(now);

    emit(PrayerLoaded(
      currentNextPrayerName: prayerName,
      remainingMinutes: remainingMinutes > 0 ? remainingMinutes : 0,
      nextPrayerTimeString: nextPrayerTime != null ? _formatTime(nextPrayerTime) : '',
      subtextString: nextNextPrayerTimeStr,
    ));
  }

  void _checkAndPlayInAppAdhan(DateTime now) {
    if (_prayerTimes == null) return;

    final prayerMap = <Prayer, DateTime>{
      Prayer.fajr: _prayerTimes!.fajr,
      Prayer.dhuhr: _prayerTimes!.dhuhr,
      Prayer.asr: _prayerTimes!.asr,
      Prayer.maghrib: _prayerTimes!.maghrib,
      Prayer.isha: _prayerTimes!.isha,
    };

    prayerMap.forEach((prayer, time) {
      final diffSeconds = now.difference(time).inSeconds;
      if (diffSeconds >= 0 && diffSeconds < 60) {
        final key = '${now.year}-${now.month}-${now.day}-${prayer.name}';
        if (_lastPlayedPrayerKey != key) {
          _lastPlayedPrayerKey = key;
          AzanNotificationService.playAdhanInApp();
        }
      }
    });
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? 'م' : 'ص';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'الفجر';
      case Prayer.sunrise: return 'الشروق';
      case Prayer.dhuhr: return 'الظهر';
      case Prayer.asr: return 'العصر';
      case Prayer.maghrib: return 'المغرب';
      case Prayer.isha: return 'العشاء';
      case Prayer.none: return 'التالية غداً';
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
