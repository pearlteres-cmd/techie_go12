import 'package:flutter/material.dart';
import 'package:techie_go/services/api_service.dart';

class AdminNotifications extends StatefulWidget {
  @override
  _AdminNotificationsState createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends State<AdminNotifications> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final response = await ApiService.getNotifications(token);
        if (response['success'] == true) {
          setState(() {
            _notifications =
                List<Map<String, dynamic>>.from(response['data'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        // FIXED: Use named parameters
        await ApiService.markNotificationAsRead(
          token: token,
          notificationId: notificationId,
        );
        _loadNotifications(); // Refresh the list
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No notifications',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final bool isUnread = notification['isRead'] == false;

                    return GestureDetector(
                      onTap: () {
                        if (isUnread) {
                          _markAsRead(
                              notification['_id'] ?? notification['id']);
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isUnread ? Colors.blue.shade50 : Colors.white,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notification['type'] == 'new_user'
                                ? Colors.green
                                : Colors.blue,
                            child: Icon(
                              notification['type'] == 'new_user'
                                  ? Icons.person_add
                                  : Icons.info,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            notification['message'] ?? 'New notification',
                            style: TextStyle(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            _formatDate(notification['timestamp']),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: isUnread
                              ? Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : const Icon(Icons.check,
                                  color: Colors.green, size: 16),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Just now';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
