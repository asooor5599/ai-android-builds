class UserModel {
  final String id;
  String name;
  String bio;
  int avatarColor;

  UserModel({
    required this.id,
    required this.name,
    required this.bio,
    required this.avatarColor,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bio': bio,
        'avatarColor': avatarColor,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? 'user_me',
        name: json['name'] ?? 'سارة أحمد',
        bio: json['bio'] ?? 'متاح في تلغرام',
        avatarColor: json['avatarColor'] ?? 0xFF2AABEE,
      );
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  bool isRead;
  final String attachmentType;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.attachmentType = 'text',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'attachmentType': attachmentType,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] ?? '',
        chatId: json['chatId'] ?? '',
        senderId: json['senderId'] ?? '',
        senderName: json['senderName'] ?? '',
        text: json['text'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
            : DateTime.now(),
        isRead: json['isRead'] ?? false,
        attachmentType: json['attachmentType'] ?? 'text',
      );
}

class ChatModel {
  final String id;
  final String name;
  final bool isGroup;
  final bool isOnline;
  final int avatarColor;
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;

  ChatModel({
    required this.id,
    required this.name,
    this.isGroup = false,
    this.isOnline = false,
    required this.avatarColor,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isGroup': isGroup,
        'isOnline': isOnline,
        'avatarColor': avatarColor,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime.toIso8601String(),
        'unreadCount': unreadCount,
      };

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        isGroup: json['isGroup'] ?? false,
        isOnline: json['isOnline'] ?? false,
        avatarColor: json['avatarColor'] ?? 0xFF2AABEE,
        lastMessage: json['lastMessage'] ?? '',
        lastMessageTime: json['lastMessageTime'] != null
            ? DateTime.tryParse(json['lastMessageTime']) ?? DateTime.now()
            : DateTime.now(),
        unreadCount: json['unreadCount'] ?? 0,
      );
}
