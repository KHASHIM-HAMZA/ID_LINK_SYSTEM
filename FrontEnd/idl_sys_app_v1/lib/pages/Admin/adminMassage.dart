import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminMessage {
  final int id;
  final String regNumber;
  final String email;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  AdminMessage({
    required this.id,
    required this.regNumber,
    required this.email,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  String get formattedTime =>
      DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp);

  factory AdminMessage.fromJson(Map<String, dynamic> json) {
    try {
      return AdminMessage(
        id: json['id'] as int? ?? 0,
        regNumber: json['regNumber'] as String? ?? 'Unknown',
        email: json['email'] as String? ?? 'unknown@email.com',
        content: json['content'] as String? ?? '',
        timestamp:
            json['timestamp'] != null
                ? DateTime.parse(json['timestamp'] as String)
                : DateTime.now(),
        isRead: json['isRead'] as bool? ?? false,
      );
    } catch (e) {
      // Fallback constructor if parsing fails
      return AdminMessage(
        id: 0,
        regNumber: 'Error',
        email: 'error@email.com',
        content: 'Failed to parse message',
        timestamp: DateTime.now(),
        isRead: false,
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'regNumber': regNumber,
    'email': email,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };
}
