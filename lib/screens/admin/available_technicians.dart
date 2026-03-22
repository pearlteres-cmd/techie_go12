import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/services/api_service.dart';

class AvailableTechnicians extends StatefulWidget {
  final UserModel user;
  final Map<String, dynamic>? complaint;

  const AvailableTechnicians({Key? key, required this.user, this.complaint})
      : super(key: key);

  @override
  _AvailableTechniciansState createState() => _AvailableTechniciansState();
}

class _AvailableTechniciansState extends State<AvailableTechnicians> {
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedExpertise = 'All';

  final List<String> _expertiseFilters = [
    'All',
    'Hardware',
    'Software',
    'Network',
    'Printer',
    'Laptop',
    'Mobile'
  ];

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData == null) return [];
    if (responseData is List) return responseData;
    if (responseData is Map) {
      if (responseData.containsKey('data') && responseData['data'] is List) {
        return responseData['data'] as List;
      }
      if (responseData.containsKey('technicians') &&
          responseData['technicians'] is List) {
        return responseData['technicians'] as List;
      }
      if (responseData.containsKey('users') && responseData['users'] is List) {
        return responseData['users'] as List;
      }
    }
    return [];
  }

  Future<void> _loadTechnicians() async {
    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        print('No token found');
        setState(() => _isLoading = false);
        return;
      }

      // Try dedicated endpoint first
      print('Trying getAvailableTechnicians...');
      var response = await ApiService.getAvailableTechnicians(token);
      bool success = response['success'] == true;
      print('getAvailableTechnicians success: $success');

      List<dynamic> techList = [];

      if (success) {
        techList = _extractList(response['data']);
      }

      // If no data from dedicated endpoint, fallback to getTechnicians
      if (techList.isEmpty) {
        print('Falling back to getTechnicians...');
        response = await ApiService.getTechnicians(token);
        success = response['success'] == true;
        if (success) {
          techList = _extractList(response['data']);
          print('getTechnicians raw data: $techList');
        }
      }

      // If still empty, try getAllTechnicians (from employee management)
      if (techList.isEmpty) {
        print('Falling back to getAllTechnicians...');
        response = await ApiService.getAllTechnicians(token);
        success = response['success'] == true;
        if (success) {
          techList = _extractList(response['data']);
        }
      }

      // Debug: print first few technicians before filtering
      if (techList.isNotEmpty) {
        print('First technician before filter: ${techList.first}');
      }

      // Filter to only available technicians (if status field exists)
      techList = techList.where((t) {
        final status = t['status']?.toString().toLowerCase();
        // If status is missing, assume available (for mock data)
        return status == 'available' || status == null;
      }).toList();

      print(
          'Final technician count after availability filter: ${techList.length}');

      setState(() {
        _technicians = List<Map<String, dynamic>>.from(techList);
      });
    } catch (e) {
      print('Error loading technicians: $e');
      setState(() => _technicians = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredTechnicians {
    return _technicians.where((tech) {
      if (_searchQuery.isNotEmpty) {
        final name = tech['name']?.toString().toLowerCase() ?? '';
        final email = tech['email']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !email.contains(query)) return false;
      }

      if (_selectedExpertise != 'All') {
        final skills =
            (tech['skills'] as List?)?.map((s) => s.toString()) ?? [];
        final expertise =
            (tech['expertise'] as List?)?.map((e) => e.toString()) ?? [];
        final allSkills = [...skills, ...expertise];
        if (!allSkills.any((s) =>
            s.toLowerCase().contains(_selectedExpertise.toLowerCase()))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _assignTechnician(Map<String, dynamic> technician) async {
    if (widget.complaint == null) {
      _showTechnicianDetails(technician);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Technician'),
        content: Text('Assign ${technician['name']} to this complaint?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('No token');

      final response = await ApiService.assignComplaint(
        token: token,
        complaintId: widget.complaint!['_id'] ?? widget.complaint!['id'],
        technicianId: technician['_id'] ?? technician['id'],
      );

      if (mounted) Navigator.pop(context); // close loading

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Technician assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(response['message'] ?? 'Assignment failed');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTechnicianDetails(Map<String, dynamic> technician) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green.shade100,
              child: Text(
                technician['name']?[0].toUpperCase() ?? '?',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              technician['name'] ?? 'Unknown',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Available',
                style: TextStyle(color: Colors.green.shade800),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.email, 'Email', technician['email'] ?? 'N/A'),
            _buildDetailRow(Icons.phone, 'Phone', technician['phone'] ?? 'N/A'),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Skills:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...?((technician['skills'] as List?)?.map((skill) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        skill.toString(),
                        style: TextStyle(
                            fontSize: 12, color: Colors.blue.shade800),
                      ),
                    ))),
                ...?((technician['expertise'] as List?)?.map((exp) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        exp.toString(),
                        style: TextStyle(
                            fontSize: 12, color: Colors.orange.shade800),
                      ),
                    ))),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.complaint != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _assignTechnician(technician);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Assign to Complaint'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.complaint == null
            ? 'Available Technicians'
            : 'Assign Technician'),
        backgroundColor: Colors.green.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTechnicians,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search technicians...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _expertiseFilters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedExpertise == filter,
                          onSelected: (selected) =>
                              setState(() => _selectedExpertise = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTechnicians.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_off,
                                size: 80, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No available technicians',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTechnicians.length,
                        itemBuilder: (context, index) {
                          final tech = _filteredTechnicians[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Text(
                                  tech['name']?[0].toUpperCase() ?? '?',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(tech['name'] ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tech['email'] ?? 'No email'),
                                  Text(
                                      'Skills: ${(tech['skills'] as List?)?.join(', ') ?? (tech['expertise'] as List?)?.join(', ') ?? 'General'}'),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _assignTechnician(tech),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: Text(widget.complaint == null
                                    ? 'View'
                                    : 'Assign'),
                              ),
                              onTap: () => _showTechnicianDetails(tech),
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
