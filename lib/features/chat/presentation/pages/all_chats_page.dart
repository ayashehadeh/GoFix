import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/chat_bloc.dart';
import '../../domain/entities/chat_entity.dart';
import 'chat_page.dart';

class AllChatsPage extends StatefulWidget {
  const AllChatsPage({super.key});

  @override
  State<AllChatsPage> createState() => _AllChatsPageState();
}

class _AllChatsPageState extends State<AllChatsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ChatPreviewEntity> _filteredChats = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const LoadChats());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query, List<ChatPreviewEntity> allChats) {
    setState(() {
      _filteredChats = query.isEmpty
          ? allChats
          : allChats
              .where((chat) =>
                  chat.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  void _showChatOptions(BuildContext context, ChatPreviewEntity chat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete chat',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDelete(context, chat);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ChatPreviewEntity chat) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete chat?'),
          content: Text(
              'Are you sure you want to delete the chat with ${chat.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.primaryDark)),
            ),
            TextButton(
              onPressed: () {
                context.read<ChatBloc>().add(DeleteChatEvent(chat.id));
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isSearching
            ? null
            : const BackButton(color: AppColors.primaryDark),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(color: AppColors.primaryDark),
                onChanged: (query) {
                  final state = context.read<ChatBloc>().state;
                  if (state is ChatsLoaded) {
                    _onSearch(query, state.chats);
                  }
                },
              )
            : const Text(
                'All chats',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppColors.primaryDark,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  final state = context.read<ChatBloc>().state;
                  if (state is ChatsLoaded) {
                    _filteredChats = state.chats;
                  }
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatsLoaded) {
            setState(() {
              _filteredChats = state.chats;
            });
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }
          if (state is ChatError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: AppColors.textSecondary)),
            );
          }
          if (state is ChatsLoaded) {
            final chatsToShow =
                _filteredChats.isEmpty && _searchController.text.isNotEmpty
                    ? <ChatPreviewEntity>[]
                    : _filteredChats;

            if (chatsToShow.isEmpty) {
              return Center(
                child: Text(
                  _searchController.text.isNotEmpty
                      ? 'No chats found'
                      : 'No chats yet',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return ListView.separated(
              itemCount: chatsToShow.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final chat = chatsToShow[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => di.sl<ChatBloc>(),
                          child: ChatPage(
                            professionalName: chat.name,
                            chatId: chat.id,
                          ),
                        ),
                      ),
                    ).then((_) {
                      if (mounted) {
                        context.read<ChatBloc>().add(const LoadChats());
                      }
                    });
                  },
                  onLongPress: () => _showChatOptions(context, chat),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFE0E8F0),
                    child: Icon(Icons.person, color: AppColors.primaryDark),
                  ),
                  title: Text(
                    chat.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                      fontSize: 15,
                    ),
                  ),
                  trailing: Text(
                    chat.timeAgo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
