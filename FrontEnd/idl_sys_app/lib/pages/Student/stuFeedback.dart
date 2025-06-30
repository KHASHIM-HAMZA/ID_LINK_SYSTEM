import 'package:flutter/material.dart';

class StufeedbackPage extends StatefulWidget {
  const StufeedbackPage({super.key});

  @override
  State<StufeedbackPage> createState() => _StufeedbackPageState();
}

class _StufeedbackPageState extends State<StufeedbackPage> {
  final TextEditingController _messageController = TextEditingController();
  String _selectedType = "General enquiry";

  final List<String> _feedbackTypes = [
    "General enquiry",
    "Missing ID",
    "Photo issue",
    "Delay in processing",
    "Other",
  ];

  void _sendFeedback() {
    String message = _messageController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your message")),
      );
      return;
    }

    // TODO: Send to backend using http.post
    print("Type: $_selectedType\nMessage: $message");

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ Feedback sent")));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Feedback", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.send), onPressed: _sendFeedback),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.grey,
                border: OutlineInputBorder(),
              ),
              items:
                  _feedbackTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText:
                      "Let us know about a broken feature or leave any other comment",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Color.fromARGB(255, 29, 28, 28),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
