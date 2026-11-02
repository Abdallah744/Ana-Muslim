part of 'hadith_bloc.dart';
abstract class HadithState {}
class HadithInitial extends HadithState {}
class HadithLoading extends HadithState {}
class HadithLoaded extends HadithState {
  final List<HadithModel> hadiths;
  HadithLoaded(this.hadiths);
}
class HadithError extends HadithState {
  final String message;
  HadithError(this.message);
}
