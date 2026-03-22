import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/services/api_service.dart';

class ManageCustomers extends StatefulWidget {
  final UserModel user;

  const ManageCustomers({Key? key, required this.user}) : super(key: key);

  @override
  _ManageCustomersState createState() => _ManageCustomersState();
}

class _ManageCustomersState extends State<ManageCustomers> {
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Use the new getCustomers method
        final response = await ApiService.getCustomers(token);
        if (response['success'] == true) {
          // The backend may return data inside a nested 'data' field
          final data = response['data'];
          List<dynamic> customersData = [];

          if (data is Map && data['data'] != null) {
            customersData = data['data'] as List;
          } else if (data is List) {
            customersData = data;
          }

          setState(() {
            _customers = customersData.cast<Map<String, dynamic>>();
          });
        } else {
          print('Failed to load customers: ${response['message']}');
        }
      }
    } catch (e) {
      print('Error loading customers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((c) {
      final name = c['name']?.toString().toLowerCase() ?? '';
      final email = c['email']?.toString().toLowerCase() ?? '';
      final phone = c['phone']?.toString() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query);
    }).toList();
  }

  Future<void> _viewCustomerDetails(Map<String, dynamic> customer) async {
    List<Map<String, dynamic>> customerComplaints = [];

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Get all tasks and filter for this customer
        final response = await ApiService.getAllTasks(token);
        if (response['success'] == true) {
          final allTasks = response['data'] ?? [];
          customerComplaints = allTasks
              .where((task) =>
                  task['userId'] == customer['_id'] ||
                  task['userId'] == customer['id'])
              .toList()
              .cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('Error loading customer complaints: $e');
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CustomerDetails(
        customer: customer,
        complaints: customerComplaints,
      ),
    );
  }

  Future<void> _viewComplaintHistory(Map<String, dynamic> customer) async {
    List<Map<String, dynamic>> customerComplaints = [];

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.getAllTasks(token);
        if (response['success'] == true) {
          final allTasks = response['data'] ?? [];
          customerComplaints = allTasks
              .where((task) =>
                  task['userId'] == customer['_id'] ||
                  task['userId'] == customer['id'])
              .toList()
              .cast<Map<String, dynamic>>();
        }
      }
    } catch (e) {
      print('Error loading complaint history: $e');
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComplaintHistoryScreen(
          customer: customer,
          complaints: customerComplaints,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Customers'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCustomers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Customers List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredCustomers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No customers found',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = _filteredCustomers[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Text(
                                  customer['name']?[0].toUpperCase() ?? '?',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(customer['name'] ?? 'No Name'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(customer['email'] ?? 'No Email'),
                                  Text(customer['phone'] ?? 'No Phone'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.visibility,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _viewCustomerDetails(customer),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.history,
                                        color: Colors.orange),
                                    onPressed: () =>
                                        _viewComplaintHistory(customer),
                                  ),
                                ],
                              ),
                              onTap: () => _viewCustomerDetails(customer),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Customer Details Bottom Sheet with Complaints
class _CustomerDetails extends StatelessWidget {
  final Map<String, dynamic> customer;
  final List<Map<String, dynamic>> complaints;

  const _CustomerDetails({
    required this.customer,
    this.complaints = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    int totalComplaints = complaints.length;
    int pendingComplaints = complaints
        .where((c) => c['status']?.toString().toLowerCase() == 'pending')
        .length;
    int completedComplaints = complaints
        .where((c) => c['status']?.toString().toLowerCase() == 'completed')
        .length;

    return Container(
      padding: EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Customer Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green.shade100,
              child: Text(
                customer['name']?[0].toUpperCase() ?? '?',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              customer['name'] ?? 'No Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildDetailRow(
              Icons.email, 'Email', customer['email'] ?? 'No Email'),
          _buildDetailRow(
              Icons.phone, 'Phone', customer['phone'] ?? 'No Phone'),
          _buildDetailRow(Icons.person, 'Role', customer['role'] ?? 'user'),
          _buildDetailRow(Icons.calendar_today, 'Joined',
              _formatDate(customer['createdAt'] ?? '2024-01-15')),

          SizedBox(height: 16),

          // Complaints Statistics
          if (complaints.isNotEmpty) ...[
            Divider(),
            SizedBox(height: 8),
            Text(
              'Complaints Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip(
                    'Total', totalComplaints.toString(), Colors.blue),
                _buildStatChip(
                    'Pending', pendingComplaints.toString(), Colors.orange),
                _buildStatChip(
                    'Completed', completedComplaints.toString(), Colors.green),
              ],
            ),
            SizedBox(height: 8),

            // Recent Complaints
            Text(
              'Recent Complaints',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 100,
              child: ListView.builder(
                itemCount: complaints.length > 3 ? 3 : complaints.length,
                itemBuilder: (context, index) {
                  final complaint = complaints[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: _getStatusColor(complaint['status']),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            complaint['title'] ?? 'Untitled',
                            style: TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          complaint['status'] ?? 'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStatusColor(complaint['status']),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to message screen (optional)
                  },
                  icon: Icon(Icons.message),
                  label: Text('Message'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to full complaint history
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplaintHistoryScreen(
                          customer: customer,
                          complaints: complaints,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.history),
                  label: Text('All History'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
      case 'assigned':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

// Complaint History Screen
class ComplaintHistoryScreen extends StatelessWidget {
  final Map<String, dynamic> customer;
  final List<Map<String, dynamic>> complaints;

  const ComplaintHistoryScreen({
    Key? key,
    required this.customer,
    required this.complaints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${customer['name']}\'s Complaints'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: complaints.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No complaints found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaints[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                complaint['title'] ?? 'Untitled',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(complaint['status']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                complaint['status']?.toUpperCase() ?? 'PENDING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          complaint['description'] ?? 'No description',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.category, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              complaint['category'] ?? 'General',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              _formatDate(complaint['createdAt']),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
      case 'assigned':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
