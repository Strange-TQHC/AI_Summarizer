import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    documents = HiveService.getDocuments();
  }

  // Pure PDF Extraction Logic using Syncfusion
  Future<String?> _extractTextFromPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return null;

      final File file = File(result.files.single.path!);
      final List<int> bytes = await file.readAsBytes();

      // Load and Extract
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      String text = extractor.extractText();

      document.dispose(); // Always dispose to free memory
      return text.trim();
    } catch (e) {
      debugPrint("PDF Extraction Error: $e");
      return null;
    }
  }

  void handlePdfUpload() async {
    setState(() => _isLoading = true);

    final extractedText = await _extractTextFromPdf();

    if (extractedText != null && extractedText.isNotEmpty) {
      final doc = Document(
        id: const Uuid().v4(),
        content: extractedText,
        createdAt: DateTime.now(),
      );

      await HiveService.saveDocument(doc);

      setState(() {
        documents = HiveService.getDocuments();
        _isLoading = false;
      });

      _showSnackBar("PDF Extracted and Saved!");
    } else {
      setState(() => _isLoading = false);
      _showSnackBar("No text found or upload cancelled.");
    }
  }

  void handleTextSubmit() async {
    final text = _controller.text.trim();
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Text Summarizer")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Paste your text here...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : handleTextSubmit,
                    icon: const Icon(Icons.send),
                    label: const Text("Process Text"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : handlePdfUpload,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50),
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.picture_as_pdf, color: Colors.red),
                    label: const Text("Upload PDF", style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: documents.isEmpty
                  ? const Center(child: Text("No documents yet"))
                  : ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        doc.content.length > 80
                            ? "${doc.content.substring(0, 80)}..."
                            : doc.content,
                      ),
                      subtitle: Text(doc.createdAt.toString().split('.')[0]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}