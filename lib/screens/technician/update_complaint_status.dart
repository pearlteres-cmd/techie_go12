import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/models/complaint_model.dart';
import 'package:techie_go/services/api_service.dart';
import 'package:techie_go/screens/user/edit_complaint.dart';
class UpdateComplaintStatus extends StatefulWidget {
  final UserModel technician;
  final ComplaintModel complaint;

  const UpdateComplaintStatus({
    Key? key,
    required this.technician,
    required this.complaint,
  }) : super(key: key);

  @override
  State<UpdateComplaintStatus> createState() => _UpdateComplaintStatusState();
}

class _UpdateComplaintStatusState extends State<UpdateComplaintStatus> {
  String? _selectedStatus;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isUpdating = false;
  bool _isVerifying = false;
  bool _otpVerified = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'en_route',
      'label': 'En Route',
      'icon': Icons.directions_car,
      'color': Colors.purple
    },
    {
      'value': 'in_progress',
      'label': 'In Progress',
      'icon': Icons.build,
      'color': Colors.amber
    },
    {
      'value': 'completed',
      'label': 'Completed',
      'icon': Icons.check_circle,
      'color': Colors.green
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.complaint.status;
    _otpVerified = widget.complaint.otpVerified;
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter OTP'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP must be 6 digits'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.verifyOTP(
          token: token,
          complaintId: widget.complaint.id,
          otp: _otpController.text.trim(),
        );

        if (response['success'] == true) {
          setState(() {
            _otpVerified = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'OTP verified successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Invalid OTP'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ OTP verification error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == widget.complaint.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status is already set to this value'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Require OTP verification before marking as completed
    if (_selectedStatus == 'completed' && !_otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify OTP first before marking as completed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.updateComplaintStatus(
          token: token,
          complaintId: widget.complaint.id,
          status: _selectedStatus!,
          notes:
              _notesController.text.isNotEmpty ? _notesController.text : null,
        );

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response['message'] ?? 'Status updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to update status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Update error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Complaint Status'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Complaint Details Card
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Complaint Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.complaint.status != 'completed' && widget.complaint.status != 'cancelled')
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditComplaintScreen(
                                    user: widget.technician,
                                    complaint: widget.complaint,
                                  ),
                                ),
                              );
                              if (result == true) {
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                              }
                            },
                          ),
                      ],
                    ),
                    const Divider(),
                    _buildDetailRow('ID', widget.complaint.id.substring(0, 8)),
                    _buildDetailRow('Title', widget.complaint.title),
                    _buildDetailRow('User', widget.complaint.userName),
                    _buildDetailRow('Address', widget.complaint.userAddress),
                    _buildDetailRow('Phone', widget.complaint.userPhone),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // OTP Verification Card
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
                            color: _otpVerified
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _otpVerified ? Icons.check_circle : Icons.password,
                            color: _otpVerified ? Colors.green : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _otpVerified
                                    ? 'OTP Verified'
                                    : 'OTP Verification Required',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _otpVerified
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              if (!_otpVerified)
                                const Text(
                                  'Please ask the customer for the OTP to start working',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_otpVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check,
                                    size: 12, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (!_otpVerified) ...[
                      const Divider(height: 24),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'Enter 6-digit OTP',
                          hintText: 'Enter OTP from customer',
                          prefixIcon: const Icon(Icons.password),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          counterText: '${_otpController.text.length}/6',
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Verify OTP'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Current Status Card
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
                      'Current Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: widget.complaint.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(widget.complaint.status),
                            size: 16,
                            color: widget.complaint.statusColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.complaint.statusText,
                            style: TextStyle(
                              color: widget.complaint.statusColor,
                              fontWeight: FontWeight.bold,
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

            // Update Status Card
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
                      'Update Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Status Options
                    ..._statusOptions.map((option) {
                      final isSelected = _selectedStatus == option['value'];
                      final isDisabled = !_canTransitionTo(option['value']);

                      // For completed status, require OTP verification
                      final disableDueToOtp =
                          option['value'] == 'completed' && !_otpVerified;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isSelected
                            ? option['color'].withOpacity(0.1)
                            : null,
                        child: ListTile(
                          leading: Icon(
                            option['icon'],
                            color: (isDisabled || disableDueToOtp)
                                ? Colors.grey
                                : option['color'],
                          ),
                          title: Text(
                            option['label'],
                            style: TextStyle(
                              color: (isDisabled || disableDueToOtp)
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          subtitle:
                              disableDueToOtp && option['value'] == 'completed'
                                  ? const Text(
                                      'Verify OTP first',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.orange),
                                    )
                                  : null,
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: option['color'])
                              : null,
                          selected: isSelected,
                          enabled: !isDisabled && !disableDueToOtp,
                          onTap: (isDisabled || disableDueToOtp)
                              ? null
                              : () {
                                  setState(() {
                                    _selectedStatus = option['value'];
                                  });
                                },
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 16),

                    // Notes Field
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Add any notes about the work',
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _updateStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isUpdating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Update Status',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
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

  bool _canTransitionTo(String newStatus) {
    // Define valid status transitions
    const validTransitions = {
      'assigned': ['en_route'],
      'en_route': ['in_progress'],
      'in_progress': ['completed'],
    };

    final currentStatus = widget.complaint.status;

    if (currentStatus == newStatus) return false;

    final allowed = validTransitions[currentStatus];
    return allowed?.contains(newStatus) ?? false;
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
