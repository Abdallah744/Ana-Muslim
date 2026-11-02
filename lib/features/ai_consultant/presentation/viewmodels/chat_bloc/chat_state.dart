part of 'chat_bloc.dart';
abstract class ChatState {}
class ChatInitial extends ChatState {}
class ChatUpdated extends ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  ChatUpdated(this.messages, {this.isLoading = false});
}
