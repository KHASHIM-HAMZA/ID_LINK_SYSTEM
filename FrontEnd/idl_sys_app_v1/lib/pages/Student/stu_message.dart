import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:idl_sys_app_v1/pages/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StuMessages extends StatefulWidget {
  final String regNo;
  const StuMessages({super.key, required this.regNo});

  @override
  State<StuMessages> createState() => _StuMessagesState();
}

class _StuMessagesState extends State<StuMessages> {
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedCategory = 'All';
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse(
          '${AppConfig.baseUrl}/api/messages?regNumber=${widget.regNo}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _messages = data.map((msg) => Message.fromJson(msg)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/student/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'regNumber': widget.regNo,
          'content': _messageController.text,
          'type': 'student',
        }),
      );

      if (response.statusCode == 200) {
        _messageController.clear();
        _fetchMessages(); // Refresh messages
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message sent successfully'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMessages =
        _selectedCategory == 'All'
            ? _messages
            : _selectedCategory == 'From Admin'
            ? _messages.where((m) => m.type == 'admin').toList()
            : _messages.where((m) => m.type == 'student').toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCategories(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_hasError)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(height: 16),
                    const Text('Failed to load messages'),
                    TextButton(
                      onPressed: _fetchMessages,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredMessages.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No messages found',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchMessages,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredMessages.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                  itemBuilder:
                      (context, index) =>
                          _buildMessageCard(filteredMessages[index]),
                ),
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    const categories = ['All', 'From Admin', 'From Students'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children:
            categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: Colors.green.shade100,
                  labelStyle: TextStyle(
                    color:
                        _selectedCategory == category
                            ? Colors.green.shade800
                            : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms * categories.indexOf(category));
            }).toList(),
      ),
    );
  }

  Widget _buildMessageCard(Message message) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openMessageDetails(message),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: message.isRead ? Colors.white : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(message),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.sender,
                            style: TextStyle(
                              fontWeight:
                                  message.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(message.time),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message.content,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight:
                            message.isRead
                                ? FontWeight.normal
                                : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!message.isRead)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms * _messages.indexOf(message));
  }

  Widget _buildAvatar(Message message) {
    final colors = {
      'admin': Colors.green.shade100,
      'student': Colors.blue.shade100,
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors[message.type] ?? Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          message.type == 'admin'
              ? Icons.person_outline
              : Icons.school_outlined,
          color: Colors.grey.shade800,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          _isSending
              ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : IconButton(
                icon: Icon(Icons.send, color: Colors.green.shade700),
                onPressed: _sendMessage,
              ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (time.isAfter(today)) {
      return DateFormat('h:mm a').format(time);
    } else if (time.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }

  void _openMessageDetails(Message message) {
    setState(() {
      _messages[_messages.indexOf(message)] = message.copyWith(isRead: true);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildAvatar(message),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.sender,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatTime(message.time),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(message.content, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                if (message.type == 'admin')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        FocusScope.of(context).requestFocus(FocusNode());
                        Future.delayed(const Duration(milliseconds: 300), () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _messageController.text =
                              'Re: ${message.content.split('\n').first}...';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reply'),
                    ),
                  ),
              ],
            ),
          ),
    );
  }
}

class Message {
  final String sender;
  final String content;
  final DateTime time;
  bool isRead;
  final String type;

  Message({
    required this.sender,
    required this.content,
    required this.time,
    required this.isRead,
    required this.type,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'] ?? 'Admin',
      content: json['content'] ?? '',
      time: DateTime.parse(json['time']),
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? 'admin',
    );
  }

  Message copyWith({
    String? sender,
    String? content,
    DateTime? time,
    bool? isRead,
    String? type,
  }) {
    return Message(
      sender: sender ?? this.sender,
      content: content ?? this.content,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}
