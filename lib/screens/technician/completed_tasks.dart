import 'package:flutter/material.dart';
import 'package:techie_go/models/user_model.dart';
import 'package:techie_go/services/api_service.dart';
import 'package:techie_go/screens/technician/view_user_profile.dart';

class CompletedTasks extends StatefulWidget {
  final UserModel user;

  const CompletedTasks({Key? key, required this.user}) : super(key: key);

  @override
  _CompletedTasksState createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
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
                response['completedTasks'] ?? []);
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
        title: Text('Completed Tasks'),
        backgroundColor: Colors.green.shade800,
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
                      Icon(Icons.check_circle, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No completed tasks',
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
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'COMPLETED',
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
                                            'Completed on: ${_formatDate(task['completedAt'])}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
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
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoChip(
                                  Icons.access_time,
                                  'Duration',
                                  task['duration'] ?? '2 hours',
                                ),
                                _buildInfoChip(
                                  Icons.currency_rupee,
                                  'Amount',
                                  '₹${task['amount'] ?? '0'}',
                                ),
                                _buildInfoChip(
                                  Icons.star,
                                  'Rating',
                                  task['rating'] ?? '5.0',
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

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
