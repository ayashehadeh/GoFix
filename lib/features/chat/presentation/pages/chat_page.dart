import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/chat_bloc.dart';
import '../../domain/entities/chat_entity.dart';

class ChatPage extends StatefulWidget {
  final String professionalName;
  final String chatId;
  const ChatPage({
    super.key,
    required this.professionalName,
    required this.chatId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadMessages(widget.chatId));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessageEvent(
          chatId: widget.chatId,
          text: text,
          type: 'text',
        ));
    _controller.clear();
    _scrollToBottom();
  }

  Future<void> _showAttachmentMenu() async {
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
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.primaryOrange),
                title: Text(AppLocalizations.of(sheetContext)!.photo),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt,
                    color: AppColors.primaryOrange),
                title: Text(AppLocalizations.of(sheetContext)!.camera),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file,
                    color: AppColors.primaryOrange),
                title: Text(AppLocalizations.of(sheetContext)!.fileLabel),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickFile();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        context.read<ChatBloc>().add(SendMessageEvent(
              chatId: widget.chatId,
              text: 'Photo',
              type: 'image',
              attachmentPath: image.path,
            ));
        _scrollToBottom();
      }
    } catch (e) {
      _showSnack('Could not pick image');
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles();
      if (!mounted) return;
      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        context.read<ChatBloc>().add(SendMessageEvent(
              chatId: widget.chatId,
              text: file.name,
              type: 'file',
              attachmentPath: file.path!,
            ));
        _scrollToBottom();
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not pick file');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE0E8F0),
              child: Icon(Icons.person, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              widget.professionalName,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is MessagesLoaded) {
            _scrollToBottom();
          }
          if (state is ChatError) {
            _showSnack(state.message);
          }
        },
        builder: (context, state) {
          List<ChatMessageEntity> messages = [];
          if (state is MessagesLoaded) {
            messages = state.messages;
          }
          if (state is ChatLoading && messages.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _MessageBubble(message: messages[index]),
                ),
              ),
              _buildInputBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showAttachmentMenu,
            child:
                const Icon(Icons.add, color: AppColors.primaryDark, size: 26),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.typeMessage,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _sendText(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendText,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  const _MessageBubble({required this.message});

  /// Returns true when the path looks like a remote URL rather than a local file.
  bool get _isRemoteUrl =>
      message.attachmentPath != null &&
      (message.attachmentPath!.startsWith('http://') ||
          message.attachmentPath!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!message.isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                message.time,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: message.type == 'image'
                ? const EdgeInsets.all(4)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: message.isMe
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: message.isMe
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
            ),
            child: _buildContent(),
          ),
          if (message.isMe)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                message.time,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (message.type) {
      case 'image':
        if (message.attachmentPath != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isRemoteUrl
                ? Image.network(
                    message.attachmentPath!,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                        color: AppColors.primaryDark),
                  )
                : Image.file(
                    File(message.attachmentPath!),
                    width: 200,
                    fit: BoxFit.cover,
                  ),
          );
        }
        return _textWidget();
      case 'file':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, color: AppColors.primaryOrange),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.text,
                style:
                    const TextStyle(fontSize: 14, color: AppColors.primaryDark),
              ),
            ),
          ],
        );
      default:
        return _textWidget();
    }
  }

  Widget _textWidget() {
    return Text(
      message.text,
      style: const TextStyle(fontSize: 14, color: AppColors.primaryDark),
    );
  }
}
