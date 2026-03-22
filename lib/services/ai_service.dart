import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String apiKey = "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";

  static Future<String> summarize(String text) async {
    final url = Uri.parse("https://openrouter.ai/api/v1/chat/completions");

    final trimmed = text.length > 2000 ? text.substring(0, 2000) : text;

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "mistralai/mistral-7b-instruct",
        "messages": [
          {
            "role": "user",
            "content": "Summarize this in 5 bullet points:\n$trimmed"
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      return "Error: ${response.statusCode}";
    }
  }
}