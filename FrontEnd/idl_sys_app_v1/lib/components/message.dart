class Message {
  final String sender;
  final String content;
  final DateTime time;
  bool isRead;
  final String avatar;
  final String type;

  Message({
    required this.sender,
    required this.content,
    required this.time,
    required this.isRead,
    required this.avatar,
    required this.type,
  });
}
