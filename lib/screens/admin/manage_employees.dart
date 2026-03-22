import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import 'technician_detail_screen.dart';

class ManageEmployees extends StatefulWidget {
  final UserModel user;
  const ManageEmployees({Key? key, required this.user}) : super(key: key);

  @override
  State<ManageEmployees> createState() => _ManageEmployeesState();
}

class _ManageEmployeesState extends State<ManageEmployees> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _experienceController = TextEditingController();

  List<String> _selectedSkills = [];
  bool _isLoading = false;
  bool _isLoadingData = true;
  List<UserModel> _technicians = [];

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
    _loadTechnicians();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  // ✅ FIXED: Load technicians with proper type casting
  Future<void> _loadTechnicians() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.getAllTechnicians(token);
        if (response['success'] == true) {
          final List<dynamic> data = response['data'] ?? [];

          setState(() {
            _technicians = data
                .map((json) {
                  try {
                    return UserModel.fromJson(json as Map<String, dynamic>);
                  } catch (e) {
                    print('Error parsing technician: $e');
                    return null;
                  }
                })
                .whereType<UserModel>()
                .toList();
            _isLoadingData = false;
          });
        } else {
          setState(() {
            _isLoadingData = false;
          });
          _showError(response['message'] ?? 'Failed to load technicians');
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      print('Error loading technicians: $e');
      _showError('Network error. Please try again.');
    }
  }

  // ✅ FIXED: Register technician using registerEmployee method
  Future<void> _registerTechnician() async {
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
            role: 'technician',
            expertise: _selectedSkills.isNotEmpty ? _selectedSkills : null,
          );

          if (response['success'] == true) {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Technician registered successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadTechnicians();
            }
          } else {
            _showError(response['message'] ?? 'Registration failed');
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ✅ FIXED: Dialog with proper layout constraints
  void _showAddTechnicianDialog() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _experienceController.clear();
    _selectedSkills = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New Technician'),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
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
                      labelText: 'Email',
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
                      labelText: 'Phone Number',
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
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _experienceController,
                    decoration: const InputDecoration(
                      labelText: 'Experience (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select Skills:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  // ✅ FIXED: Container with fixed height for ListView
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: _availableSkills.map((skill) {
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _registerTechnician,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Technicians'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTechnicianDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTechnicians,
          ),
        ],
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _technicians.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No technicians found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _showAddTechnicianDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Technician'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _technicians.length,
                  itemBuilder: (context, index) {
                    final technician = _technicians[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TechnicianDetailScreen(
                                user: widget.user,
                                technician: technician,
                              ),
                            ),
                          ).then((_) => _loadTechnicians());
                        },
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
                        title: Text(
                          technician.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(technician.email),
                            Text(technician.phone),
                            if (technician.skills != null &&
                                technician.skills!.isNotEmpty)
                              Text(
                                'Skills: ${technician.skills!.take(3).join(', ')}${technician.skills!.length > 3 ? '...' : ''}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: technician.status == 'available'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            technician.status,
                            style: TextStyle(
                              color: technician.status == 'available'
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTechnicianDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
