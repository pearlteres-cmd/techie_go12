import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class TechnicianDetailScreen extends StatefulWidget {
  final UserModel user;
  final UserModel technician;

  const TechnicianDetailScreen({
    Key? key,
    required this.user,
    required this.technician,
  }) : super(key: key);

  @override
  State<TechnicianDetailScreen> createState() => _TechnicianDetailScreenState();
}

class _TechnicianDetailScreenState extends State<TechnicianDetailScreen> {
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _experienceController;
  late String _status;
  late List<String> _selectedSkills;

  final List<String> _availableSkills = [
    'Hardware Expert',
    'Software Expert',
    'Network Expert',
    'Printer Expert',
    'Laptop Expert',
    'Desktop Expert',
    'Mobile Expert',
    'Data Recovery Expert',
    'Security Expert',
    'Cloud Expert',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.technician.name);
    _emailController = TextEditingController(text: widget.technician.email);
    _phoneController = TextEditingController(text: widget.technician.phone);
    _experienceController =
        TextEditingController(text: widget.technician.experience ?? '');
    _status = widget.technician.status;
    _selectedSkills = widget.technician.skills ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _updateTechnician() async {
    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.updateTechnician(
          token: token,
          technicianId: widget.technician.id,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          status: _status,
          skills: _selectedSkills,
          experience: _experienceController.text,
        );

        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Technician updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => _isEditing = false);
          Navigator.pop(context, true);
        } else {
          _showError(response['message'] ?? 'Update failed');
        }
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTechnician() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Technician'),
        content:
            Text('Are you sure you want to delete ${widget.technician.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        final token = await ApiService.getToken();
        if (token != null) {
          final response =
              await ApiService.deleteTechnician(token, widget.technician.id);

          if (response['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.technician.name} deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else {
            _showError(response['message'] ?? 'Delete failed');
          }
        }
      } catch (e) {
        _showError('Error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
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
        title: Text(_isEditing ? 'Edit Technician' : 'Technician Details'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTechnician,
            ),
          if (_isEditing) ...[
            TextButton(
              onPressed: _isLoading ? null : _updateTechnician,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _initializeControllers();
                setState(() => _isEditing = false);
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.green.shade100,
                          child: Text(
                            widget.technician.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!_isEditing)
                          Text(
                            widget.technician.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.technician.status == 'available'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Status: ${widget.technician.status}',
                            style: TextStyle(
                              color: widget.technician.status == 'available'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Details Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (_isEditing) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.info),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'available',
                                  child: Text('Available'),
                                ),
                                DropdownMenuItem(
                                  value: 'busy',
                                  child: Text('Busy'),
                                ),
                                DropdownMenuItem(
                                  value: 'inactive',
                                  child: Text('Inactive'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _status = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _experienceController,
                              decoration: const InputDecoration(
                                labelText: 'Experience',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.work),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Skills:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._availableSkills.map((skill) {
                              return CheckboxListTile(
                                title: Text(skill),
                                value: _selectedSkills.contains(skill),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked!) {
                                      _selectedSkills.add(skill);
                                    } else {
                                      _selectedSkills.remove(skill);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ] else ...[
                            _buildDetailRow('Email', widget.technician.email),
                            _buildDetailRow('Phone', widget.technician.phone),
                            if (widget.technician.experience != null &&
                                widget.technician.experience!.isNotEmpty)
                              _buildDetailRow(
                                  'Experience', widget.technician.experience!),
                            if (widget.technician.rating > 0)
                              _buildDetailRow('Rating',
                                  '${widget.technician.rating.toStringAsFixed(1)} ⭐'),
                            _buildDetailRow('Member Since',
                                '${widget.technician.createdAt.day}/${widget.technician.createdAt.month}/${widget.technician.createdAt.year}'),
                            if (widget.technician.skills != null &&
                                widget.technician.skills!.isNotEmpty) ...[
                              const Divider(height: 30),
                              const Text(
                                'Skills',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    widget.technician.skills!.map((skill) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.blue.shade200),
                                    ),
                                    child: Text(
                                      skill,
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Login Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 20),
                          _buildDetailRow('Email', widget.technician.email),
                          _buildDetailRow('Password', '•••••••• (hidden)'),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'This technician can login with their email and the password you set during registration.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
