import 'package:flutter_test/flutter_test.dart';
import 'package:adhan/adhan.dart';

void main() {
  group('Prayer Calculation Tests', () {
    test('Calculates prayer times correctly for given coordinates', () {
      final coordinates = Coordinates(24.7136, 46.6753); // Riyadh
      final params = CalculationMethod.umm_al_qura.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes.today(coordinates, params);

      expect(prayerTimes.fajr, isNotNull);
      expect(prayerTimes.dhuhr, isNotNull);
      expect(prayerTimes.asr, isNotNull);
      expect(prayerTimes.maghrib, isNotNull);
      expect(prayerTimes.isha, isNotNull);

      expect(prayerTimes.dhuhr.isAfter(prayerTimes.fajr), isTrue);
      expect(prayerTimes.asr.isAfter(prayerTimes.dhuhr), isTrue);
      expect(prayerTimes.maghrib.isAfter(prayerTimes.asr), isTrue);
      expect(prayerTimes.isha.isAfter(prayerTimes.maghrib), isTrue);
    });

    test('Formats time in 12-hour format with AM/PM', () {
      final time = DateTime(2025, 5, 20, 15, 30); // 3:30 PM
      int hour = time.hour;
      String period = hour >= 12 ? 'م' : 'ص';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      final formatted = '$hour:${time.minute.toString().padLeft(2, '0')} $period';

      expect(formatted, equals('3:30 م'));
    });
  });
}
