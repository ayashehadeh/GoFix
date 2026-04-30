import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/usecases/chat_usecases.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChats extends ChatEvent {
  const LoadChats();
}

class LoadMessages extends ChatEvent {
  final String chatId;
  const LoadMessages(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String text;
  final String type;
  final String? attachmentPath;
  const SendMessageEvent({
    required this.chatId,
    required this.text,
    this.type = 'text',
    this.attachmentPath,
  });
  @override
  List<Object?> get props => [chatId, text, type, attachmentPath];
}

class DeleteChatEvent extends ChatEvent {
  final String chatId;
  const DeleteChatEvent(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<ChatPreviewEntity> chats;
  const ChatsLoaded(this.chats);
  @override
  List<Object?> get props => [chats];
}

class MessagesLoaded extends ChatState {
  final String chatId;
  final List<ChatMessageEntity> messages;
  const MessagesLoaded(this.chatId, this.messages);
  @override
  List<Object?> get props => [chatId, messages];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChats getChats;
  final GetMessages getMessages;
  final SendMessage sendMessage;
  final DeleteChat deleteChat;

  ChatBloc({
    required this.getChats,
    required this.getMessages,
    required this.sendMessage,
    required this.deleteChat,
  }) : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<DeleteChatEvent>(_onDeleteChat);
  }

  Future<void> _onLoadChats(
      LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await getChats();
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chats) => emit(ChatsLoaded(chats)),
    );
  }

  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await getMessages(event.chatId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) => emit(MessagesLoaded(event.chatId, messages)),
    );
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    final result = await sendMessage(
      chatId: event.chatId,
      text: event.text,
      type: event.type,
      attachmentPath: event.attachmentPath,
    );
    await result.fold(
      (failure) async => emit(ChatError(failure.message)),
      (_) async {
        final messagesResult = await getMessages(event.chatId);
        messagesResult.fold(
          (failure) => emit(ChatError(failure.message)),
          (messages) => emit(MessagesLoaded(event.chatId, messages)),
        );
      },
    );
  }

  Future<void> _onDeleteChat(
      DeleteChatEvent event, Emitter<ChatState> emit) async {
    await deleteChat(event.chatId);
    final result = await getChats();
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (chats) => emit(ChatsLoaded(chats)),
    );
  }
}
