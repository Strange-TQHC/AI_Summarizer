import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static Future<String?> pickAndExtractText() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return null;

    final filePath = result.files.single.path;
    if (filePath == null) return null;

    try {
      final bytes = await File(filePath).readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      final textExtractor = PdfTextExtractor(document);

      final text = textExtractor.extractText();

      document.dispose();

      return text;
    } catch (e) {
      print("PDF Error: $e");
      return null;
    }
  }
}