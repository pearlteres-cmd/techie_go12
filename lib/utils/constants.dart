// lib/utils/constants.dart
import 'package:flutter/material.dart'; // ADD THIS IMPORT

class AppConstants {
  static const String appName = 'Techie Go';
  static const String appTagline = 'Digital Complaint Management';
  static const String apiBaseUrl = 'https://api.techiego.example.com';

  // App Routes
  static const String landingRoute = '/';
  static const String customerLoginRoute = '/customer/login';
  static const String customerRegisterRoute = '/customer/register';
  static const String staffLoginRoute = '/staff/login';
  static const String customerDashboardRoute = '/customer/dashboard';
  static const String staffDashboardRoute = '/staff/dashboard';
  static const String complaintFormRoute = '/complaint/form';
  static const String trackComplaintRoute = '/complaint/track';
  static const String complaintDetailRoute = '/complaint/detail';

  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';
}

class ComplaintStatus {
  static const String pending = 'Pending';
  static const String inProgress = 'In Progress';
  static const String resolved = 'Resolved';
  static const String closed = 'Closed';

  static Color getStatusColor(String status) {
    switch (status) {
      case pending:
        return const Color(0xFFFFD166);
      case inProgress:
        return const Color(0xFF4CC9F0);
      case resolved:
        return const Color(0xFF06D6A0);
      case closed:
        return const Color(0xFF7209B7);
      default:
        return Colors.grey;
    }
  }
}

class ServiceTypes {
  static const List<String> all = [
    'Laptop Repair',
    'Desktop Repair',
    'Software Installation',
    'Virus Removal',
    'Data Recovery',
    'Hardware Upgrade',
    'Network Setup',
    'Printer Setup',
    'Other'
  ];
}
