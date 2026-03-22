import 'package:flutter/material.dart';

class PaymentModel {
  final String id;
  final String complaintId;          // changed from taskId
  final String? complaintTitle;       // renamed from taskTitle
  final String userId;
  final String userName;
  final String? technicianId;
  final String? technicianName;
  final double amount;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? paidAt;

  PaymentModel({
    required this.id,
    required this.complaintId,
    this.complaintTitle,
    required this.userId,
    required this.userName,
    this.technicianId,
    this.technicianName,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    required this.createdAt,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] ?? json['id'] ?? '',
      complaintId: json['complaintId'] ?? '',          // backend uses complaintId
      complaintTitle: json['complaintTitle'] ?? json['title'] ?? 'Service Payment',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Customer',
      technicianId: json['technicianId'],
      technicianName: json['technicianName'],
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'cash',
      status: json['status'] ?? 'pending',
      transactionId: json['transactionId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'complaintId': complaintId,
      'complaintTitle': complaintTitle,
      'userId': userId,
      'userName': userName,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  // Helper getters
  Color get statusColor {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.refresh;
      default:
        return Icons.help;
    }
  }

  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';
  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get formattedTime => '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

  PaymentModel copyWith({
    String? id,
    String? complaintId,
    String? complaintTitle,
    String? userId,
    String? userName,
    String? technicianId,
    String? technicianName,
    double? amount,
    String? paymentMethod,
    String? status,
    String? transactionId,
    DateTime? createdAt,
    DateTime? paidAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      complaintId: complaintId ?? this.complaintId,
      complaintTitle: complaintTitle ?? this.complaintTitle,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}