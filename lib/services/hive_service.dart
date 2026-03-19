import 'package:hive_flutter/hive_flutter.dart';
import '../models/document.dart';

class HiveService {
  static const String boxName = "documentsBox";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Future<void> saveDocument(Document doc) async {
    final box = Hive.box(boxName);
    await box.put(doc.id, {
      "content": doc.content,
      "createdAt": doc.createdAt.toIso8601String(),
    });
  }

  static List<Document> getDocuments() {
    final box = Hive.box(boxName);

    return box.keys.map((key) {
      final data = box.get(key);
      return Document(
        id: key,
        content: data["content"],
        createdAt: DateTime.parse(data["createdAt"]),
      );
    }).toList();
  }
}