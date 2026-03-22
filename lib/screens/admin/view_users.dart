// lib/screens/admin/view_users.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class ViewUsers extends StatefulWidget {
  final UserModel user;
  const ViewUsers({super.key, required this.user});

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _users = [
        {
          'id': 'USR001',
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'phone': '+1 234-567-8900',
          'address': '123 Main St, New York, NY',
          'joined': '2024-01-15',
          'complaints': 3,
        },
        {
          'id': 'USR002',
          'name': 'Jane Smith',
          'email': 'jane.smith@example.com',
          'phone': '+1 234-567-8901',
          'address': '456 Oak Ave, Los Angeles, CA',
          'joined': '2024-01-20',
          'complaints': 1,
        },
        {
          'id': 'USR003',
          'name': 'Bob Wilson',
          'email': 'bob.wilson@example.com',
          'phone': '+1 234-567-8902',
          'address': '789 Pine St, Chicago, IL',
          'joined': '2024-02-01',
          'complaints': 5,
        },
        {
          'id': 'USR004',
          'name': 'Alice Brown',
          'email': 'alice.brown@example.com',
          'phone': '+1 234-567-8903',
          'address': '321 Elm St, Houston, TX',
          'joined': '2024-02-10',
          'complaints': 2,
        },
      ];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users
        .where((user) =>
            user['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user['email'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user['id'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Users'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Total Users', _users.length.toString(),
                            Icons.people, Colors.blue),
                        _buildStatItem('Active', _users.length.toString(),
                            Icons.check_circle, Colors.green),
                        _buildStatItem(
                            'New (30d)', '4', Icons.person_add, Colors.orange),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                user['name'][0],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              user['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${user['id']}'),
                                Text('Email: ${user['email']}'),
                                Text('Phone: ${user['phone']}'),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showUserDetails(user),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Users'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter name, email or ID...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          onSubmitted: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue,
                child: Text(
                  user['name'][0],
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user['name'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user['email'],
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const Divider(height: 32),
              _buildDetailRow(Icons.badge, 'User ID', user['id']),
              _buildDetailRow(Icons.phone, 'Phone', user['phone']),
              _buildDetailRow(Icons.location_on, 'Address', user['address']),
              _buildDetailRow(Icons.calendar_today, 'Joined', user['joined']),
              _buildDetailRow(
                  Icons.list_alt, 'Complaints', '${user['complaints']}'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Viewing complaints of ${user['name']}')),
                        );
                      },
                      child: const Text('View Complaints'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
