// lib/screens/landing_screen.dart
import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  final String userRole;
  final String userName;

  const LandingScreen({
    super.key,
    this.userRole = 'User',
    this.userName = 'Guest',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Techie Go - $userRole Dashboard'),
        backgroundColor: _getRoleColor(userRole),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getRoleIcon(userRole),
              size: 100,
              color: _getRoleColor(userRole),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome, $userName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You are logged in as: $userRole',
              style: TextStyle(
                fontSize: 18,
                color: _getRoleColor(userRole),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to different dashboards based on role
                _navigateToDashboard(context, userRole);
              },
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'staff':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'staff':
        return Icons.engineering;
      default:
        return Icons.person;
    }
  }

  void _navigateToDashboard(BuildContext context, String role) {
    // You can implement different screens for different roles
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$role Dashboard'),
        content: Text('This would be the $role dashboard screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
