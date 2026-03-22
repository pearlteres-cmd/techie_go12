import 'user_model.dart';

class MessageModel {
  final String id;
  final UserModel sender;
  final String content;
  final bool read;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.sender,
    required this.content,
    required this.read,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      sender: UserModel.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
