import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/complaint_model.dart';
import '../../services/api_service.dart';

class AssignTaskScreen extends StatefulWidget {
  final UserModel user;
  final ComplaintModel complaint;

  const AssignTaskScreen({
    Key? key,
    required this.user,
    required this.complaint,
  }) : super(key: key);

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  List<UserModel> _technicians = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Use getAvailableTechnicians or getTechnicians method
        final response = await ApiService.getTechnicians(token);
        if (response['success'] == true) {
          setState(() {
            _technicians = (response['data'] as List)
                .map((json) => UserModel.fromJson(json))
                .where((tech) => tech.status == 'available') // Filter available
                .toList();
          });
        }
      }
    } catch (e) {
      _showError('Error loading technicians: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<UserModel> get _filteredTechnicians {
    if (_searchQuery.isEmpty) return _technicians;
    return _technicians.where((tech) {
      return tech.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tech.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _assignTechnician(UserModel technician) async {
    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Use assignComplaint method from ApiService
        final response = await ApiService.assignComplaint(
          token: token,
          complaintId: widget.complaint.id,
          technicianId: technician.id,
        );

        if (response['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Complaint assigned to ${technician.name}'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          _showError(response['message'] ?? 'Assignment failed');
        }
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Technician'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Complaint Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complaint Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Title: ${widget.complaint.title}'),
                  Text('Customer: ${widget.complaint.userName}'),
                  Text('Priority: ${widget.complaint.priority}'),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search technicians...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // Technician Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filteredTechnicians.length} available technicians',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Technician List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTechnicians.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off,
                                size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No available technicians',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTechnicians.length,
                        itemBuilder: (context, index) {
                          final technician = _filteredTechnicians[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Text(
                                  technician.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(technician.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(technician.email),
                                  if (technician.skills != null &&
                                      technician.skills!.isNotEmpty)
                                    Text(
                                      'Skills: ${technician.skills!.join(', ')}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _assignTechnician(technician),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text('Assign'),
                              ),
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
