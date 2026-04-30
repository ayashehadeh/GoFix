import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatPreviewModel>> getChats();
  Future<List<ChatMessageModel>> getMessages(String chatId);
  Future<ChatMessageModel> sendMessage(
      String chatId, String text, String type, String? attachmentPath);
  Future<void> deleteChat(String chatId);
  Future<ChatPreviewModel> getOrCreateChat(
      String professionalId, String professionalName);
}

/// Real implementation — swap to this when backend is ready.
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;
  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ChatPreviewModel>> getChats() async {
    final response = await dio.get('/chats');
    final data = response.data['data'] as List;
    return data.map((e) => ChatPreviewModel.fromJson(e)).toList();
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String chatId) async {
    final response = await dio.get('/chats/$chatId/messages');
    final data = response.data['data'] as List;
    return data.map((e) => ChatMessageModel.fromJson(e)).toList();
  }

  @override
  Future<ChatMessageModel> sendMessage(
      String chatId, String text, String type, String? attachmentPath) async {
    final response = await dio.post(
      '/chats/$chatId/messages',
      data: {
        'text': text,
        'type': type,
        'attachmentPath': attachmentPath,
      },
    );
    return ChatMessageModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await dio.delete('/chats/$chatId');
  }

  @override
  Future<ChatPreviewModel> getOrCreateChat(
      String professionalId, String professionalName) async {
    final response = await dio.post('/chats/getOrCreate', data: {
      'professionalId': professionalId,
      'professionalName': professionalName,
    });
    return ChatPreviewModel.fromJson(response.data['data']);
  }
}

/// Mock that persists to SharedPreferences so messages survive
/// between sessions. Singleton ensures the same data across screens.
class MockChatDataSource implements ChatRemoteDataSource {
  static final MockChatDataSource _instance = MockChatDataSource._internal();
  factory MockChatDataSource() => _instance;
  MockChatDataSource._internal();

  static const _chatsKey = 'mock_chats';
  static const _messagesPrefix = 'mock_messages_';

  List<ChatPreviewModel> get _initialChats => [
        ChatPreviewModel(
          id: '1',
          name: 'Mohammed Hassan',
          timeAgo:
              _formatDate(DateTime.now().subtract(const Duration(days: 2))),
        ),
        ChatPreviewModel(
          id: '2',
          name: 'Ahmad Khalil',
          timeAgo:
              _formatDate(DateTime.now().subtract(const Duration(days: 7))),
        ),
        ChatPreviewModel(
          id: '3',
          name: 'Ali Emad',
          timeAgo:
              _formatDate(DateTime.now().subtract(const Duration(days: 21))),
        ),
        ChatPreviewModel(
          id: '4',
          name: 'Tahleel khaled',
          timeAgo:
              _formatDate(DateTime.now().subtract(const Duration(days: 30))),
        ),
        ChatPreviewModel(
          id: '5',
          name: 'Abdullah Zaid',
          timeAgo:
              _formatDate(DateTime.now().subtract(const Duration(days: 35))),
        ),
        ChatPreviewModel(
          id: '6',
          name: "Ra'ed Mahmood",
          timeAgo:
              _formatDate(DateTime.now().subtract(const Duration(days: 60))),
        ),
      ];

  final Map<String, List<ChatMessageModel>> _initialMessages = {
    '2': const [
      ChatMessageModel(
          id: 'm1',
          text: 'Hello 👋 This is Ahmad, the plumber.',
          isMe: false,
          time: '8:09 am'),
      ChatMessageModel(
          id: 'm2',
          text: 'Hi Ahmad.\nJust confirming today\'s appointment',
          isMe: true,
          time: '8:10 am'),
      ChatMessageModel(
          id: 'm3',
          text: 'Yes 👍 it\'s scheduled for today at 4:00 pm.',
          isMe: false,
          time: '8:11 am'),
      ChatMessageModel(
          id: 'm4',
          text: 'Perfect, The issue is the kitchen sink leak.',
          isMe: true,
          time: '8:12 am'),
      ChatMessageModel(
          id: 'm5',
          text: 'Noted.\nI\'ll bring the necessary tools.',
          isMe: false,
          time: '8:13 am'),
      ChatMessageModel(
          id: 'm6', text: 'Great, See you later.', isMe: true, time: '8:14 am'),
      ChatMessageModel(
          id: 'm7',
          text: 'See you at 4 pm, Thanks.',
          isMe: false,
          time: '8:15 am'),
    ],
  };

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date); // Day name
    } else if (difference.inDays < 365) {
      return DateFormat('MMM d').format(date); // Jan 15
    } else {
      return DateFormat('MMM d, yyyy').format(date); // Jan 15, 2024
    }
  }

  @override
  Future<List<ChatPreviewModel>> getChats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_chatsKey);
    if (stored == null) {
      await prefs.setString(
          _chatsKey, jsonEncode(_initialChats.map((c) => c.toJson()).toList()));
      return _initialChats;
    }
    final list = jsonDecode(stored) as List;
    return list
        .map((e) => ChatPreviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final prefs = await SharedPreferences.getInstance();
    final key = '$_messagesPrefix$chatId';
    final stored = prefs.getString(key);
    if (stored == null) {
      final initial = _initialMessages[chatId] ?? [];
      await prefs.setString(
          key, jsonEncode(initial.map((m) => m.toJson()).toList()));
      return initial;
    }
    final list = jsonDecode(stored) as List;
    return list
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChatMessageModel> sendMessage(
      String chatId, String text, String type, String? attachmentPath) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final prefs = await SharedPreferences.getInstance();
    final key = '$_messagesPrefix$chatId';
    final messages = await getMessages(chatId);
    final newMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isMe: true,
      time: _formatNow(),
      type: type,
      attachmentPath: attachmentPath,
    );
    final updated = [...messages, newMsg];
    await prefs.setString(
        key, jsonEncode(updated.map((m) => m.toJson()).toList()));

    // Update chat preview timestamp
    await _updateChatTimestamp(chatId);

    return newMsg;
  }

  Future<void> _updateChatTimestamp(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final chats = await getChats();
    final updatedChats = chats.map((chat) {
      if (chat.id == chatId) {
        return ChatPreviewModel(
          id: chat.id,
          name: chat.name,
          timeAgo: _formatDate(DateTime.now()),
          imageUrl: chat.imageUrl,
        );
      }
      return chat;
    }).toList();
    await prefs.setString(
        _chatsKey, jsonEncode(updatedChats.map((c) => c.toJson()).toList()));
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final prefs = await SharedPreferences.getInstance();
    final chats = await getChats();
    final updated = chats.where((c) => c.id != chatId).toList();
    await prefs.setString(
        _chatsKey, jsonEncode(updated.map((c) => c.toJson()).toList()));
    await prefs.remove('$_messagesPrefix$chatId');
  }

  @override
  Future<ChatPreviewModel> getOrCreateChat(
      String professionalId, String professionalName) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final prefs = await SharedPreferences.getInstance();
    final chats = await getChats();

    // Check if chat already exists
    final existing = chats.where((c) => c.id == professionalId).toList();
    if (existing.isNotEmpty) {
      return existing.first;
    }

    // Create new chat
    final newChat = ChatPreviewModel(
      id: professionalId,
      name: professionalName,
      timeAgo: _formatDate(DateTime.now()),
    );

    final updatedChats = [newChat, ...chats];
    await prefs.setString(
        _chatsKey, jsonEncode(updatedChats.map((c) => c.toJson()).toList()));

    return newChat;
  }

  String _formatNow() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'am' : 'pm';
    return '$hour:$minute $period';
  }
}
