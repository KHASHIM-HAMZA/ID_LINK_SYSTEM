import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:idl_sys_app_v1/pages/Admin/adminMassage.dart';
import 'package:idl_sys_app_v1/pages/config.dart';
import 'admin_message.dart';

class AdminMessagesPage extends StatefulWidget {
  const AdminMessagesPage({super.key});

  @override
  State<AdminMessagesPage> createState() => _AdminMessagesPageState();
}

class _AdminMessagesPageState extends State<AdminMessagesPage> {
  List<AdminMessage> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/admin/messages/incoming'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          messages = data.map((json) => AdminMessage.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _replyToMessage(String regNo, int index) {
    TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Reply to $regNo"),
            content: TextField(
              controller: replyController,
              decoration: const InputDecoration(hintText: 'Type your reply...'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    final response = await http.post(
                      Uri.parse('${AppConfig.baseUrl}/api/admin/reply'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'regNo': regNo,
                        'reply': replyController.text,
                      }),
                    );
                    if (response.statusCode == 200) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ Reply sent")),
                      );
                    } else {
                      throw Exception("Failed to send reply");
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
                  }
                },
                child: const Text("Send"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
    );
  }

  Widget _buildMessageTile(AdminMessage msg, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        title: Text("From: ${msg.regNumber}"),
        subtitle: Text(msg.content),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!msg.isRead)
              const CircleAvatar(radius: 5, backgroundColor: Colors.red),
            IconButton(
              icon: const Icon(Icons.reply),
              onPressed: () => _replyToMessage(msg.regNumber, index),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Messages"),
        backgroundColor: Colors.green,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : messages.isEmpty
              ? const Center(child: Text("No messages received."))
              : ListView.builder(
                itemCount: messages.length,
                itemBuilder:
                    (context, index) =>
                        _buildMessageTile(messages[index], index),
              ),
    );
  }
}
