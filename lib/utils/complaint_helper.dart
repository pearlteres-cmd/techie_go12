import 'package:flutter/material.dart';
import '../models/complaint_model.dart';

class ComplaintHelper {
  static String getStatusText(ComplaintModel complaint) {
    switch (complaint.status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned to Technician';
      case 'in-progress':
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return complaint.status;
    }
  }

  static Color getStatusColor(ComplaintModel complaint) {
    switch (complaint.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in-progress':
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(ComplaintModel complaint) {
    switch (complaint.status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'assigned':
        return Icons.assignment;
      case 'in-progress':
      case 'in_progress':
        return Icons.build;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
