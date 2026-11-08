import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:app/models/chat_models.dart';

class ChatService extends ChangeNotifier {
  static const String _firebaseDbUrl =
      'https://chat-76331-default-rtdb.firebaseio.com';

  late SharedPreferences _prefs;
  late UserModel currentUser;
  List<ChatModel> chats = [];
  Map<String, List<MessageModel>> messagesMap = {};
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool isSyncing = false;
  Timer? _pollingTimer;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadProfile();
    _loadLocalData();
    _startPeriodicSync();
  }

  void _loadProfile() {
    final userJson = _prefs.getString('telegram_user');
    if (userJson != null) {
      try {
        currentUser = UserModel.fromJson(jsonDecode(userJson));
      } catch (_) {
        _createDefaultUser();
      }
    } else {
      _createDefaultUser();
    }
    soundEnabled = _prefs.getBool('sound_enabled') ?? true;
    vibrationEnabled = _prefs.getBool('vibration_enabled') ?? true;
  }

  void _createDefaultUser() {
    currentUser = UserModel(
      id: 'user_me',
      name: 'سارة أحمد',
      bio: 'مطور تطبيقات Flutter | متاح للعمل',
      avatarColor: 0xFF2AABEE,
    );
    _saveProfile();
  }

  Future<void> _saveProfile() async {
    await _prefs.setString('telegram_user', jsonEncode(currentUser.toJson()));
    notifyListeners();
  }

  void updateProfile(String name, String bio, int color) {
    currentUser.name = name;
    currentUser.bio = bio;
    currentUser.avatarColor = color;
    _saveProfile();
  }

  void toggleSound(bool val) {
    soundEnabled = val;
    _prefs.setBool('sound_enabled', val);
    notifyListeners();
  }

  void toggleVibration(bool val) {
    vibrationEnabled = val;
    _prefs.setBool('vibration_enabled', val);
    notifyListeners();
  }

  void _loadLocalData() {
    final chatsJson = _prefs.getString('telegram_chats');
    if (chatsJson != null) {
      try {
        final List list = jsonDecode(chatsJson);
        chats = list.map((e) => ChatModel.fromJson(e)).toList();
      } catch (_) {
        _loadDefaultChats();
      }
    } else {
      _loadDefaultChats();
    }

    for (var chat in chats) {
      final key = 'messages_${chat.id}';
      final msgsJson = _prefs.getString(key);
      if (msgsJson != null) {
        try {
          final List list = jsonDecode(msgsJson);
          messagesMap[chat.id] = list.map((e) => MessageModel.fromJson(e)).toList();
        } catch (_) {
          messagesMap[chat.id] = _generateInitialMessages(chat.id);
          _saveMessages(chat.id);
        }
      } else {
        messagesMap[chat.id] = _generateInitialMessages(chat.id);
        _saveMessages(chat.id);
      }
    }
  }

  void _loadDefaultChats() {
    chats = [
      ChatModel(
        id: 'chat_saved',
        name: 'الرسائل المحفوظة',
        avatarColor: 0xFF2AABEE,
        lastMessage: 'ملاحظاتك ومستنداتك الشخصية',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 0,
      ),
      ChatModel(
        id: 'chat_1',
        name: 'أحمد محمود (مطور Flutter)',
        isOnline: true,
        avatarColor: 0xFF4CAF50,
        lastMessage: 'أهلاً سارة، كيف تسير برمجة واجهة تلغرام؟',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 12)),
        unreadCount: 2,
      ),
      ChatModel(
        id: 'chat_2',
        name: 'مجتمع التقنية العربي',
        isGroup: true,
        avatarColor: 0xFF9C27B0,
        lastMessage: 'علي: تم تحديث المكتبات للسلسلة الجديدة!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 5,
      ),
      ChatModel(
        id: 'chat_3',
        name: 'م. مريم الخالد',
        isOnline: false,
        avatarColor: 0xFFFF9800,
        lastMessage: 'شكراً جزيلاً لك على الدعم الفني.',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
    ];
    _saveChats();
  }

  List<MessageModel> _generateInitialMessages(String chatId) {
    final now = DateTime.now();
    if (chatId == 'chat_saved') {
      return [
        MessageModel(
          id: 'm1',
          chatId: chatId,
          senderId: currentUser.id,
          senderName: currentUser.name,
          text: 'روابط هامة لمشروع Flutter وتصميم تلغرام',
          timestamp: now.subtract(const Duration(minutes: 30)),
          isRead: true,
        )
      ];
    } else if (chatId == 'chat_1') {
      return [
        MessageModel(
          id: 'm1',
          chatId: chatId,
          senderId: 'user_1',
          senderName: 'أحمد محمود',
          text: 'مرحباً! هل انتهيت من إعداد التصميم الداكن؟',
          timestamp: now.subtract(const Duration(minutes: 25)),
          isRead: true,
        ),
        MessageModel(
          id: 'm2',
          chatId: chatId,
          senderId: currentUser.id,
          senderName: currentUser.name,
          text: 'نعم، تم ضبط الألوان #0E1621 و #242F3D بالكامل!',
          timestamp: now.subtract(const Duration(minutes: 18)),
          isRead: true,
        ),
        MessageModel(
          id: 'm3',
          chatId: chatId,
          senderId: 'user_1',
          senderName: 'أحمد محمود',
          text: 'أهلاً سارة، كيف تسير برمجة واجهة تلغرام؟',
          timestamp: now.subtract(const Duration(minutes: 12)),
          isRead: false,
        ),
      ];
    }
    return [
      MessageModel(
        id: 'm1',
        chatId: chatId,
        senderId: 'user_other',
        senderName: 'مشارك',
        text: 'مرحباً بك في المحادثة',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: true,
      )
    ];
  }

  Future<void> _saveChats() async {
    final data = chats.map((c) => c.toJson()).toList();
    await _prefs.setString('telegram_chats', jsonEncode(data));
  }

  Future<void> _saveMessages(String chatId) async {
    final msgs = messagesMap[chatId] ?? [];
    final data = msgs.map((m) => m.toJson()).toList();
    await _prefs.setString('messages_$chatId', jsonEncode(data));
  }

  List<MessageModel> getMessages(String chatId) {
    return messagesMap[chatId] ?? [];
  }

  void markAsRead(String chatId) {
    final chatIndex = chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      chats[chatIndex].unreadCount = 0;
      _saveChats();
      notifyListeners();
    }
    final msgs = messagesMap[chatId];
    if (msgs != null) {
      for (var m in msgs) {
        m.isRead = true;
      }
      _saveMessages(chatId);
    }
  }

  Future<void> sendMessage(
      String chatId, String text, {String attachmentType = 'text'}) async {
    final msg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: chatId,
      senderId: currentUser.id,
      senderName: currentUser.name,
      text: text,
      timestamp: DateTime.now(),
      isRead: true,
      attachmentType: attachmentType,
    );

    if (messagesMap[chatId] == null) {
      messagesMap[chatId] = [];
    }
    messagesMap[chatId]!.add(msg);
    _saveMessages(chatId);

    final chatIndex = chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      chats[chatIndex].lastMessage = text;
      chats[chatIndex].lastMessageTime = msg.timestamp;
      final updatedChat = chats.removeAt(chatIndex);
      chats.insert(0, updatedChat);
      _saveChats();
    }

    notifyListeners();
    _postToFirebase(msg);

    if (chatId != 'chat_saved') {
      _simulateReply(chatId, text);
    }
  }

  void _simulateReply(String chatId, String userText) {
    Timer(const Duration(seconds: 2), () {
      String replyText = 'تم استلام رسالتك بنجاح! 👍';
      if (userText.contains('سلام') || userText.contains('مرحبا')) {
        replyText = 'وعليكم السلام ورحمة الله وبركاته! أهلاً بك.';
      } else if (userText.contains('اختبار') || userText.contains('تجربة')) {
        replyText = 'التطبيق يعمل بشكل سلس جداً وسريع! 🚀';
      }

      final replyMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: 'remote_user',
        senderName: 'رد تلقائي',
        text: replyText,
        timestamp: DateTime.now(),
        isRead: false,
      );

      messagesMap[chatId]?.add(replyMsg);
      _saveMessages(chatId);

      final chatIndex = chats.indexWhere((c) => c.id == chatId);
      if (chatIndex != -1) {
        chats[chatIndex].lastMessage = replyText;
        chats[chatIndex].lastMessageTime = replyMsg.timestamp;
        chats[chatIndex].unreadCount += 1;
        final updatedChat = chats.removeAt(chatIndex);
        chats.insert(0, updatedChat);
        _saveChats();
      }
      notifyListeners();
    });
  }

  void createNewChat(String name, {bool isGroup = false}) {
    final colorsList = [0xFF2AABEE, 0xFFE91E63, 0xFF9C27B0, 0xFF4CAF50, 0xFFFF9800];
    final newChat = ChatModel(
      id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      isGroup: isGroup,
      avatarColor: colorsList[chats.length % colorsList.length],
      lastMessage: isGroup ? 'تم إنشاء المجموعة' : 'محادثة جديدة',
      lastMessageTime: DateTime.now(),
    );
    chats.insert(0, newChat);
    messagesMap[newChat.id] = [];
    _saveChats();
    _saveMessages(newChat.id);
    notifyListeners();
  }

  Future<void> _postToFirebase(MessageModel msg) async {
    try {
      final url = Uri.parse('$_firebaseDbUrl/messages/${msg.chatId}.json');
      await http.post(url, body: jsonEncode(msg.toJson()));
    } catch (e) {
      debugPrint('Firebase Sync Note: $e');
    }
  }

  void _startPeriodicSync() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      try {
        isSyncing = true;
        notifyListeners();
        final url = Uri.parse('$_firebaseDbUrl/messages.json');
        await http.get(url);
      } catch (_) {
      } finally {
        isSyncing = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
