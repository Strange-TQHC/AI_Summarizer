import 'package:flutter/material.dart';
import '../models/document.dart';

class DocumentDetailScreen extends StatefulWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  String summary = "";
  bool isLoading = false;

  // Dummy Summarizer
  String generateSummary(String text) {
    final words = text.split(" ");

    if (words.length <= 50) return text;

    // Simple logic: take first 50 words
    return words.take(50).join(" ") + "...";
  }

  void handleSummarize() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1)); // simulate AI delay

    final result = generateSummary(widget.document.content);

    setState(() {
      summary = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : handleSummarize,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Summarize"),
            ),
            const SizedBox(height: 16),

            if (summary.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(summary),
              ),

            const SizedBox(height: 16),

            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                child: Text(widget.document.content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}