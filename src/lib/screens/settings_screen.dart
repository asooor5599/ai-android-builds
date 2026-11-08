import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/services/chat_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final chatService = Provider.of<ChatService>(context, listen: false);
    _nameController = TextEditingController(text: chatService.currentUser.name);
    _bioController = TextEditingController(text: chatService.currentUser.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1621),
      appBar: AppBar(
        backgroundColor: const Color(0xFF242F3D),
        title: const Text('الإعدادات والملف الشخصي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF2AABEE)),
            onPressed: () {
              chatService.updateProfile(
                _nameController.text.trim(),
                _bioController.text.trim(),
                chatService.currentUser.avatarColor,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(chatService.currentUser.avatarColor),
                  child: Text(
                    chatService.currentUser.name.isNotEmpty
                        ? chatService.currentUser.name[0]
                        : '?',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF2AABEE),
                    child: IconButton(
                      iconSize: 16,
                      icon: const Icon(Icons.color_lens, color: Colors.white),
                      onPressed: () => _showColorPicker(context, chatService),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'المعلومات الشخصية',
            style: TextStyle(color: Color(0xFF2AABEE), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF17212B),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'الاسم',
                    labelStyle: TextStyle(color: Color(0xFF7F91A4)),
                    border: InputBorder.none,
                  ),
                ),
                const Divider(color: Color(0xFF242F3D)),
                TextField(
                  controller: _bioController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'السيرة الذاتية (Bio)',
                    labelStyle: TextStyle(color: Color(0xFF7F91A4)),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'الإشعارات والأصوات',
            style: TextStyle(color: Color(0xFF2AABEE), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF17212B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: chatService.soundEnabled,
                  activeColor: const Color(0xFF2AABEE),
                  title: const Text('أصوات المحادثات', style: TextStyle(color: Colors.white)),
                  onChanged: (val) => chatService.toggleSound(val),
                ),
                const Divider(color: Color(0xFF242F3D), height: 1),
                SwitchListTile(
                  value: chatService.vibrationEnabled,
                  activeColor: const Color(0xFF2AABEE),
                  title: const Text('اهتزاز اللمس (Haptic)', style: TextStyle(color: Colors.white)),
                  onChanged: (val) => chatService.toggleVibration(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF17212B),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.cloud_done, color: Color(0xFF4CAF50)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'حالة السحابة: Firebase REST متصل (chat-76331)',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                if (chatService.isSyncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2AABEE)),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, ChatService chatService) {
    final colors = [
      0xFF2AABEE,
      0xFF4CAF50,
      0xFFE91E63,
      0xFF9C27B0,
      0xFFFF9800,
      0xFF673AB7,
    ];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر لون النمط الشخصي', style: TextStyle(color: Colors.white)),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((c) {
            return InkWell(
              onTap: () {
                chatService.updateProfile(
                  _nameController.text.trim(),
                  _bioController.text.trim(),
                  c,
                );
                Navigator.pop(ctx);
              },
              child: CircleAvatar(
                backgroundColor: Color(c),
                radius: 22,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
