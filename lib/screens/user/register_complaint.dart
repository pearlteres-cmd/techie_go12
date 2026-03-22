import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/services/api_service.dart';

class RegisterComplaint extends StatefulWidget {
  final UserModel user;

  const RegisterComplaint({Key? key, required this.user}) : super(key: key);

  @override
  _RegisterComplaintState createState() => _RegisterComplaintState();
}

class _RegisterComplaintState extends State<RegisterComplaint> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _peripheralDetailsController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();

  String? _selectedComplaintType;
  String? _selectedPeripheralType;
  String? _selectedPriority;
  String? _selectedTimeSlot;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Position? _currentLocation;

  bool _isLoading = false;
  bool _isLocationLoading = false;
  bool _useCurrentLocation = true;

  // Complaint Types
  final List<String> _complaintTypes = [
    'Hardware',
    'Software',
    'Computer Peripherals',
    'Network',
    'Mobile',
    'Printer',
    'Other'
  ];

  // Peripheral Types
  final List<String> _peripheralTypes = [
    'Monitor',
    'Keyboard',
    'Mouse',
    'Printer',
    'Scanner',
    'Speaker',
    'Webcam',
    'External Drive',
    'Other'
  ];

  // Priority Levels
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  // Time Slots
  final List<String> _timeSlots = [
    'Morning (9AM-12PM)',
    'Afternoon (12PM-3PM)',
    'Evening (3PM-6PM)',
    'Night (6PM-9PM)'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _peripheralDetailsController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled. Please enable them.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = position;
        if (_useCurrentLocation) {
          _updateAddressFromLocation(position);
        }
      });
    } catch (e) {
      _showError('Error getting location: $e');
    } finally {
      setState(() => _isLocationLoading = false);
    }
  }

  void _updateAddressFromLocation(Position position) {
    _addressController.text =
        'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
  }

  String _generateOTP() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedComplaintType == null) {
      _showError('Please select complaint type');
      return;
    }

    if (_selectedComplaintType == 'Computer Peripherals' &&
        _selectedPeripheralType == null) {
      _showError('Please select peripheral type');
      return;
    }

    if (_selectedDate == null) {
      _showError('Please select preferred date');
      return;
    }

    if (_selectedTime == null) {
      _showError('Please select preferred time');
      return;
    }

    if (_selectedTimeSlot == null) {
      _showError('Please select preferred time slot');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await ApiService.getToken();
      print('🔑 Token: $token');

      if (token == null) {
        _showError('Not authenticated. Please login again.');
        setState(() => _isLoading = false);
        return;
      }

      String generatedOTP = _generateOTP();
      print('🔑 GENERATED OTP: $generatedOTP');

      String formattedTime =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      print('📤 Registering complaint with:');
      print('   Title: ${_titleController.text}');
      print('   Type: $_selectedComplaintType');
      print('   Priority: ${_selectedPriority ?? 'Medium'}');
      print('   Date: $_selectedDate');
      print('   Time: $formattedTime');
      print('   Slot: $_selectedTimeSlot');

      // Register complaint via API
      final response = await ApiService.registerComplaint(
        token: token,
        title: _titleController.text,
        description: _selectedComplaintType == 'Computer Peripherals'
            ? _peripheralDetailsController.text
            : _descriptionController.text,
        complaintType: _selectedComplaintType!,
        peripheralType: _selectedPeripheralType,
        priority: _selectedPriority ?? 'Medium',
        address: _addressController.text,
        landmark: _landmarkController.text.isNotEmpty
            ? _landmarkController.text
            : null,
        preferredDate: _selectedDate!,
        preferredTime: formattedTime,
        preferredTimeSlot: _selectedTimeSlot!,
        location: _currentLocation != null
            ? {
                'lat': _currentLocation!.latitude,
                'lng': _currentLocation!.longitude,
              }
            : null,
      );

      print('📥 Response: $response');

      if (response['success'] == true) {
        print('✅ Complaint registered successfully');

        if (mounted) {
          _showSuccessDialog(generatedOTP);
        }
      } else {
        print('❌ Registration failed: ${response['message']}');

        // Show more specific error message
        String errorMessage =
            response['message'] ?? 'Failed to register complaint';

        // Check if it's a network error
        if (errorMessage.contains('Network error') ||
            errorMessage.contains('Socket')) {
          errorMessage = 'Network error. Please check your connection.';
        }

        _showError(errorMessage);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Submit complaint error: $e');
      _showError('Error: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String otp) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Complaint Registered!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    '🔑 Your OTP for Technician:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    otp,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share this OTP with the technician',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                  ),
                  Text(
                    'when they arrive for service',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'GO TO DASHBOARD',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
        title: const Text('Register Complaint'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child:
                                Icon(Icons.person, color: Colors.blue.shade800),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Customer Information',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  widget.user.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Complaint Type
                  const Text(
                    'Complaint Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: _complaintTypes.map((type) {
                        return RadioListTile<String>(
                          title: Text(type),
                          value: type,
                          groupValue: _selectedComplaintType,
                          onChanged: (value) {
                            setState(() {
                              _selectedComplaintType = value;
                              _selectedPeripheralType = null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Peripheral Type
                  if (_selectedComplaintType == 'Computer Peripherals') ...[
                    const Text(
                      'Peripheral Type',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: _peripheralTypes.map((type) {
                          return RadioListTile<String>(
                            title: Text(type),
                            value: type,
                            groupValue: _selectedPeripheralType,
                            onChanged: (value) {
                              setState(() => _selectedPeripheralType = value);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _peripheralDetailsController,
                      decoration: InputDecoration(
                        labelText: 'Peripheral Details',
                        hintText: 'Enter model, issue details, etc.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.info_outline),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter peripheral details';
                        }
                        return null;
                      },
                    ),
                  ],

                  // Description
                  if (_selectedComplaintType != null &&
                      _selectedComplaintType != 'Computer Peripherals') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'What happened?',
                        hintText: 'Describe the issue in detail...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe the issue';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Complaint Title',
                      hintText: 'Brief title for your complaint',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter complaint title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Priority Selection
                  const Text(
                    'Priority Level',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: _priorities.map((priority) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedPriority = priority);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedPriority == priority
                                    ? _getPriorityColor(priority)
                                        .withOpacity(0.2)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _getPriorityIcon(priority),
                                    color: _getPriorityColor(priority),
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    priority,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getPriorityColor(priority),
                                      fontWeight: _selectedPriority == priority
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location Section
                  const Text(
                    'Service Location',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Use Current Location',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Switch(
                                value: _useCurrentLocation,
                                onChanged: (value) {
                                  setState(() {
                                    _useCurrentLocation = value;
                                    if (value && _currentLocation != null) {
                                      _updateAddressFromLocation(
                                          _currentLocation!);
                                    } else {
                                      _addressController.clear();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_isLocationLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          if (!_useCurrentLocation ||
                              _currentLocation == null) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Full Address',
                                hintText: 'Enter your complete address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.location_on),
                              ),
                              maxLines: 2,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter address';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _landmarkController,
                            decoration: InputDecoration(
                              labelText: 'Landmark (Optional)',
                              hintText: 'Nearby landmark',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.flag),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Schedule Section
                  const Text(
                    'Preferred Schedule',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.blue.shade800,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              _selectedDate == null
                                  ? 'Select Preferred Date'
                                  : 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            ),
                            trailing: TextButton(
                              onPressed: _selectDate,
                              child: const Text('Choose Date'),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(
                                Icons.access_time,
                                color: Colors.blue.shade800,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              _selectedTime == null
                                  ? 'Select Preferred Time'
                                  : 'Time: ${_formatTimeOfDay(_selectedTime!)}',
                            ),
                            trailing: TextButton(
                              onPressed: _selectTime,
                              child: const Text('Choose Time'),
                            ),
                          ),
                          const Divider(),
                          const Text(
                            'Preferred Time Slot',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _timeSlots.length,
                              itemBuilder: (context, index) {
                                final slot = _timeSlots[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedTimeSlot = slot);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedTimeSlot == slot
                                          ? Colors.blue.shade50
                                          : Colors.grey.shade50,
                                      border: Border.all(
                                        color: _selectedTimeSlot == slot
                                            ? Colors.blue.shade800
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        slot,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: _selectedTimeSlot == slot
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _selectedTimeSlot == slot
                                              ? Colors.blue.shade800
                                              : Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OTP Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade800),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OTP will be generated automatically',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Admin will be notified of your complaint',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Submit Complaint',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
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
}
