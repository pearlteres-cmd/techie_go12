import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/services/api_service.dart';
import 'package:techie_go/screens/technician/available_tasks.dart';
import 'package:techie_go/screens/technician/working_tasks.dart';
import 'package:techie_go/screens/technician/completed_tasks.dart';
import 'package:techie_go/screens/technician/edit_profile.dart';
import 'package:techie_go/screens/technician/assigned_tasks.dart'; // Fixed import
import 'package:techie_go/screens/auth/login_screen.dart';

class TechDashboard extends StatefulWidget {
  final UserModel user;

  const TechDashboard({Key? key, required this.user}) : super(key: key);

  @override
  _TechDashboardState createState() => _TechDashboardState();
}

class _TechDashboardState extends State<TechDashboard> {
  late UserModel _user; // keep a mutable copy so we can refresh after edits
  bool _isLoading = true;

  // Dashboard Stats
  int _assignedCount = 0;
  int _availableCount = 0;
  int _workingCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.getTechnicianDashboard(token);
        if (response['success'] == true) {
          final data = response['data'] ?? {};
          setState(() {
            _assignedCount = data['assignedCount'] ?? 0;
            _availableCount = data['availableCount'] ?? 0;
            _workingCount = data['workingCount'] ?? 0;
            _completedCount = data['completedCount'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
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

  void _refreshUser() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final resp = await ApiService.getUserProfile(token);
        if (resp['success'] == true && resp['user'] != null) {
          setState(() {
            _user = UserModel.fromJson(resp['user']);
          });
        }
      }
    } catch (e) {
      // ignore errors, not critical
      print('failed to refresh user: $e');
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        // already on dashboard
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvailableTasks(user: _user),
          ),
        ).then((_) {
          _loadDashboardData();
        });
        break;
      case 2:
        // FIXED: Use the correct class name
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TechnicianAssignedComplaints(technician: _user),
          ),
        ).then((_) {
          _loadDashboardData();
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkingTasks(user: _user),
          ),
        ).then((_) {
          _loadDashboardData();
        });
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompletedTasks(user: _user),
          ),
        ).then((_) {
          _loadDashboardData();
        });
        break;
      case 5:
        // profile tile in navigation grid – just view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfile(user: _user),
          ),
        ).then((_) {
          _refreshUser();
          _loadDashboardData();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Dashboard'),
        backgroundColor: Colors.green.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          PopupMenuButton<int>(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                _user.name.isNotEmpty ? _user.name[0].toUpperCase() : 'T',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            itemBuilder: (ctx) => [
              const PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Profile'),
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 0: // just view
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfile(user: _user),
                    ),
                  ).then((_) {
                    _refreshUser();
                    _loadDashboardData();
                  });
                  break;
                case 1: // start editing immediately
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfile(user: _user),
                    ),
                  ).then((_) {
                    _refreshUser();
                    _loadDashboardData();
                  });
                  break;
                case 2: // Logout
                  _logout();
                  break;
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade800,
              Colors.green.shade600,
            ],
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 20),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildTodaySchedule(),
                      const SizedBox(height: 20),
                      _buildNavigationGrid(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade800, Colors.teal.shade800],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            _user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Expertise: ${_getExpertiseString()}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getExpertiseString() {
    if (_user.skills != null && _user.skills!.isNotEmpty) {
      return _user.skills!.join(', ');
    }
    return 'Hardware, Software Expert';
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Available',
          _availableCount.toString(),
          Icons.event_available,
          Colors.blue,
          onTap: () => _onItemTapped(1),
        ),
        _buildStatCard(
          'Assigned',
          _assignedCount.toString(),
          Icons.assignment_ind,
          Colors.orange,
          onTap: () => _onItemTapped(2),
        ),
        _buildStatCard(
          'Working',
          _workingCount.toString(),
          Icons.work,
          Colors.purple,
          onTap: () => _onItemTapped(3),
        ),
        _buildStatCard(
          'Completed',
          _completedCount.toString(),
          Icons.check_circle,
          Colors.green,
          onTap: () => _onItemTapped(4),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Available',
            Icons.event_available,
            Colors.blue,
            () => _onItemTapped(1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            'Assigned',
            Icons.assignment_ind,
            Colors.orange,
            () => _onItemTapped(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            'Working',
            Icons.work,
            Colors.purple,
            () => _onItemTapped(3),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildScheduleItem(
              '10:00 AM',
              'Printer Repair',
              'Office',
              'Pending',
              Colors.orange,
            ),
            const Divider(),
            _buildScheduleItem(
              '2:00 PM',
              'Software Installation',
              'Home',
              'Confirmed',
              Colors.green,
            ),
            const Divider(),
            _buildScheduleItem(
              '4:30 PM',
              'Network Issue',
              'Office',
              'Assigned',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(String time, String task, String location,
      String status, Color statusColor) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                location,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 10,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2,
      children: [
        _buildNavItem('Available', Icons.event_available, Colors.blue, 1),
        _buildNavItem('Assigned', Icons.assignment_ind, Colors.orange, 2),
        _buildNavItem('Working', Icons.work, Colors.purple, 3),
        _buildNavItem('Completed', Icons.check_circle, Colors.green, 4),
        _buildNavItem('Profile', Icons.edit, Colors.brown, 5),
      ],
    );
  }

  Widget _buildNavItem(String label, IconData icon, Color color, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
