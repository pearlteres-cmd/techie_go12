// lib/screens/admin/manage_technicians.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class ManageTechnicians extends StatefulWidget {
  final UserModel user;
  const ManageTechnicians({super.key, required this.user});

  @override
  State<ManageTechnicians> createState() => _ManageTechniciansState();
}

class _ManageTechniciansState extends State<ManageTechnicians> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _technicians = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _technicians = [
        {
          'id': 'TECH001',
          'name': 'John Smith',
          'email': 'john.smith@techiego.com',
          'phone': '+1 234-567-8901',
          'specialization': 'Hardware',
          'isAvailable': true,
          'assignedComplaints': 2,
          'completedComplaints': 15,
        },
        {
          'id': 'TECH002',
          'name': 'Sarah Johnson',
          'email': 'sarah.j@techiego.com',
          'phone': '+1 234-567-8902',
          'specialization': 'Software',
          'isAvailable': true,
          'assignedComplaints': 1,
          'completedComplaints': 23,
        },
        {
          'id': 'TECH003',
          'name': 'Mike Wilson',
          'email': 'mike.w@techiego.com',
          'phone': '+1 234-567-8903',
          'specialization': 'Networking',
          'isAvailable': false,
          'assignedComplaints': 3,
          'completedComplaints': 8,
        },
      ];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredTechnicians {
    if (_searchController.text.isEmpty) return _technicians;
    return _technicians
        .where((tech) =>
            tech['name']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            tech['id']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            tech['specialization']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search technicians...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                onChanged: (value) => setState(() {}),
              )
            : const Text('Manage Technicians'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTechnicians,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTechnicians,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          'Total',
                          _technicians.length.toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                        _buildSummaryItem(
                          'Available',
                          _technicians
                              .where((t) => t['isAvailable'] == true)
                              .length
                              .toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildSummaryItem(
                          'Busy',
                          _technicians
                              .where((t) => t['isAvailable'] == false)
                              .length
                              .toString(),
                          Icons.access_time,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filteredTechnicians.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_off,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text('No technicians found',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _filteredTechnicians.length,
                            itemBuilder: (context, index) {
                              final tech = _filteredTechnicians[index];
                              return _buildTechnicianCard(tech);
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTechnicianDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildTechnicianCard(Map<String, dynamic> tech) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: tech['isAvailable'] ? Colors.green : Colors.orange,
          child: Text(tech['name'][0],
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(tech['name'],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${tech['id']}'),
            Text('Specialization: ${tech['specialization']}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: tech['isAvailable'] ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tech['isAvailable'] ? 'Available' : 'Busy',
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.email, 'Email', tech['email']),
                _buildInfoRow(Icons.phone, 'Phone', tech['phone']),
                _buildInfoRow(Icons.assignment, 'Assigned',
                    '${tech['assignedComplaints']} complaints'),
                _buildInfoRow(Icons.check_circle, 'Completed',
                    '${tech['completedComplaints']} complaints'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editTechnician(tech),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleAvailability(tech),
                        icon: Icon(
                            tech['isAvailable']
                                ? Icons.access_time
                                : Icons.check_circle,
                            size: 18),
                        label: Text(
                            tech['isAvailable'] ? 'Set Busy' : 'Set Available'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tech['isAvailable']
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deleteTechnician(tech),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
              width: 80,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddTechnicianDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Technician'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Full Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Phone', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                decoration: const InputDecoration(
                    labelText: 'Specialization', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Hardware', child: Text('Hardware')),
                  DropdownMenuItem(value: 'Software', child: Text('Software')),
                  DropdownMenuItem(
                      value: 'Networking', child: Text('Networking')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Technician added successfully'),
                    backgroundColor: Colors.green),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editTechnician(Map<String, dynamic> tech) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${tech['name']} - Feature coming soon')),
    );
  }

  void _toggleAvailability(Map<String, dynamic> tech) {
    setState(() {
      tech['isAvailable'] = !tech['isAvailable'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${tech['name']} is now ${tech['isAvailable'] ? 'available' : 'busy'}'),
        backgroundColor: tech['isAvailable'] ? Colors.green : Colors.orange,
      ),
    );
  }

  void _deleteTechnician(Map<String, dynamic> tech) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Technician'),
        content: Text('Are you sure you want to delete ${tech['name']}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _technicians.remove(tech);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('${tech['name']} deleted'),
                    backgroundColor: Colors.red),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
