import 'package:flutter_test/flutter_test.dart';
import 'package:ana_muslim/features/quran_islamic/data/models/surah_model.dart';

void main() {
  group('SurahModel Unit Test', () {
    test('should parse SurahModel json correctly with ayahs', () {
      final Map<String, dynamic> json = {
        'id': 1,
        'name': 'الفاتحة',
        'name_en': 'The Opening',
        'type': 'مكية',
        'array': [
          {'id': 1, 'ar': 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ', 'en': 'In the name of Allah'}
        ]
      };

      final surah = SurahModel.fromJson(json);

      expect(surah.id, equals(1));
      expect(surah.name, equals('الفاتحة'));
      expect(surah.type, equals('مكية'));
      expect(surah.array.length, equals(1));
      expect(surah.array.first.ar, equals('بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ'));
    });
  });
}
