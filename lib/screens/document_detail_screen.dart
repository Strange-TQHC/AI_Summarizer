import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/ai_service.dart';

class DocumentDetailScreen extends StatefulWidget {
  final Document document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  String summary = "";
  bool isLoading = false;

  void handleSummarize() async {
    setState(() => isLoading = true);

    try {
      final result = await AIService.summarize(widget.document.content);

      setState(() {
        summary = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        summary = "Error generating summary";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : handleSummarize,
              child: const Text("Summarize"),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
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
