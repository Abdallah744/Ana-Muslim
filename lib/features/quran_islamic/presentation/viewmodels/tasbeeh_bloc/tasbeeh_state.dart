part of 'tasbeeh_bloc.dart';
abstract class TasbeehState {}
class TasbeehInitial extends TasbeehState {}
class TasbeehUpdated extends TasbeehState {
  final int count;
  TasbeehUpdated(this.count);
}
