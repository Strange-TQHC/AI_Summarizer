import 'message.dart';

class Chat {
  final String id;
  final String title;
  final String documentContent;
  final List<Message> messages;

  Chat({
    required this.id,
    required this.title,
    required this.documentContent,
    required this.messages,
  });
}