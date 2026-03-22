import 'package:hive/hive.dart';
import '../models/chat.dart';
import '../models/message.dart';

class HiveService {
  static const String chatBoxName = "chatBox";

  static Future<void> init() async {
    await Hive.openBox(chatBoxName);
  }

  static Future<void> saveChat(Chat chat) async {
    final box = Hive.box(chatBoxName);

    await box.put(chat.id, {
      "title": chat.title,
      "document": chat.documentContent,
      "messages": chat.messages.map((m) => {
        "text": m.text,
        "isUser": m.isUser,
      }).toList(),
    });
  }

  static List<Chat> getChats() {
    final box = Hive.box(chatBoxName);

    return box.keys.map((key) {
      final data = box.get(key);

      return Chat(
        id: key,
        title: data["title"],
        documentContent: data["document"],
        messages: (data["messages"] as List)
            .map((m) => Message(
          text: m["text"],
          isUser: m["isUser"],
        ))
            .toList(),
      );
    }).toList();
  }

  static Future<void> deleteChat(String id) async {
    final box = Hive.box(chatBoxName);
    await box.delete(id);
  }
}