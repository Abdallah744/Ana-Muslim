import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/quran_local_data_source.dart';
import '../../../data/models/hadith_model.dart';
part 'hadith_event.dart';
part 'hadith_state.dart';

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final QuranLocalDataSource _dataSource = QuranLocalDataSource();
  List<HadithModel> _allHadiths = [];

  HadithBloc() : super(HadithInitial()) {
    on<LoadHadithDataEvent>(_onLoadData);
    on<SearchHadithEvent>(_onSearch);
  }

  Future<void> _onLoadData(LoadHadithDataEvent event, Emitter<HadithState> emit) async {
    emit(HadithLoading());
    try {
      final data = await _dataSource.getHadithData();
      _allHadiths = data.map((e) => HadithModel.fromJson(e)).toList();
      emit(HadithLoaded(_allHadiths));
    } catch (e) {
      emit(HadithError(e.toString()));
    }
  }

  void _onSearch(SearchHadithEvent event, Emitter<HadithState> emit) {
    if (event.query.isEmpty) {
      emit(HadithLoaded(_allHadiths));
      return;
    }
    final filtered = _allHadiths.where((hadith) => hadith.hadith.contains(event.query) || hadith.description.contains(event.query)).toList();
    emit(HadithLoaded(filtered));
  }
}
