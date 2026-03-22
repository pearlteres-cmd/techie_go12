import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/services/api_service.dart';

class AvailableTasks extends StatefulWidget {
  final UserModel user;

  const AvailableTasks({Key? key, required this.user}) : super(key: key);

  @override
  _AvailableTasksState createState() => _AvailableTasksState();
}

class _AvailableTasksState extends State<AvailableTasks> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.getTechnicianDashboard(token);
        if (response['success'] == true) {
          setState(() {
            _tasks = List<Map<String, dynamic>>.from(
                response['availableTasks'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptTask(Map<String, dynamic> task) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Accept Task'),
        content: Text('Are you sure you want to accept this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Add accept task API call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task accepted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadTasks();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Accept'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Tasks'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No available tasks',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check back later',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'] ?? 'Untitled',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              task['description'] ?? 'No description',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.category,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  task['category'] ?? 'General',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.priority_high,
                                    size: 16,
                                    color: _getPriorityColor(task['priority'])),
                                SizedBox(width: 4),
                                Text(
                                  task['priority'] ?? 'Medium',
                                  style: TextStyle(
                                      color:
                                          _getPriorityColor(task['priority'])),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    task['address'] ?? 'No address',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  _formatDate(task['preferredDate']),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _acceptTask(task),
                                icon: Icon(Icons.check),
                                label: Text('Accept Task'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'No date';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
