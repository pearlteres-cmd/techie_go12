import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class AdminSupportMessages extends StatefulWidget {
  final UserModel user;
  const AdminSupportMessages({Key? key, required this.user}) : super(key: key);

  @override
  _AdminSupportMessagesState createState() => _AdminSupportMessagesState();
}

class _AdminSupportMessagesState extends State<AdminSupportMessages> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Not authenticated. Please login again.';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getAllSupportMessages(token);
      print('Admin support messages response: $response');

      if (response['success'] == true) {
        final rawData = response['data'];
        List<dynamic> messagesList = [];

        if (rawData is List) {
          messagesList = rawData;
        } else if (rawData is Map && rawData.containsKey('data')) {
          messagesList = (rawData['data'] as List?) ?? [];
        }

        setState(() {
          _messages =
              messagesList.map((m) => Map<String, dynamic>.from(m)).toList();
        });

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        setState(() {
          _errorMessage =
              (response['message'] as String?) ?? 'Failed to load messages';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _replyToMessage(Map<String, dynamic> message) async {
    final replyController = TextEditingController();
    final messageId = message['_id'] ?? message['id'];

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reply to ${message['userName'] ?? 'User'}'),
        content: TextField(
          controller: replyController,
          decoration: InputDecoration(
            hintText: 'Type your reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Send'),
          ),
        ],
      ),
    );

    if (result != true || replyController.text.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('No token');

      final response = await ApiService.replyToSupportMessage(
        token: token,
        messageId: messageId,
        reply: replyController.text,
      );

      if (mounted) Navigator.pop(context);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reply sent'), backgroundColor: Colors.green),
        );
        _loadMessages();
      } else {
        throw Exception((response['message'] as String?) ?? 'Failed to send');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Messages'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Admin's own contact info header (optional)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(widget.user.email),
                if (widget.user.phone.isNotEmpty == true) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.phone, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(widget.user.phone),
                ],
              ],
            ),
          ),
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadMessages,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.message,
                                    size: 80, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  'No messages yet.',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final unread = msg['isRead'] == false;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: unread
                                      ? Colors.blue.shade50
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: unread
                                          ? Colors.blue.shade200
                                          : Colors.grey.shade300),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: unread
                                                ? Colors.blue.shade100
                                                : Colors.grey.shade200,
                                            child: Text(
                                              (msg['userName']?[0] ?? '?')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: unread
                                                    ? Colors.blue
                                                    : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  msg['userName'] ??
                                                      'Unknown User',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: unread
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                                Text(
                                                  msg['userEmail'] ??
                                                      'No Email',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600]),
                                                ),
                                                if (msg['userPhone']
                                                        ?.isNotEmpty ==
                                                    true)
                                                  Row(
                                                    children: [
                                                      Icon(Icons.phone,
                                                          size: 12,
                                                          color: Colors.grey),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        msg['userPhone'],
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey[600]),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (unread)
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  shape: BoxShape.circle),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          msg['message'] ?? 'No content',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[800]),
                                        ),
                                      ),
                                      if (msg['reply'] != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Admin Reply:',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(msg['reply'],
                                                    style: const TextStyle(
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDate(msg['createdAt']),
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey),
                                          ),
                                          TextButton.icon(
                                            onPressed: () =>
                                                _replyToMessage(msg),
                                            icon: const Icon(Icons.reply,
                                                size: 16),
                                            label: const Text('Reply'),
                                            style: TextButton.styleFrom(
                                                foregroundColor:
                                                    Colors.blue.shade800),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return dateStr;
    }
  }
}
