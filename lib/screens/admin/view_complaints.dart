import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/models/complaint_model.dart';
import 'package:techie_go/services/api_service.dart';
import 'package:techie_go/screens/user/edit_complaint.dart';
import 'package:techie_go/screens/user/payment_screen.dart';

class ViewComplaints extends StatefulWidget {
  final UserModel user;
  final ComplaintModel? initialComplaint;

  const ViewComplaints({
    Key? key,
    required this.user,
    this.initialComplaint,
  }) : super(key: key);

  @override
  State<ViewComplaints> createState() => _ViewComplaintsState();
}

class _ViewComplaintsState extends State<ViewComplaints> {
  late ComplaintModel _complaint;
  bool _showOtp = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialComplaint != null) {
      _complaint = widget.initialComplaint!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialComplaint == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('View Complaints'),
          backgroundColor: Colors.blue.shade800,
        ),
        body: const Center(
          child: Text('No complaint selected'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          // Toggle OTP visibility button (only for user)
          if (widget.user.userType == 'user')
            IconButton(
              icon: Icon(_showOtp ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _showOtp = !_showOtp;
                });
              },
              tooltip: _showOtp ? 'Hide OTP' : 'Show OTP',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(_complaint.status).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(_complaint.status),
                        color: _getStatusColor(_complaint.status),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Status',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _complaint.statusText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(_complaint.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Priority Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _complaint.priorityColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _complaint.priorityIcon,
                        color: _complaint.priorityColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Priority',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _complaint.priority,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _complaint.priorityColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // OTP Card - Only visible to user when showOtp is true
            if (widget.user.userType == 'user' && _showOtp) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.password,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Your OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _complaint.otp,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _complaint.otpVerified
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _complaint.otpVerified
                                  ? 'Verified'
                                  : 'Not Verified',
                              style: TextStyle(
                                color: _complaint.otpVerified
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share this OTP with the technician when they arrive to verify the complaint.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Complaint Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complaint Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('ID', _complaint.id),
                    _buildInfoRow('Title', _complaint.title),
                    _buildInfoRow('Type', _complaint.complaintType),
                    if (_complaint.peripheralType != null)
                      _buildInfoRow('Peripheral', _complaint.peripheralType!),
                    _buildInfoRow('Description', _complaint.description),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Name', _complaint.userName),
                    _buildInfoRow('Email', _complaint.userEmail),
                    _buildInfoRow('Phone', _complaint.userPhone),
                    _buildInfoRow('Address', _complaint.userAddress),
                    if (_complaint.userLandmark != null)
                      _buildInfoRow('Landmark', _complaint.userLandmark!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Schedule Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferred Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Date', _complaint.formattedDate),
                    _buildInfoRow('Time', _complaint.preferredTime),
                    _buildInfoRow('Time Slot', _complaint.preferredTimeSlot),
                  ],
                ),
              ),
            ),

            // Technician Info Card (if assigned)
            if (_complaint.assignedTechnicianName != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Technician Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Name', _complaint.assignedTechnicianName!),
                      if (_complaint.assignedTechnicianPhone != null)
                        _buildInfoRow(
                            'Phone', _complaint.assignedTechnicianPhone!),
                      if (_complaint.technicianNotes != null)
                        _buildInfoRow('Notes', _complaint.technicianNotes!),
                      if (_complaint.assignedAt != null)
                        _buildInfoRow('Assigned',
                            _formatDateTime(_complaint.assignedAt!)),
                    ],
                  ),
                ),
              ),
            ],

            // Feedback Section (if completed and feedback exists)
            if (_complaint.status == 'completed' &&
                _complaint.customerFeedback != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      if (_complaint.customerRating != null)
                        Row(
                          children: [
                            const Text('Rating: '),
                            ...List.generate(5, (index) {
                              return Icon(
                                index < _complaint.customerRating!.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${_complaint.customerRating!.toStringAsFixed(1)}/5',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      if (_complaint.customerFeedback != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _complaint.customerFeedback!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Action Buttons
            // Edit button available to all users (user, admin, technician) if complaint is active
            if (_complaint.status == 'pending' || 
                _complaint.status == 'assigned' || 
                _complaint.status == 'en_route' || 
                _complaint.status == 'in_progress') ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditComplaintScreen(
                          user: widget.user,
                          complaint: _complaint,
                        ),
                      ),
                    );
                    if (result == true) {
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(200, 45),
                  ),
                  child: const Text('Edit Complaint'),
                ),
              ),
            ],

            // User specific action buttons (Cancel, Pay)
            if (widget.user.userType == 'user') ...[
              if (_complaint.isCancellable) ...[
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _showCancelDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(200, 45),
                    ),
                    child: const Text('Cancel Complaint'),
                  ),
                ),
              ],
              if (_complaint.status == 'completed' && _complaint.paymentStatus != 'paid') ...[
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            user: widget.user,
                            task: {
                              '_id': _complaint.id,
                              'title': _complaint.title,
                            },
                            amount: _complaint.amount ?? 500.0,
                            technicianId: _complaint.assignedTo ?? '',
                            technicianName: _complaint.assignedTechnicianName ?? 'Technician',
                          ),
                        ),
                      );
                      // Pop with true to let previous screens refresh their data after potential payment.
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(200, 45),
                    ),
                    child: const Text('Pay Now'),
                  ),
                ),
              ],
            ] else if (_complaint.isCancellable) ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => _showCancelDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(200, 45),
                  ),
                  child: const Text('Cancel Complaint'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Complaint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to cancel this complaint?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for cancellation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelComplaint(reasonController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelComplaint(String reason) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.cancelComplaint(
          token: token,
          complaintId: _complaint.id,
          reason: reason,
        );

        Navigator.pop(context);

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  response['message'] ?? 'Complaint cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response['message'] ?? 'Failed to cancel complaint'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'assigned':
        return Icons.person;
      case 'en_route':
        return Icons.directions_car;
      case 'in_progress':
        return Icons.build;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
