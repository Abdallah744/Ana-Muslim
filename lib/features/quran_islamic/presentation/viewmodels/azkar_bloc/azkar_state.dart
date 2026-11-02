part of 'azkar_bloc.dart';
abstract class AzkarState {}
class AzkarInitial extends AzkarState {}
class AzkarLoading extends AzkarState {}
class AzkarLoaded extends AzkarState {
  final List<ZikrCategoryModel> categories;
  AzkarLoaded(this.categories);
}
class AzkarError extends AzkarState {
  final String message;
  AzkarError(this.message);
}
