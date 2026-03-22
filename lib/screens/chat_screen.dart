import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../services/hive_service.dart';
import '../services/pdf_service.dart';
import 'chat_list_screen.dart';

class ChatScreen extends StatefulWidget {
  final Chat? chat;

  const ChatScreen({super.key, this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  List<Message> messages = [];
  bool isLoading = false;

  String? currentChatId;
  String documentContent = "";

  @override
  void initState() {
    super.initState();

    if (widget.chat != null) {
      messages = widget.chat!.messages;
      documentContent = widget.chat!.documentContent;
      currentChatId = widget.chat!.id;
    }
  }

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(Message(text: text, isUser: true));
      isLoading = true;
      _controller.clear();
    });

    final contextText =
    documentContent.isNotEmpty ? documentContent : "No document";

    final prompt = """
$contextText

Question:
$text
""";

    final response = await AIService.summarize(prompt);

    setState(() {
      messages.add(Message(text: response, isUser: false));
      isLoading = false;
    });

    final chat = Chat(
      id: currentChatId ?? DateTime.now().toString(),
      title: messages.first.text.length > 30
          ? messages.first.text.substring(0, 30)
          : messages.first.text,
      documentContent: documentContent,
      messages: messages,
    );

    currentChatId = chat.id;

    await HiveService.saveChat(chat);
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

  Future<void> handlePdfUpload() async {
    final extractedText = await PdfService.pickAndExtractText();

    if (extractedText != null) {
      setState(() {
        documentContent = extractedText;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF loaded into chat")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatListScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) => buildMessage(messages[i]),
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: handlePdfUpload,
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