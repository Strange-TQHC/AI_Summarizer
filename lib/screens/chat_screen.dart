import 'package:flutter/material.dart';
import '../models/document.dart';
import '../models/message.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  final Document document;

  const ChatScreen({super.key, required this.document});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Message> messages = [];
  bool isLoading = false;

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(Message(text: text, isUser: true));
      isLoading = true;
      _controller.clear();
    });

    // LIMIT CONTEXT (IMPORTANT)
    final contextText = widget.document.content.length > 1500
        ? widget.document.content.substring(0, 1500)
        : widget.document.content;

    final prompt = """
Answer the question based on this document:

$contextText

Question:
$text
""";

    final response = await AIService.summarize(prompt);

    setState(() {
      messages.add(Message(text: response, isUser: false));
      isLoading = false;
    });
  }

  Widget buildMessage(Message msg) {
    return Align(
      alignment:
      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.indigo : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),

          // 🔥 CHAT INPUT BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // later: PDF upload
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}