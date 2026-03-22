import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/services/api_service.dart';

class EditProfile extends StatefulWidget {
  final UserModel user;

  /// whether the form should start in editing mode (true) or just viewing (false).
  final bool startEditing;

  const EditProfile({Key? key, required this.user, this.startEditing = false})
      : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _expertiseController = TextEditingController();

  List<String> _expertise = [];
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _expertiseOptions = [
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
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phone;
    // initialize editing flag from parent
    _isEditing = widget.startEditing;
    // Load expertise from user model if available
    _expertise = ['Hardware Expert', 'Software Expert']; // Example
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _expertiseController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // Add your update profile API call here
        await Future.delayed(Duration(seconds: 2)); // Simulate API call

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.green.shade800,
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing && !_isLoading) ...[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nameController.text = widget.user.name;
                  _emailController.text = widget.user.email;
                  _phoneController.text = widget.user.phone;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _updateProfile,
            ),
          ],
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.green.shade100,
                          child: Text(
                            widget.user.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 50,
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_isEditing && !_isLoading)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade800,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        if (_isLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Technician Badge
                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Technician',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      enabled: _isEditing && !_isLoading,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      enabled: false, // Email cannot be changed
                    ),
                  ),
                  SizedBox(height: 16),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      enabled: _isEditing && !_isLoading,
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
                  SizedBox(height: 16),

                  // Expertise Section
                  if (!_isEditing) ...[
                    _buildExpertiseDisplay(),
                  ] else ...[
                    Text(
                      'Select Expertise:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 300,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _expertiseOptions.length,
                        itemBuilder: (context, index) {
                          final expertise = _expertiseOptions[index];
                          final isSelected = _expertise.contains(expertise);
                          return FilterChip(
                            label: Text(
                              expertise,
                              style: TextStyle(fontSize: 12),
                            ),
                            selected: isSelected,
                            onSelected: _isLoading
                                ? null
                                : (selected) {
                                    setState(() {
                                      if (selected) {
                                        _expertise.add(expertise);
                                      } else {
                                        _expertise.remove(expertise);
                                      }
                                    });
                                  },
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: 16),

                  // Change Password Button
                  if (_isEditing && !_isLoading)
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Change password feature coming soon'),
                          ),
                        );
                      },
                      icon: Icon(Icons.lock),
                      label: Text('Change Password'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 45),
                      ),
                    ),

                  SizedBox(height: 20),

                  // Edit Button (for non-editing mode)
                  if (!_isEditing && !_isLoading)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                        ),
                        child: Text('Edit Profile'),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Full screen loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.green.shade800,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Updating profile...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpertiseDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expertise:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _expertise
              .map((exp) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      exp,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
