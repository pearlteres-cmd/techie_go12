import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/models/complaint_model.dart';
import 'package:techie_go/services/api_service.dart';
import 'package:techie_go/services/payment_service.dart'; // ✅ added
import 'package:techie_go/screens/admin/view_complaints.dart';

class MyComplaints extends StatefulWidget {
  final UserModel user;

  const MyComplaints({Key? key, required this.user}) : super(key: key);

  @override
  _MyComplaintsState createState() => _MyComplaintsState();
}

class _MyComplaintsState extends State<MyComplaints> {
  bool _isLoading = true;
  List<ComplaintModel> _complaints = [];
  String _selectedFilter = 'all';
  String? _errorMessage;
  bool _showOtp = false;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await ApiService.getToken();

      if (token != null) {
        final response = await ApiService.getUserComplaints(token);

        if (response['success'] == true) {
          final List<dynamic> data = response['data'] ?? [];
          setState(() {
            _complaints =
                data.map((json) => ComplaintModel.fromJson(json)).toList();
          });
          print('✅ Loaded ${_complaints.length} complaints from API');
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Failed to load complaints';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Not authenticated';
        });
      }
    } catch (e) {
      print('❌ Error loading complaints: $e');
      setState(() {
        _errorMessage = 'Error loading complaints. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<ComplaintModel> get _filteredComplaints {
    if (_selectedFilter == 'all') return _complaints;
    return _complaints.where((c) => c.status == _selectedFilter).toList();
  }

  void _toggleOtpVisibility() {
    setState(() {
      _showOtp = !_showOtp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(_showOtp ? Icons.visibility_off : Icons.visibility),
            onPressed: _toggleOtpVisibility,
            tooltip: _showOtp ? 'Hide OTP' : 'Show OTP',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplaints,
          ),
        ],
        bottom: _complaints.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all', Colors.grey),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pending', 'pending', Colors.orange),
                        const SizedBox(width: 8),
                        _buildFilterChip('Assigned', 'assigned', Colors.blue),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            'In Progress', 'in_progress', Colors.purple),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            'Completed', 'completed', Colors.green),
                        const SizedBox(width: 8),
                        _buildFilterChip('Cancelled', 'cancelled', Colors.red),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade600],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorState()
                  : _filteredComplaints.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadComplaints,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredComplaints.length,
                            itemBuilder: (ctx, index) {
                              final complaint = _filteredComplaints[index];
                              return UserComplaintCard(
                                complaint: complaint,
                                onRefresh: _loadComplaints,
                                user: widget.user,
                                showOtp: _showOtp,
                              );
                            },
                          ),
                        ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Unable to load complaints',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadComplaints,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            'No complaints found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You haven\'t registered any complaints yet.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Register New Complaint'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class UserComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  final VoidCallback onRefresh;
  final UserModel user;
  final bool showOtp;

  const UserComplaintCard({
    Key? key,
    required this.complaint,
    required this.onRefresh,
    required this.user,
    required this.showOtp,
  }) : super(key: key);

  Future<void> _payForComplaint(BuildContext context) async {
    await PaymentService.payForComplaint(
      context: context,
      complaintId: complaint.id,
      amount: complaint.amount ?? 0.0,
      buyerEmail: user.email,
      buyerPhone: user.phone,
      complaintTitle: complaint.title,
    );
    onRefresh(); // refresh list after payment
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowOtp = showOtp &&
        (complaint.status == 'pending' ||
            complaint.status == 'assigned' ||
            complaint.status == 'en_route' ||
            complaint.status == 'in_progress');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewComplaints(
                user: user,
                initialComplaint: complaint,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Priority and Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(complaint.priority)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPriorityIcon(complaint.priority),
                      color: _getPriorityColor(complaint.priority),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'ID: ${complaint.id.substring(0, 8)}...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // User and Date Row
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    complaint.userName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    complaint.formattedDate,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Status and Technician Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(complaint.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(complaint.status),
                          size: 12,
                          color: _getStatusColor(complaint.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          complaint.statusText,
                          style: TextStyle(
                            color: _getStatusColor(complaint.status),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (complaint.assignedTechnicianName != null)
                    Text(
                      'Tech: ${complaint.assignedTechnicianName}',
                      style: const TextStyle(fontSize: 10),
                    ),
                ],
              ),

              // OTP Section
              if (shouldShowOtp) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.password,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your OTP',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  complaint.otp,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: complaint.otpVerified
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    complaint.otpVerified
                                        ? 'Verified'
                                        : 'Not Verified',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: complaint.otpVerified
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('OTP copied: ${complaint.otp}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],

              // PAY BUTTON for completed unpaid complaints
              if (complaint.status == 'completed' &&
                  complaint.paymentStatus == 'pending') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _payForComplaint(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Pay ₹${complaint.amount?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
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

  IconData _getPriorityIcon(String priority) {
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
