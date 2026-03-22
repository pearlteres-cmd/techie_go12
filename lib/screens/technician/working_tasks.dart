import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/services/api_service.dart';
import 'package:techie_go/screens/technician/view_user_profile.dart';

class WorkingTasks extends StatefulWidget {
  final UserModel user;

  const WorkingTasks({Key? key, required this.user}) : super(key: key);

  @override
  _WorkingTasksState createState() => _WorkingTasksState();
}

class _WorkingTasksState extends State<WorkingTasks> {
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
            _tasks =
                List<Map<String, dynamic>>.from(response['workingTasks'] ?? []);
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

  Future<void> _updateProgress(
      Map<String, dynamic> task, double progress) async {
    // Update task progress
    setState(() {
      task['progress'] = progress;
    });
  }

  Future<void> _markAsCompleted(Map<String, dynamic> task) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Complete Task'),
        content: Text('Are you sure you want to mark this task as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Add complete task API call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task marked as completed'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadTasks();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _viewUserProfile(Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewUserProfile(
          userId: task['userId'],
          taskId: task['_id'] ?? task['id'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Working Tasks'),
        backgroundColor: Colors.purple.shade800,
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
                      Icon(Icons.work_off, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No working tasks',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
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
                            // Task Header
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task['title'] ?? 'Untitled',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'WORKING',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // User Info (Clickable)
                            GestureDetector(
                              onTap: () => _viewUserProfile(task),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.blue.shade100,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task['userName'] ?? 'Unknown User',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Tap to view profile',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward,
                                        color: Colors.blue, size: 16),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),

                            // Progress Bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Progress: ${(task['progress'] ?? 0).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: (task['progress'] ?? 0) / 100,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.purple),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value:
                                            (task['progress'] ?? 0).toDouble(),
                                        min: 0,
                                        max: 100,
                                        divisions: 10,
                                        onChanged: (value) {
                                          _updateProgress(task, value);
                                        },
                                      ),
                                    ),
                                    Text('${(task['progress'] ?? 0).toInt()}%'),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _viewUserProfile(task),
                                    icon: Icon(Icons.person),
                                    label: Text('View User'),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _markAsCompleted(task),
                                    icon: Icon(Icons.check_circle),
                                    label: Text('Complete'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
