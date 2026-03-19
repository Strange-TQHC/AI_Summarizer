import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../services/hive_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Document> documents = [];

  void handleTextSubmit() async {
    final text = _controller.text;

    if (text.isEmpty) return;

    final doc = Document(
      id: const Uuid().v4(),
      content: text,
      createdAt: DateTime.now(),
    );

    await HiveService.saveDocument(doc);

    setState(() {
      documents = HiveService.getDocuments();
      _controller.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    documents = HiveService.getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Text Summarizer"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Paste your text here...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: handleTextSubmit,
              child: const Text("Process Text"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: documents.isEmpty
                  ? const Center(child: Text("No documents yet"))
                  : ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        doc.content.length > 50
                            ? "${doc.content.substring(0, 50)}..."
                            : doc.content,
                      ),
                      subtitle: Text(doc.createdAt.toString()),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}