import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/models/complaint_model.dart';
import 'package:techie_go/services/api_service.dart';

class AssignTechnicianScreen extends StatefulWidget {
  final UserModel admin;
  final ComplaintModel complaint;

  const AssignTechnicianScreen({
    Key? key,
    required this.admin,
    required this.complaint,
  }) : super(key: key);

  @override
  State<AssignTechnicianScreen> createState() => _AssignTechnicianScreenState();
}

class _AssignTechnicianScreenState extends State<AssignTechnicianScreen> {
  bool _isLoading = true;
  List<dynamic> _technicians = [];
  String? _selectedTechnicianId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Use getAvailableTechnicians method
        final response = await ApiService.getAvailableTechnicians(token);

        if (response['success'] == true) {
          setState(() {
            _technicians = response['data'] ?? [];
          });
          print('✅ Loaded ${_technicians.length} available technicians');
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Failed to load technicians';
          });
        }
      }
    } catch (e) {
      print('❌ Error loading technicians: $e');
      setState(() {
        _errorMessage = 'Error loading technicians';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignTechnician() async {
    if (_selectedTechnicianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a technician'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Use assignComplaint method (not assignTechnician)
        final response = await ApiService.assignComplaint(
          token: token,
          complaintId: widget.complaint.id,
          technicianId: _selectedTechnicianId!,
        );

        if (response['success'] == true) {
          // Also create notification for technician using the existing method
          await ApiService.createNotification(
            token: token,
            type: 'task_assigned',
            message: 'New complaint assigned to you',
            userId: _selectedTechnicianId!,
            data: {'complaintId': widget.complaint.id},
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  response['message'] ?? 'Technician assigned successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(response['message'] ?? 'Failed to assign technician'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Assignment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Technician'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade600],
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
              : _errorMessage != null
                  ? _buildErrorState()
                  : _technicians.isEmpty
                      ? _buildEmptyState()
                      : _buildAssignmentUI(),
        ),
      ),
    );
  }

  Widget _buildAssignmentUI() {
    return Column(
      children: [
        // Complaint Summary Card
        Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                const Divider(),
                _buildDetailRow('ID', widget.complaint.id.substring(0, 8)),
                _buildDetailRow('Title', widget.complaint.title),
                _buildDetailRow('Type', widget.complaint.complaintType),
                _buildDetailRow('Priority', widget.complaint.priority,
                    color: widget.complaint.priorityColor),
                _buildDetailRow('User', widget.complaint.userName),
              ],
            ),
          ),
        ),

        // Technicians List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _technicians.length,
            itemBuilder: (context, index) {
              final tech = _technicians[index];
              final isSelected = _selectedTechnicianId == tech['_id'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? BorderSide(color: Colors.blue.shade800, width: 2)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTechnicianId = tech['_id'];
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tech['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    tech['rating']?.toString() ?? '4.5',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.work,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${tech['completedComplaints'] ?? 0} jobs',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              if (tech['skills'] != null)
                                Wrap(
                                  spacing: 4,
                                  children: (tech['skills'] as List)
                                      .take(2)
                                      .map((skill) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              skill,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                        Radio<String>(
                          value: tech['_id'],
                          groupValue: _selectedTechnicianId,
                          onChanged: (value) {
                            setState(() {
                              _selectedTechnicianId = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Assign Button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _assignTechnician,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Assign Technician',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
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
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error Loading Technicians',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadTechnicians,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Technicians Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All technicians are currently busy',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadTechnicians,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
