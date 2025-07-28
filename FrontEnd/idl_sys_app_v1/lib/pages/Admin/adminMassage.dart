class AdminMessage {
  final int id;
  final String regNumber;
  final String content;
  final bool isRead;

  AdminMessage({
    required this.id,
    required this.regNumber,
    required this.content,
    required this.isRead,
  });

  factory AdminMessage.fromJson(Map<String, dynamic> json) {
    return AdminMessage(
      id: json['id'] ?? 0,
      regNumber: json['regNumber'] ?? 'Unknown',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }
}
