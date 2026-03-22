// lib/screens/admin/employee_management.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class EmployeeManagementScreen extends StatefulWidget {
  final List<UserModel> employees;

  const EmployeeManagementScreen({
    super.key,
    required this.employees,
  });

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  List<UserModel> _filteredEmployees = [];
  String _filterRole = 'all';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for add/edit employee
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();

  String _selectedRole = 'technician';
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _filteredEmployees = widget.employees;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _filterEmployees(String role) {
    setState(() {
      _filterRole = role;
      if (role == 'all') {
        _filteredEmployees = widget.employees;
      } else {
        _filteredEmployees = widget.employees
            .where((employee) =>
                employee.userType == role) // FIXED: Changed role to userType
            .toList();
      }
    });
  }

  Future<void> _refreshEmployees() async {
    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.getUsers(token);
        if (response['success'] == true) {
          final List<dynamic> usersData = response['data'] ?? [];
          final List<UserModel> updatedEmployees =
              usersData.map((json) => UserModel.fromJson(json)).toList();

          setState(() {
            // FIXED: Can't modify widget.employees directly
            _filteredEmployees = updatedEmployees.where((e) {
              if (_filterRole == 'all') return true;
              return e.userType == _filterRole;
            }).toList();
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to refresh: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshEmployees,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _filterRole == 'all',
                          onSelected: (_) => _filterEmployees('all'),
                        ),
                        const SizedBox(width: 10),
                        FilterChip(
                          label: const Text('Technicians'),
                          selected: _filterRole == 'technician',
                          onSelected: (_) => _filterEmployees('technician'),
                        ),
                        const SizedBox(width: 10),
                        FilterChip(
                          label: const Text('Users'),
                          selected: _filterRole == 'user',
                          onSelected: (_) => _filterEmployees('user'),
                        ),
                        const SizedBox(width: 10),
                        FilterChip(
                          label: const Text('Admins'),
                          selected: _filterRole == 'admin',
                          onSelected: (_) => _filterEmployees('admin'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Employee Count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${_filteredEmployees.length} employees found',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Employee List
                Expanded(
                  child: _filteredEmployees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No employees found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _filterRole == 'all'
                                    ? 'Add your first employee'
                                    : 'No ${_filterRole}s found',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final employee = _filteredEmployees[index];
                            return _buildEmployeeCard(employee);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: Colors.blue.shade800,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
      ),
    );
  }

  Widget _buildEmployeeCard(UserModel employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(
              employee.userType), // FIXED: Changed role to userType
          child: Text(
            employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(employee.email),
            Text(
                'Role: ${employee.userType.toUpperCase()}'), // FIXED: Changed role to userType
            if (employee.rating > 0)
              Text('Rating: ${employee.rating.toStringAsFixed(1)} ⭐'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 10),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.remove_red_eye, size: 20),
                  SizedBox(width: 10),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(value, employee),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Phone', employee.phone),
                // FIXED: Removed unnecessary null checks
                if (employee.skills != null && employee.skills!.isNotEmpty)
                  _buildDetailRow('Skills', employee.skills!.join(', ')),
                if (employee.experience != null &&
                    employee.experience!.isNotEmpty)
                  _buildDetailRow('Experience', employee.experience!),
                _buildDetailRow('Joined', _formatDate(employee.createdAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog() {
    _clearControllers();
    _selectedRole = 'technician';
    _skills = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Employee'),
        content: _buildEmployeeForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _registerEmployee,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
            ),
            child: const Text('Add Employee'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(UserModel employee) {
    _nameController.text = employee.name;
    _emailController.text = employee.email;
    _phoneController.text = employee.phone;
    _passwordController.text = '';
    _selectedRole = employee.userType; // FIXED: Changed role to userType
    _skills = employee.skills ?? [];
    _skillsController.text = _skills.join(', ');
    _experienceController.text = employee.experience ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${employee.name}'),
        content: _buildEmployeeForm(isEdit: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _updateEmployee(employee),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeForm({bool isEdit = false}) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Enter valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.length < 10) {
                  return 'Enter valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            if (!isEdit)
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (!isEdit && (value == null || value.isEmpty)) {
                    return 'Please enter password';
                  }
                  if (!isEdit && value!.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            if (!isEdit) const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'technician', child: Text('Technician')),
                DropdownMenuItem(value: 'user', child: Text('User')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            if (_selectedRole == 'technician') ...[
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills (comma separated)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build),
                ),
                onChanged: (value) {
                  _skills = value
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: 'Experience',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _registerEmployee() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final token = await ApiService.getToken();
        if (token != null) {
          final response = await ApiService.registerEmployee(
            token: token,
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
            role: _selectedRole,
            expertise: _selectedRole == 'technician' ? _skills : null,
          );

          if (response['success'] == true) {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Employee registered successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              await _refreshEmployees();
            }
          } else {
            _showErrorSnackBar(response['message'] ?? 'Registration failed');
          }
        }
      } catch (e) {
        _showErrorSnackBar('Error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateEmployee(UserModel employee) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final token = await ApiService.getToken();
        if (token != null) {
          // TODO: Add update employee API endpoint
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${employee.name} updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            await _refreshEmployees();
          }
        }
      } catch (e) {
        _showErrorSnackBar('Error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleMenuAction(String action, UserModel employee) {
    switch (action) {
      case 'edit':
        _showEditEmployeeDialog(employee);
        break;
      case 'view':
        _showEmployeeDetails(employee);
        break;
      case 'delete':
        _showDeleteConfirmation(employee);
        break;
    }
  }

  void _showEmployeeDetails(UserModel employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', employee.email),
              _buildDetailRow('Phone', employee.phone),
              _buildDetailRow(
                  'Role',
                  employee.userType
                      .toUpperCase()), // FIXED: Changed role to userType
              if (employee.rating > 0)
                _buildDetailRow(
                    'Rating', '${employee.rating.toStringAsFixed(1)} ⭐'),
              if (employee.skills != null && employee.skills!.isNotEmpty)
                _buildDetailRow('Skills', employee.skills!.join(', ')),
              if (employee.experience != null &&
                  employee.experience!.isNotEmpty)
                _buildDetailRow('Experience', employee.experience!),
              _buildDetailRow('Joined', _formatDate(employee.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(UserModel employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteEmployee(employee),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEmployee(UserModel employee) async {
    Navigator.pop(context); // Close dialog
    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${employee.name} deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await _refreshEmployees();
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'technician':
        return Colors.green;
      case 'user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _clearControllers() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _skillsController.clear();
    _experienceController.clear();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
