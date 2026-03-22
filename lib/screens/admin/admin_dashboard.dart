import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/complaint_model.dart';
import '../../models/payment_model.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

// Import all admin screens
import 'manage_employees.dart';
import 'manage_customers.dart';
import 'available_technicians.dart';
import 'payment_details.dart';
import 'manage_complaints.dart';
import 'support_messages.dart'; // exports AdminSupportMessages
import 'edit_profile.dart';
import 'employee_management.dart'; // exports EmployeeManagementScreen
import 'view_complaints.dart';
import 'view_users.dart';
import 'admin_payments.dart'; // exports AdminPaymentsScreen

class AdminDashboard extends StatefulWidget {
  final UserModel user;
  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Dashboard Statistics
  int _totalEmployees = 0;
  int _totalCustomers = 0;
  int _availableTechnicians = 0;
  int _totalComplaints = 0;
  int _pendingComplaints = 0;
  int _inProgressComplaints = 0;
  int _completedComplaints = 0;
  int _totalPayments = 0;
  double _totalRevenue = 0;
  int _unreadMessages = 0;

  // Lists for recent items
  List<ComplaintModel> _recentComplaints = [];
  List<Map<String, dynamic>> _recentPayments = [];
  List<Map<String, dynamic>> _recentMessages = [];

