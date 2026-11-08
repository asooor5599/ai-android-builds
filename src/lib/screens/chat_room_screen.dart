import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/models/chat_models.dart';
import 'package:app/services/chat_service.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatRoomScreen({super.key, required this.chat});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(ChatService chatService, {String attachmentType = 'text', String customText = ''}) {
    final text = customText.isNotEmpty ? customText : _textController.text.trim();
    if (text.isEmpty && attachmentType == 'text') return;

    if (chatService.vibrationEnabled) {
      HapticFeedback.lightImpact();
    }

    chatService.sendMessage(widget.chat.id, text, attachmentType: attachmentType);
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final messages = chatService.getMessages(widget.chat.id);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1621),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242F3D),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: Color(widget.chat.avatarColor),
              child: widget.chat.id == 'chat_saved'
                  ? const Icon(Icons.bookmark, color: Colors.white, size: 20)
                  : Text(
                      widget.chat.name.isNotEmpty ? widget.chat.name[0] : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.chat.isGroup
                        ? 'مجموعة أفراد'
                        : (widget.chat.isOnline ? 'متصل الآن' : 'آخر ظهور مؤخراً'),
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.chat.isOnline
                          ? const Color(0xFF64B5F6)
                          : const Color(0xFF7F91A4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري بدء المكالمة الصوتية...'))
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0E1621),
              ),
              child: messages.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF182533),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'لا توجد رسائل بعد. ابدأ المحادثة الآن!',
                          style: TextStyle(color: Color(0xFF7F91A4)),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == chatService.currentUser.id;
                        return _buildMessageBubble(msg, isMe);
                      },
                    ),
            ),
          ),
          _buildInputBar(chatService),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    final timeStr = intl.DateFormat('HH:mm').format(msg.timestamp);

    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2B5278) : const Color(0xFF182533),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: isMe ? const Radius.circular(2) : const Radius.circular(14),
            bottomRight: isMe ? const Radius.circular(14) : const Radius.circular(2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.attachmentType == 'image') ...[
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 50, color: Color(0xFF64B5F6)),
                ),
              ),
              const SizedBox(height: 6),
            ] else if (msg.attachmentType == 'location') ...[
              Row(
                children: const [
                  Icon(Icons.location_on, color: Color(0xFFFF5252)),
                  SizedBox(width: 6),
                  Text(
                    'الموقع الجغرافي المشارك',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ] else if (msg.attachmentType == 'voice') ...[
              Row(
                children: [
                  const Icon(Icons.play_arrow, color: Color(0xFF64B5F6), size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      color: Colors.white30,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('0:15', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(
              msg.text,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.3),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min, 
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: Color(0xFF7F91A4),
                    fontSize: 11,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all : Icons.done,
                    size: 15,
                    color: msg.isRead ? const Color(0xFF64B5F6) : const Color(0xFF7F91A4),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ChatService chatService) {
    return Container(
      color: const Color(0xFF17212B),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Color(0xFF7F91A4)),
              onPressed: () => _showAttachmentModal(chatService),
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالة...',
                  hintStyle: TextStyle(color: Color(0xFF7F91A4)),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.mic, color: Color(0xFF7F91A4)),
              onPressed: () {
                _sendMessage(chatService, attachmentType: 'voice', customText: 'تسجيل صوتي (0:15)');
              },
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF2AABEE)),
              onPressed: () => _sendMessage(chatService),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentModal(ChatService chatService) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 180,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAttachmentOption(
              icon: Icons.image,
              color: Colors.purple,
              label: 'صورة',
              onTap: () {
                Navigator.pop(ctx);
                _sendMessage(chatService, attachmentType: 'image', customText: 'صورة مرفقة');
              },
            ),
            _buildAttachmentOption(
              icon: Icons.location_on,
              color: Colors.red,
              label: 'موقع',
              onTap: () {
                Navigator.pop(ctx);
                _sendMessage(chatService, attachmentType: 'location', customText: 'الرياض، المملكة العربية السعودية');
              },
            ),
            _buildAttachmentOption(
              icon: Icons.insert_drive_file,
              color: Colors.blue,
              label: 'ملف',
              onTap: () {
                Navigator.pop(ctx);
                _sendMessage(chatService, customText: 'مستند_مشروع.pdf');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
      {required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
