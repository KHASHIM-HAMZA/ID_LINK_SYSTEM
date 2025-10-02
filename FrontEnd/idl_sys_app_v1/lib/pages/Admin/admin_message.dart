import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idl_sys_app_v1/pages/Admin/adminMassage.dart';
import 'package:idl_sys_app_v1/pages/config.dart';
import 'admin_message.dart';
import 'package:intl/intl.dart';

class AdminMessagesPage extends StatefulWidget {
  const AdminMessagesPage({super.key});

  @override
  State<AdminMessagesPage> createState() => _AdminMessagesPageState();
}

class _AdminMessagesPageState extends State<AdminMessagesPage> {
  List<AdminMessage> _messages = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      // Simulated API call - replace with actual implementation
      await Future.delayed(const Duration(seconds: 1));

      // Example JSON data - replace with your API response
      final mockData = [
        {
          'id': 1,
          'regNumber': 'BITAM/10/22/001/TZ',
          'email': 'student1@suza.ac.tz',
          'content': 'Need help with course registration',
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
          'isRead': false,
        },
        {
          'id': 2,
          'regNumber': 'BSE/10/22/015/TZ',
          'email': 'student2@suza.ac.tz',
          'content': 'Question about exam schedule',
          'timestamp':
              DateTime.now()
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
          'isRead': true,
        },
      ];

      setState(() {
        _messages =
            mockData.map((json) => AdminMessage.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load messages: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<AdminMessage> get _filteredMessages {
    if (_searchQuery.isEmpty) return _messages;
    final query = _searchQuery.toLowerCase();
    return _messages.where((msg) {
      return msg.regNumber.toLowerCase().contains(query) ||
          msg.email.toLowerCase().contains(query) ||
          msg.content.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildMessageItem(AdminMessage message) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.person, color: Colors.green[800]),
        ),
        title: Text(
          message.regNumber,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.email),
            const SizedBox(height: 4),
            Text(message.content),
            const SizedBox(height: 4),
            Text(
              message.formattedTime,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing:
            !message.isRead
                ? const Icon(Icons.mark_email_unread, color: Colors.red)
                : const Icon(Icons.mark_email_read, color: Colors.green),
        onTap: () => _showMessageDetails(message),
      ),
    );
  }

  void _showMessageDetails(AdminMessage message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Message from ${message.regNumber}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Email: ${message.email}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Message:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(message.content),
                  const SizedBox(height: 16),
                  Text('Sent: ${message.formattedTime}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _replyToMessage(message);
                },
                child: const Text(
                  'Reply',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _replyToMessage(AdminMessage message) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reply to ${message.regNumber}'),
            content: TextField(
              controller: replyController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Type your reply here...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                ),
                onPressed: () {
                  if (replyController.text.isNotEmpty) {
                    // Implement reply sending logic here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reply sent successfully')),
                    );
                  }
                },
                child: const Text(
                  'Send',
                  style: TextStyle(color: Colors.white),
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
        title: const Text('Student Messages'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
            tooltip: 'Refresh messages',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredMessages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No messages available'
                                : 'No messages found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadMessages,
                      child: ListView.builder(
                        itemCount: _filteredMessages.length,
                        itemBuilder:
                            (context, index) =>
                                _buildMessageItem(_filteredMessages[index]),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