  // For employee management
  List<UserModel> _allEmployees = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Not authenticated. Please login again.';
          _isLoading = false;
        });
        return;
      }

      await Future.wait([
        _loadStatistics(token),
        _loadRecentComplaints(token),
        _loadRecentPayments(token),
        _loadUnreadMessages(token),
        _loadAllEmployees(token),
      ]);
    } catch (e) {
      print('Error loading dashboard: $e');
      setState(() {
        _errorMessage = 'Failed to load dashboard data: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Safely extracts a list from API response.
  List<dynamic> _extractList(dynamic responseData) {
    if (responseData == null) return [];
    if (responseData is List) return responseData;
    if (responseData is Map) {
      if (responseData.containsKey('data') && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      if (responseData.containsKey('users') && responseData['users'] is List) {
        return responseData['users'] as List;
      }
      if (responseData.containsKey('messages') &&
          responseData['messages'] is List) {
        return responseData['messages'] as List;
      }
    }
    return [];
  }

  Future<void> _loadStatistics(String token) async {
    try {
      // Users
      final usersResponse = await ApiService.getUsers(token);
      if (usersResponse['success'] == true) {
        final usersList = _extractList(usersResponse['data']);
        setState(() {
          _totalCustomers =
              usersList.where((u) => u['userType'] == 'user').length;
          _totalEmployees = usersList
              .where((u) =>
                  u['userType'] == 'technician' || u['userType'] == 'admin')
              .length;
          _availableTechnicians = usersList
              .where((u) =>
                  u['userType'] == 'technician' && u['status'] == 'available')
              .length;
        });
      }

      // Complaints
      final complaintsResponse = await ApiService.getAllComplaints(token);
      if (complaintsResponse['success'] == true) {
        final complaintsList = _extractList(complaintsResponse['data']);
        setState(() {
          _totalComplaints = complaintsList.length;
          _pendingComplaints =
              complaintsList.where((c) => c['status'] == 'pending').length;
          _inProgressComplaints = complaintsList
              .where((c) =>
                  c['status'] == 'assigned' || c['status'] == 'in_progress')
              .length;
          _completedComplaints =
              complaintsList.where((c) => c['status'] == 'completed').length;
        });
      }

      // Payments
      final paymentsResponse = await ApiService.getAllPayments(token);
      if (paymentsResponse['success'] == true) {
        final paymentsList = _extractList(paymentsResponse['data']);
        setState(() {
          _totalPayments = paymentsList.length;
          _totalRevenue =
              paymentsList.fold(0.0, (sum, p) => sum + (p['amount'] ?? 0));
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  Future<void> _loadRecentComplaints(String token) async {
    try {
      final response = await ApiService.getAllComplaints(token);
      if (response['success'] == true) {
        final complaintsList = _extractList(response['data']);
        setState(() {
          _recentComplaints = complaintsList
              .take(5)
              .map((c) => ComplaintModel.fromJson(c as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading recent complaints: $e');
    }
  }

  Future<void> _loadRecentPayments(String token) async {
    try {
      final response = await ApiService.getAllPayments(token);
      if (response['success'] == true) {
        final paymentsList = _extractList(response['data']);
        setState(() {
          _recentPayments = paymentsList
              .take(5)
              .map((p) => Map<String, dynamic>.from(p))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading recent payments: $e');
    }
  }

  Future<void> _loadUnreadMessages(String token) async {
    try {
      final response = await ApiService.getAllSupportMessages(token);
      if (response['success'] == true) {
        final messagesList = _extractList(response['data']);
        setState(() {
          _unreadMessages =
              messagesList.where((m) => m['isRead'] == false).length;
          _recentMessages = messagesList
              .take(3)
              .map((m) => Map<String, dynamic>.from(m))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _loadAllEmployees(String token) async {
    try {
      final response = await ApiService.getUsers(token);
      if (response['success'] == true) {
        final usersList = _extractList(response['data']);
        setState(() {
          _allEmployees = usersList
              .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
              .where((u) => u.userType == 'technician' || u.userType == 'admin')
              .toList();
        });
      }
    } catch (e) {
      print('Error loading employees: $e');
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => _loadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message),
                onPressed: () => _navigateToScreen(
                  AdminSupportMessages(user: widget.user),
                ),
              ),
              if (_unreadMessages > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadMessages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade50, Colors.white],
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: _loadDashboardData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeBanner(),
                          const SizedBox(height: 20),
                          _buildStatisticsSection(),
                          const SizedBox(height: 20),
                          _buildQuickActions(),
                          const SizedBox(height: 20),
                          _buildRecentComplaints(),
                          const SizedBox(height: 20),
                          _buildRecentPayments(),
                          const SizedBox(height: 20),
                          _buildRecentMessages(),
                        ],
                      ),
                    ),
                  ),
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
              _errorMessage ?? 'Unable to load dashboard',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
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

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.user.name),
            accountEmail: Text(widget.user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.user.name[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.blue),
                  title: const Text('Dashboard'),
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(),

                // Employee Management
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'EMPLOYEE MANAGEMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.green),
                  title: const Text('Register New Employee'),
                  onTap: () => _navigateToScreen(
                    ManageEmployees(user: widget.user),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.blue),
                  title: const Text('Manage Employees'),
                  onTap: () => _navigateToScreen(
                    EmployeeManagementScreen(
                      employees: _allEmployees,
                    ),
                  ),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.person_search, color: Colors.orange),
                  title: const Text('Available Technicians'),
                  onTap: () => _navigateToScreen(
                    AvailableTechnicians(user: widget.user),
                  ),
                ),

                const Divider(),

                // Customer Management
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'CUSTOMER MANAGEMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.group, color: Colors.purple),
                  title: const Text('View Customers'),
                  onTap: () => _navigateToScreen(
                    ManageCustomers(user: widget.user),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.visibility, color: Colors.purple),
                  title: const Text('Customer Details'),
                  onTap: () => _navigateToScreen(
                    ViewUsers(user: widget.user),
                  ),
                ),

                const Divider(),

                // Complaint Management
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'COMPLAINT MANAGEMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt, color: Colors.blue),
                  title: const Text('All Complaints'),
                  onTap: () => _navigateToScreen(
                    ManageComplaints(user: widget.user),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.pending, color: Colors.orange),
                  title: const Text('Pending Complaints'),
                  onTap: () => _navigateToScreen(
                    ViewComplaints(user: widget.user),
                  ),
                ),

                const Divider(),

                // Payment Management
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'PAYMENT MANAGEMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.green),
                  title: const Text('All Payments'),
                  onTap: () => _navigateToScreen(
                    AdminPaymentsScreen(user: widget.user),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.receipt, color: Colors.blue),
                  title: const Text('Payment Details'),
                  onTap: () => _navigateToScreen(
                    PaymentDetails(user: widget.user, payment: null),
                  ),
                ),

                const Divider(),

                // Messages & Support
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'MESSAGES & SUPPORT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: Stack(
                    children: [
                      const Icon(Icons.message, color: Colors.orange),
                      if (_unreadMessages > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '$_unreadMessages',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: const Text('Support Messages'),
                  onTap: () => _navigateToScreen(
                    AdminSupportMessages(user: widget.user),
                  ),
                ),

                const Divider(),

                // Profile & Settings
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    'PROFILE & SETTINGS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.green),
                  title: const Text('Edit Profile'),
                  onTap: () => _navigateToScreen(
                    EditProfile(user: widget.user),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          Text(
            widget.user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                widget.user.email,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.badge, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              const Text(
                'Admin',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dashboard Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildStatCard(
              'Total Employees',
              '$_totalEmployees',
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Total Customers',
              '$_totalCustomers',
              Icons.group,
              Colors.purple,
            ),
            _buildStatCard(
              'Available Techs',
              '$_availableTechnicians',
              Icons.person_search,
              Colors.green,
            ),
            _buildStatCard(
              'Total Complaints',
              '$_totalComplaints',
              Icons.list_alt,
              Colors.orange,
            ),
            _buildStatCard(
              'Pending',
              '$_pendingComplaints',
              Icons.pending,
              Colors.red,
            ),
            _buildStatCard(
              'In Progress',
              '$_inProgressComplaints',
              Icons.assignment,
              Colors.amber,
            ),
            _buildStatCard(
              'Completed',
              '$_completedComplaints',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Total Payments',
              '$_totalPayments',
              Icons.payment,
              Colors.teal,
            ),
          ],
        ),
        Card(
          elevation: 3,
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
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.currency_rupee,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Revenue',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '₹${_totalRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildQuickActionButton(
              'New Employee',
              Icons.person_add,
              Colors.green,
              () => _navigateToScreen(ManageEmployees(user: widget.user)),
            ),
            _buildQuickActionButton(
              'View Customers',
              Icons.group,
              Colors.purple,
              () => _navigateToScreen(ManageCustomers(user: widget.user)),
            ),
            _buildQuickActionButton(
              'Available Techs',
              Icons.person_search,
              Colors.blue,
              () => _navigateToScreen(AvailableTechnicians(user: widget.user)),
            ),
            _buildQuickActionButton(
              'Complaints',
              Icons.list_alt,
              Colors.orange,
              () => _navigateToScreen(ManageComplaints(user: widget.user)),
            ),
            _buildQuickActionButton(
              'Payments',
              Icons.payment,
              Colors.teal,
              () => _navigateToScreen(AdminPaymentsScreen(user: widget.user)),
            ),
            _buildQuickActionButton(
              'Messages',
              Icons.message,
              Colors.red,
              () => _navigateToScreen(AdminSupportMessages(user: widget.user)),
            ),
            _buildQuickActionButton(
              'Edit Profile',
              Icons.edit,
              Colors.blue,
              () => _navigateToScreen(EditProfile(user: widget.user)),
            ),
            _buildQuickActionButton(
              'Dashboard',
              Icons.dashboard,
              Colors.grey,
              () => Navigator.pop(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentComplaints() {
    return Card(
      elevation: 3,
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
                  'Recent Complaints',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToScreen(
                    ManageComplaints(user: widget.user),
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _recentComplaints.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No recent complaints'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentComplaints.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final complaint = _recentComplaints[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(complaint.status),
                          radius: 6,
                        ),
                        title: Text(
                          complaint.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'ID: ${complaint.id} • ${complaint.userName}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(complaint.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            complaint.status,
                            style: TextStyle(
                              color: _getStatusColor(complaint.status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewComplaints(
                                user: widget.user,
                                initialComplaint: complaint,
                              ),
                            ),
                          ).then((_) {
                            _loadDashboardData();
                          });
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPayments() {
    return Card(
      elevation: 3,
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
                  'Recent Payments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToScreen(
                    AdminPaymentsScreen(user: widget.user),
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _recentPayments.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No recent payments'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentPayments.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final payment = _recentPayments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _getPaymentStatusColor(payment['status']),
                          child: Text(
                            '₹',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          payment['userName'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Amount: ₹${payment['amount']}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Text(
                          payment['status'] ?? 'pending',
                          style: TextStyle(
                            color: _getPaymentStatusColor(payment['status']),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentDetails(
                                user: widget.user,
                                payment: PaymentModel.fromJson(payment),
                              ),
                            ),
                          ).then((_) {
                            _loadDashboardData();
                          });
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMessages() {
    return Card(
      elevation: 3,
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
                  'Recent Messages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToScreen(
                    AdminSupportMessages(user: widget.user),
                  ),
                  child: Text(
                    'View All (${_unreadMessages} unread)',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _recentMessages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No new messages'),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentMessages.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final message = _recentMessages[index];
                      final isUnread = message['isRead'] == false;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isUnread ? Colors.red : Colors.grey,
                          radius: 4,
                        ),
                        title: Text(
                          message['userName'] ?? 'Unknown',
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          message['message'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Text(
                          _formatTime(message['createdAt']),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
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

  Color _getPaymentStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
