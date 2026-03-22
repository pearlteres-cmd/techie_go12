// lib/models/task_model.dart
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String technicianId;
  final String status;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double amount;
  final String paymentStatus;
  final String? otp;
  final DateTime? otpExpiry;
  final String? userName;
  final String? technicianName;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.technicianId,
    required this.status,
    required this.createdAt,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    required this.amount,
    required this.paymentStatus,
    this.otp,
    this.otpExpiry,
    this.userName,
    this.technicianName,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId']?.toString() ?? '',
      technicianId: json['technicianId']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'])
          : null,
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      amount: (json['amount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'pending',
      otp: json['otp'],
      otpExpiry:
          json['otpExpiry'] != null ? DateTime.parse(json['otpExpiry']) : null,
      userName: json['userName'],
      technicianName: json['technicianName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'userId': userId,
      'technicianId': technicianId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'assignedAt': assignedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'amount': amount,
      'paymentStatus': paymentStatus,
      'otp': otp,
      'otpExpiry': otpExpiry?.toIso8601String(),
      'userName': userName,
      'technicianName': technicianName,
    };
  }
}
