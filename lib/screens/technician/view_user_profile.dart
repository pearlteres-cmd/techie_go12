import 'package:flutter/material.dart';
import 'package:techie_go/services/api_service.dart';

class ViewUserProfile extends StatefulWidget {
  final String userId;
  final String taskId;

  const ViewUserProfile({
    Key? key,
    required this.userId,
    required this.taskId,
  }) : super(key: key);

  @override
  _ViewUserProfileState createState() => _ViewUserProfileState();
}

class _ViewUserProfileState extends State<ViewUserProfile> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _taskData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Load user data
        final userResponse = await ApiService.getUserProfile(token);
        if (userResponse['success'] == true) {
          setState(() {
            _userData = userResponse['user']?.toJson() ?? {};
          });
        }

        // Load task details
        // Add your get task by ID API call
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // User Profile Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              _userData?['name']?[0].toUpperCase() ?? 'U',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            _userData?['name'] ?? 'Unknown User',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Customer',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildInfoRow(Icons.email, 'Email',
                              _userData?['email'] ?? 'N/A'),
                          _buildInfoRow(Icons.phone, 'Phone',
                              _userData?['phone'] ?? 'N/A'),
                          _buildInfoRow(Icons.location_on, 'Address',
                              _userData?['address'] ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Task Details Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildTaskDetailRow('Task ID', widget.taskId),
                          _buildTaskDetailRow(
                              'Title', _taskData?['title'] ?? 'N/A'),
                          _buildTaskDetailRow(
                              'Category', _taskData?['category'] ?? 'N/A'),
                          _buildTaskDetailRow(
                              'Priority', _taskData?['priority'] ?? 'Medium'),
                          _buildTaskDetailRow(
                              'Status', _taskData?['status'] ?? 'Pending'),
                          _buildTaskDetailRow(
                              'Location', _taskData?['address'] ?? 'N/A'),
                          _buildTaskDetailRow('Preferred Date',
                              _formatDate(_taskData?['preferredDate'])),
                          _buildTaskDetailRow('Time Slot',
                              _taskData?['preferredTimeSlot'] ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Contact Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Call user
                          },
                          icon: Icon(Icons.call),
                          label: Text('Call'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Message user
                          },
                          icon: Icon(Icons.message),
                          label: Text('Message'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
