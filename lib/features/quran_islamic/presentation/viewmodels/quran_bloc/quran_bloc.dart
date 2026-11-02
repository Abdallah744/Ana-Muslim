import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/datasources/quran_local_data_source.dart';
import '../../../data/models/surah_model.dart';
part 'quran_event.dart';
part 'quran_state.dart';

class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final QuranLocalDataSource _dataSource = QuranLocalDataSource();
  List<SurahModel> _allSurahs = [];
  String _lastReadSurahName = 'سورة الفاتحة';
  String _lastReadSurahDetails = 'الجزء الأول - الصفحة ١';

  QuranBloc() : super(QuranInitial()) {
    on<LoadQuranDataEvent>(_onLoadData);
    on<SearchSurahEvent>(_onSearch);
    on<SaveLastReadSurahEvent>(_onSaveLastRead);
  }

  Future<void> _onLoadData(LoadQuranDataEvent event, Emitter<QuranState> emit) async {
    emit(QuranLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastReadSurahName = prefs.getString('last_read_surah_name') ?? 'سورة الفاتحة';
      _lastReadSurahDetails = prefs.getString('last_read_surah_details') ?? 'الجزء الأول - الصفحة ١';

      final data = await _dataSource.getQuranData();
      _allSurahs = data.map((e) => SurahModel.fromJson(e)).toList();
      emit(QuranLoaded(_allSurahs, _lastReadSurahName, _lastReadSurahDetails));
    } catch (e) {
      emit(QuranError(e.toString()));
    }
  }

  void _onSearch(SearchSurahEvent event, Emitter<QuranState> emit) {
    if (event.query.isEmpty) {
      emit(QuranLoaded(_allSurahs, _lastReadSurahName, _lastReadSurahDetails));
      return;
    }
    final filtered = _allSurahs.where((surah) => surah.name.contains(event.query) || surah.id.toString() == event.query).toList();
    emit(QuranLoaded(filtered, _lastReadSurahName, _lastReadSurahDetails));
  }

  Future<void> _onSaveLastRead(SaveLastReadSurahEvent event, Emitter<QuranState> emit) async {
    _lastReadSurahName = event.surahName;
    _lastReadSurahDetails = event.surahDetails;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_read_surah_name', _lastReadSurahName);
    await prefs.setString('last_read_surah_details', _lastReadSurahDetails);

    if (state is QuranLoaded) {
      emit(QuranLoaded((state as QuranLoaded).surahs, _lastReadSurahName, _lastReadSurahDetails));
    }
  }
}
