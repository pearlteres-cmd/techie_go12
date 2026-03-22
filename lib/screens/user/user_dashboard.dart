import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import 'my_complaints.dart';
import 'register_complaint.dart';
import 'profile_screen.dart';
import '../auth/login_screen.dart';
import 'support_chat.dart';

class UserDashboard extends StatefulWidget {
  final UserModel user;
  const UserDashboard({super.key, required this.user});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _pendingCount = 2;
  int _assignedCount = 1;
  int _completedCount = 2;
  int _totalCount = 5;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // TODO: Implement actual data loading from API/local storage
    setState(() {});
  }

  void _navigateToMyComplaints() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyComplaints(user: widget.user)),
    ).then((_) => _loadDashboardData());
  }

  Future<void> _registerNewComplaint() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RegisterComplaint(user: widget.user)),
    );
    if (result != null && result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Complaint registered successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      _showOTPReminder();
      _loadDashboardData();
    }
  }

  void _showOTPReminder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Icon(Icons.info_outline, color: Colors.blue, size: 50),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Important Reminder',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
                'Your complaint has been registered with an OTP. Please share this OTP with the technician when they arrive.'),
            SizedBox(height: 8),
            Text('You can find the OTP in your complaint details.',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Got it'))
        ],
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(user: widget.user)),
    ).then((_) => _loadDashboardData());
  }

  void _navigateToSupportMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UserSupportMessages(user: widget.user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _showNotifications,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildWelcomeBanner(),
              const SizedBox(height: 20),
              _buildStatsSection(),
              const SizedBox(height: 20),
              _buildQuickActionsSection(),
              const SizedBox(height: 20),
              _buildRecentComplaintsSection(),
            ],
          ),
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
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue.shade700),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.blue),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt, color: Colors.blue),
            title: const Text('My Complaints'),
            onTap: () {
              Navigator.pop(context);
              _navigateToMyComplaints();
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle, color: Colors.green),
            title: const Text('New Complaint'),
            onTap: () {
              Navigator.pop(context);
              _registerNewComplaint();
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.purple),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              _navigateToProfile();
            },
          ),
          ListTile(
            leading: const Icon(Icons.message, color: Colors.orange),
            title: const Text('Support Messages'),
            onTap: () {
              Navigator.pop(context);
              _navigateToSupportMessages();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildNotificationItem(
                icon: Icons.info,
                color: Colors.blue,
                title: 'Your complaint #C002 has been assigned',
                time: '2 hours ago',
              ),
              _buildNotificationItem(
                icon: Icons.check,
                color: Colors.green,
                title: 'Complaint #C003 completed',
                time: '5 hours ago',
              ),
              _buildNotificationItem(
                icon: Icons.message,
                color: Colors.orange,
                title: 'Technician left a comment',
                time: '1 day ago',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
      {required IconData icon,
      required Color color,
      required String title,
      required String time}) {
    return ListTile(
      leading: CircleAvatar(
          backgroundColor: color, child: Icon(icon, color: Colors.white)),
      title: Text(title),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
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
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back,',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9), fontSize: 14)),
          Text(widget.user.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.email, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(widget.user.email,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text('ID: ${widget.user.id}',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: [
            _buildStatCard(
                'Total', _totalCount.toString(), Icons.list, Colors.blue),
            _buildStatCard('Pending', _pendingCount.toString(), Icons.pending,
                Colors.orange),
            _buildStatCard('Assigned', _assignedCount.toString(),
                Icons.assignment, Colors.purple),
            _buildStatCard('Completed', _completedCount.toString(),
                Icons.check_circle, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text(title,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard('New Complaint', Icons.add_circle, Colors.green,
                _registerNewComplaint),
            _buildActionCard('My Complaints', Icons.list_alt, Colors.blue,
                _navigateToMyComplaints),
            _buildActionCard(
                'Profile', Icons.person, Colors.purple, _navigateToProfile),
            _buildActionCard('Support', Icons.message, Colors.orange,
                _navigateToSupportMessages),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentComplaintsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Complaints',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                    onPressed: _navigateToMyComplaints,
                    child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentItem(
                'C001', 'Computer not starting', 'pending', '2 days ago'),
            const Divider(),
            _buildRecentItem(
                'C002', 'Internet connectivity issue', 'assigned', '1 day ago'),
            const Divider(),
            _buildRecentItem(
                'C003', 'Software installation', 'completed', '5 hours ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(String id, String title, String status, String time) {
    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'assigned':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: statusColor, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text('ID: $id • $time',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Text(status,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await prefs.setBool('is_logged_in', false);
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
