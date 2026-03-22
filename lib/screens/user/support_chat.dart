import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class UserSupportMessages extends StatefulWidget {
  final UserModel user;
  const UserSupportMessages({Key? key, required this.user}) : super(key: key);

  @override
  _UserSupportMessagesState createState() => _UserSupportMessagesState();
}

class _UserSupportMessagesState extends State<UserSupportMessages> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
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
      if (token == null) throw Exception('Not authenticated');
      final response = await ApiService.getMySupportMessages(token);
      if (response['success'] == true) {
        final rawData = response['data'];
        List<dynamic> messagesList = [];
        if (rawData is List)
          messagesList = rawData;
        else if (rawData is Map && rawData.containsKey('data'))
          messagesList = rawData['data'] as List? ?? [];
        setState(() => _messages =
            messagesList.map((m) => Map<String, dynamic>.from(m)).toList());
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        setState(() =>
            _errorMessage = response['message'] ?? 'Failed to load messages');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final message = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add({
        '_id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
        'message': message,
        'createdAt': DateTime.now().toIso8601String(),
        'reply': null,
      });
    });
    _scrollToBottom();

    try {
      final token = await ApiService.getToken();
      if (token == null) throw Exception('No token');
      final response =
          await ApiService.sendSupportMessage(token: token, message: message);
      if (response['success'] != true)
        throw Exception(response['message'] ?? 'Failed to send');
      await _loadMessages(); // refresh to get actual data
    } catch (e) {
      setState(() => _messages.removeLast());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Messages'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages)
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _messages.isEmpty
                        ? const Center(child: Text('No messages yet.'))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final hasReply = msg['reply'] != null;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                            BorderRadius.circular(12).copyWith(
                                          bottomRight: Radius.zero,
                                        ),
                                      ),
                                      child: Text(msg['message'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ),
                                  ),
                                  if (hasReply)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(12)
                                                  .copyWith(
                                            bottomLeft: Radius.zero,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text('Admin:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(msg['reply']!),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (index == _messages.length - 1)
                                    const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
