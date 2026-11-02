import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/quran_local_data_source.dart';
import '../../../data/models/azkar_model.dart';
part 'azkar_event.dart';
part 'azkar_state.dart';

class AzkarBloc extends Bloc<AzkarEvent, AzkarState> {
  final QuranLocalDataSource _dataSource = QuranLocalDataSource();

  AzkarBloc() : super(AzkarInitial()) {
    on<LoadAzkarDataEvent>(_onLoadData);
  }

  Future<void> _onLoadData(LoadAzkarDataEvent event, Emitter<AzkarState> emit) async {
    emit(AzkarLoading());
    try {
      final data = await _dataSource.getAzkarData();
      Map<String, dynamic> jsonMap = data as Map<String, dynamic>;
      List<dynamic> categoriesJson = jsonMap.values.first; 
      final categories = categoriesJson.map((e) => ZikrCategoryModel.fromJson(e)).toList();
      emit(AzkarLoaded(categories));
    } catch (e) {
      emit(AzkarError(e.toString()));
    }
  }
}
