import 'package:flutter/material.dart';

class ComplaintModel {
  final String id; // This MUST be String, not int
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userAddress;
  final String? userLandmark;
  final String title;
  final String description;
  final String complaintType;
  final String? peripheralType;
  final String priority;
  final DateTime preferredDate;
  final String preferredTime;
  final String preferredTimeSlot;
  final String otp;
  final bool otpVerified;
  final DateTime? otpVerifiedAt;
  final String? assignedTo;
  final String? assignedTechnicianName;
  final String? assignedTechnicianPhone;
  final DateTime? assignedAt;
  final bool autoAssigned;
  final String status;
  final List<StatusHistory> statusHistory;
  final DateTime? workStartedAt;
  final DateTime? workCompletedAt;
  final String? technicianNotes;
  final double? customerRating;
  final String? customerFeedback;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? location;
  final int v; // MongoDB version field (__v)
  final double? amount;
  final String? paymentStatus;

  ComplaintModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userAddress,
    this.userLandmark,
    required this.title,
    required this.description,
    required this.complaintType,
    this.peripheralType,
    required this.priority,
    required this.preferredDate,
    required this.preferredTime,
    required this.preferredTimeSlot,
    required this.otp,
    required this.otpVerified,
    this.otpVerifiedAt,
    this.assignedTo,
    this.assignedTechnicianName,
    this.assignedTechnicianPhone,
    this.assignedAt,
    required this.autoAssigned,
    required this.status,
    required this.statusHistory,
    this.workStartedAt,
    this.workCompletedAt,
    this.technicianNotes,
    this.customerRating,
    this.customerFeedback,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    required this.v,
    this.amount,
    this.paymentStatus,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse DateTime safely
    DateTime? _parseDateTime(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        print('❌ Date parse error: $dateStr');
        return null;
      }
    }

    // Parse status history
    List<StatusHistory> statusHistory = [];
    if (json['statusHistory'] != null && json['statusHistory'] is List) {
      statusHistory = (json['statusHistory'] as List)
          .map((item) => StatusHistory.fromJson(item))
          .toList();
    }

    return ComplaintModel(
      // CRITICAL FIX: Convert _id to String
      id: json['_id']?.toString() ?? '',

      userId: json['userId']?.toString() ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userPhone: json['userPhone'] ?? '',
      userAddress: json['userAddress'] ?? '',
      userLandmark: json['userLandmark'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      complaintType: json['complaintType'] ?? 'General',
      peripheralType: json['peripheralType'],
      priority: json['priority'] ?? 'Medium',
      preferredDate: _parseDateTime(json['preferredDate']) ?? DateTime.now(),
      preferredTime: json['preferredTime'] ?? '',
      preferredTimeSlot: json['preferredTimeSlot'] ?? '',
      otp: json['otp']?.toString() ?? '',
      otpVerified: json['otpVerified'] ?? false,
      otpVerifiedAt: _parseDateTime(json['otpVerifiedAt']),
      assignedTo: json['assignedTo']?.toString(),
      assignedTechnicianName: json['assignedTechnicianName'],
      assignedTechnicianPhone: json['assignedTechnicianPhone'],
      assignedAt: _parseDateTime(json['assignedAt']),
      autoAssigned: json['autoAssigned'] ?? false,
      status: json['status'] ?? 'pending',
      statusHistory: statusHistory,
      workStartedAt: _parseDateTime(json['workStartedAt']),
      workCompletedAt: _parseDateTime(json['workCompletedAt']),
      technicianNotes: json['technicianNotes'],
      customerRating: json['customerRating']?.toDouble(),
      customerFeedback: json['customerFeedback'],
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      location: json['location'],
      v: json['__v'] ?? 0,
      amount: json['amount'] != null ? (json['amount'] is int ? (json['amount'] as int).toDouble() : json['amount'] as double) : null,
      paymentStatus: json['paymentStatus']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'userLandmark': userLandmark,
      'title': title,
      'description': description,
      'complaintType': complaintType,
      'peripheralType': peripheralType,
      'priority': priority,
      'preferredDate': preferredDate.toIso8601String(),
      'preferredTime': preferredTime,
      'preferredTimeSlot': preferredTimeSlot,
      'otp': otp,
      'otpVerified': otpVerified,
      'otpVerifiedAt': otpVerifiedAt?.toIso8601String(),
      'assignedTo': assignedTo,
      'assignedTechnicianName': assignedTechnicianName,
      'assignedTechnicianPhone': assignedTechnicianPhone,
      'assignedAt': assignedAt?.toIso8601String(),
      'autoAssigned': autoAssigned,
      'status': status,
      'statusHistory': statusHistory.map((h) => h.toJson()).toList(),
      'workStartedAt': workStartedAt?.toIso8601String(),
      'workCompletedAt': workCompletedAt?.toIso8601String(),
      'technicianNotes': technicianNotes,
      'customerRating': customerRating,
      'customerFeedback': customerFeedback,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location,
      '__v': v,
      'amount': amount,
      'paymentStatus': paymentStatus,
    };
  }

  // Helper getters
  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'en_route':
        return 'En Route';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'en_route':
        return Colors.purple;
      case 'in_progress':
        return Colors.amber;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Urgent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData get priorityIcon {
    switch (priority) {
      case 'Low':
        return Icons.arrow_downward;
      case 'Medium':
        return Icons.remove;
      case 'High':
        return Icons.arrow_upward;
      case 'Urgent':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String get formattedDate {
    return '${preferredDate.day}/${preferredDate.month}/${preferredDate.year}';
  }

  bool get isCancellable {
    return status == 'pending' || status == 'assigned';
  }
}

class StatusHistory {
  final String status;
  final DateTime timestamp;
  final String? note;
  final String? updatedBy;
  final String? id;

  StatusHistory({
    required this.status,
    required this.timestamp,
    this.note,
    this.updatedBy,
    this.id,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      note: json['note'],
      updatedBy: json['updatedBy']?.toString(),
      id: json['_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'updatedBy': updatedBy,
      '_id': id,
    };
  }
}
