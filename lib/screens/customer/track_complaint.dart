// lib/screens/customer/track_complaint.dart
import 'package:flutter/material.dart';

class TrackComplaint extends StatefulWidget {
  const TrackComplaint({super.key});

  @override
  State<TrackComplaint> createState() => _TrackComplaintState();
}

class _TrackComplaintState extends State<TrackComplaint> {
  final _complaintIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Complaint'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Search Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Enter Complaint ID',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your complaint ID to track its status',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _complaintIdController,
                      decoration: const InputDecoration(
                        labelText: 'Complaint ID',
                        prefixIcon: Icon(Icons.search),
                        hintText: 'e.g., TC2025001',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _trackComplaint,
                      child: const Text('Track Complaint'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Status Timeline
            const Text(
              'Complaint Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatusTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statusSteps = [
      {
        'title': 'Registered',
        'subtitle': '2025-01-15 10:30 AM',
        'completed': true
      },
      {
        'title': 'Under Review',
        'subtitle': '2025-01-15 11:45 AM',
        'completed': true
      },
      {
        'title': 'Technician Assigned',
        'subtitle': 'Alex Johnson',
        'completed': true
      },
      {
        'title': 'In Progress',
        'subtitle': 'Diagnosis started',
        'completed': true
      },
      {
        'title': 'Parts Ordered',
        'subtitle': 'Waiting for delivery',
        'completed': false
      },
      {
        'title': 'Resolved',
        'subtitle': 'Estimated: 2025-01-18',
        'completed': false
      },
    ];

    return Column(
      children: List.generate(statusSteps.length, (index) {
        final step = statusSteps[index];
        final isCompleted = step['completed'] as bool;
        final isLast = index == statusSteps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF06D6A0)
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: isCompleted
                        ? const Color(0xFF06D6A0)
                        : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Step details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['subtitle'] as String,
                      style: TextStyle(
                        color: isCompleted ? Colors.grey : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _trackComplaint() {
    if (_complaintIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complaint ID'),
          backgroundColor: Color(0xFFEF476F),
        ),
      );
      return;
    }

    // TODO: Implement actual tracking logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tracking complaint...'),
        backgroundColor: Color(0xFF4CC9F0),
      ),
    );
  }

  @override
  void dispose() {
    _complaintIdController.dispose();
    super.dispose();
  }
}
