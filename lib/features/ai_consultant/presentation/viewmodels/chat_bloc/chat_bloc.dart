import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_ai_response_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetAiResponseUseCase getAiResponseUseCase;
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  ChatBloc({required this.getAiResponseUseCase}) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;
    _messages.add(ChatMessage(text: event.message, isUser: true));
    emit(ChatUpdated(List.from(_messages), isLoading: true));

    try {
      final response = await getAiResponseUseCase.call(event.message);
      _messages.add(ChatMessage(text: response, isUser: false));
      emit(ChatUpdated(List.from(_messages), isLoading: false));
    } catch (_) {
      // Warm fallback response
      _messages.add(
        ChatMessage(
          text:
              'أهلاً بك! نسأل الله أن يبارك لك في وقتك وعملك. كن متفائلاً واحرص على الأذكار والصلاة في أوقاتها.',
          isUser: false,
        ),
      );
      emit(ChatUpdated(List.from(_messages), isLoading: false));
    }
  }
}
