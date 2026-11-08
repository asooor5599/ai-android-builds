import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/services/chat_service.dart';
import 'package:app/screens/settings_screen.dart';
import 'package:app/screens/chat_room_screen.dart';

class TelegramDrawer extends StatelessWidget {
  const TelegramDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final user = chatService.currentUser;

    return Drawer(
      child: Container(
        color: const Color(0xFF17212B),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF242F3D),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Color(user.avatarColor),
                child: Text(
                  user.name.isNotEmpty ? user.name[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              accountName: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              accountEmail: Text(
                user.bio,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF7F91A4), fontSize: 13),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF7F91A4)),
              title: const Text('مجموعة جديدة', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                chatService.createNewChat('مجموعة جديدة', isGroup: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark, color: Color(0xFF7F91A4)),
              title: const Text('الرسائل المحفوظة', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                final savedChat = chatService.chats.firstWhere(
                  (c) => c.id == 'chat_saved',
                  orElse: () => chatService.chats.first,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatRoomScreen(chat: savedChat)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF7F91A4)),
              title: const Text('جهات الاتصال', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF7F91A4)),
              title: const Text('الإعدادات', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const Divider(color: Color(0xFF242F3D)),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF7F91A4)),
              title: const Text('حول التطبيق', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'تلغرام داكن',
                  applicationVersion: '1.0.0',
                  children: [
                    const Text('تطبيق محادثات فورية بتصميم مستوحى من تلغرام بالوضع الداكن (Telegram Dark Theme).'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
