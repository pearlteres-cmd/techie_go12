class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // complaint, payment, task, system, etc.
  final String? relatedId; // Links to complaint, payment, or task ID
  final String? relatedType; // Type of related entity
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data; // Additional metadata

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    this.relatedType,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  // Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      relatedId: json['relatedId'],
      relatedType: json['relatedType'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  // Create a copy with modifications
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? relatedId,
    String? relatedType,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, title: $title, '
        'type: $type, isRead: $isRead, timestamp: $timestamp)';
  }
}