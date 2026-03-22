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
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = [];
  bool isLoading = false;

  String? currentChatId;
  String documentContent = "";

  @override
  void initState() {
    super.initState();

    if (widget.chat != null) {
      messages = List.from(widget.chat!.messages);
      documentContent = widget.chat!.documentContent;
      currentChatId = widget.chat!.id;
    }
  }

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(Message(
        text: text,
        isUser: true,
        time: DateTime.now(),
      ));
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
      messages.add(Message(
        text: response,
        isUser: false,
        time: DateTime.now(),
      ));
      isLoading = false;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.indigo : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 14,
                color: msg.isUser ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
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
        title: const Text("AI Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "New Chat",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatScreen(),
                ),
              );
            },
          ),
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
          if (messages.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "Start a conversation\nor upload a PDF",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) => buildMessage(messages[i]),
              controller: _scrollController,
            ),
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "AI is typing...",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                )
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: handlePdfUpload,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: "Ask anything...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isLoading ? null : sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}