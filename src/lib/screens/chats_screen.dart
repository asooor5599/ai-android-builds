import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:app/services/chat_service.dart';
import 'package:app/models/chat_models.dart';
import 'package:app/screens/chat_room_screen.dart';
import 'package:app/widgets/telegram_drawer.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final filteredChats = chatService.chats.where((chat) {
      return chat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          chat.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0E1621),
      drawer: const TelegramDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242F3D),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'بحث في المحادثات...', 
                  hintStyle: TextStyle(color: Color(0xFF7F91A4)),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              )
            : const Text('تليغرام'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: filteredChats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 70,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد محادثات تطابق بحثك',
                    style: TextStyle(color: Color(0xFF7F91A4), fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: filteredChats.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Color(0xFF17212B),
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                return _buildChatTile(context, chat, chatService);
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2AABEE),
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: () => _showNewChatDialog(context, chatService),
      ),
    );
  }

  Widget _buildChatTile(
      BuildContext context, ChatModel chat, ChatService chatService) {
    final String formattedTime =
        intl.DateFormat('HH:mm').format(chat.lastMessageTime);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      backgroundColor: const Color(0xFF0E1621),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Color(chat.avatarColor),
            child: chat.id == 'chat_saved'
                ? const Icon(Icons.bookmark, color: Colors.white, size: 26)
                : Text(
                    chat.name.isNotEmpty ? chat.name[0] : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
          ),
          if (chat.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0E1621), width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              chat.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            formattedTime,
            style: const TextStyle(
              color: Color(0xFF7F91A4),
              fontSize: 12,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat.unreadCount > 0
                      ? Colors.white
                      : const Color(0xFF7F91A4),
                  fontSize: 14,
                ),
              ),
            ),
            if (chat.unreadCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2AABEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
      onTap: () {
        chatService.markAsRead(chat.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(chat: chat),
          ),
        );
      },
    );
  }

  void _showNewChatDialog(BuildContext context, ChatService chatService) {
    final controller = TextEditingController();
    bool isGroup = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('محادثة جديدة', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'اسم الشخص أو المجموعة...',
                  hintStyle: TextStyle(color: Color(0xFF7F91A4)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2AABEE)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isGroup,
                    activeColor: const Color(0xFF2AABEE),
                    onChanged: (val) {
                      setDialogState(() {
                        isGroup = val ?? false;
                      });
                    },
                  ),
                  const Text('إنشاء كمجموعة', style: TextStyle(color: Colors.white)),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Color(0xFF7F91A4))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2AABEE),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  chatService.createNewChat(controller.text.trim(), isGroup: isGroup);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('إنشاء', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
