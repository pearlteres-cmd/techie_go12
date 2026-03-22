import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/complaint_model.dart';
import '../../services/api_service.dart';
import 'assign_task_screen.dart';
import 'view_complaints.dart'; // Import your existing ViewComplaints screen

class ManageComplaints extends StatefulWidget {
  final UserModel user;
  const ManageComplaints({Key? key, required this.user}) : super(key: key);

  @override
  State<ManageComplaints> createState() => _ManageComplaintsState();
}

class _ManageComplaintsState extends State<ManageComplaints> {
  List<ComplaintModel> _complaints = [];
  List<ComplaintModel> _filteredComplaints = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.getAllComplaints(token);
        if (response['success'] == true) {
          setState(() {
            _complaints = (response['data'] as List)
                .map((json) => ComplaintModel.fromJson(json))
                .toList();
            _applyFilter();
          });
        }
      }
    } catch (e) {
      _showError('Error loading complaints: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredComplaints = _complaints.where((complaint) {
        // Apply status filter
        if (_selectedFilter != 'all' && complaint.status != _selectedFilter) {
          return false;
        }

        // Apply search query
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          return complaint.title.toLowerCase().contains(query) ||
              complaint.userName.toLowerCase().contains(query) ||
              complaint.id.toLowerCase().contains(query);
        }

        return true;
      }).toList();
    });
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
        title: const Text('Manage Complaints'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplaints,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search complaints...',
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
                  _applyFilter();
                });
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', 'all', Colors.grey),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending', Colors.orange),
                const SizedBox(width: 8),
                _buildFilterChip('Assigned', 'assigned', Colors.blue),
                const SizedBox(width: 8),
                _buildFilterChip('In Progress', 'in_progress', Colors.purple),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', 'completed', Colors.green),
                const SizedBox(width: 8),
                _buildFilterChip('Cancelled', 'cancelled', Colors.red),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Complaint Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filteredComplaints.length} complaints found',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Complaint List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredComplaints.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadComplaints,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredComplaints.length,
                          itemBuilder: (context, index) {
                            final complaint = _filteredComplaints[index];
                            return _buildComplaintCard(complaint);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _applyFilter();
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to ViewComplaints with the selected complaint
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewComplaints(
                user: widget.user,
                initialComplaint: complaint, // Pass the selected complaint
              ),
            ),
          ).then((_) => _loadComplaints());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          'ID: ${complaint.id.length > 8 ? complaint.id.substring(0, 8) : complaint.id}...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(complaint.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      complaint.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(complaint.status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                    '${complaint.preferredDate.day}/${complaint.preferredDate.month}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              if (complaint.assignedTechnicianName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.build, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Assigned to: ${complaint.assignedTechnicianName}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
              if (complaint.status == 'pending') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _assignTechnician(complaint),
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Assign Technician'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 36),
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

  Future<void> _assignTechnician(ComplaintModel complaint) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignTaskScreen(
          user: widget.user,
          complaint: complaint, // Pass the complaint to assign screen
        ),
      ),
    );

    if (result == true) {
      _loadComplaints();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No complaints found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
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
}
