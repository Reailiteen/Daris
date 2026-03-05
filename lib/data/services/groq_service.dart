import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/study_question.dart';

const String _kGroqModel = 'llama-3.3-70b-versatile';
const String _kGroqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';

class GroqService extends GetxService {
  final _uuid = const Uuid();

  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  Future<List<StudyQuestion>> generateQuestions(
    String subject, {
    int count = 5,
  }) async {
    final systemPrompt =
        'You are a university study assistant. Generate $count multiple-choice '
        'questions for the subject \'$subject\' at university level. '
        'Respond with ONLY a JSON array. Each element has: '
        'question (string), options (array of 4 strings), correctIndex (0-3 int).';

    final body = jsonEncode({
      'model': _kGroqModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': 'Generate $count questions for $subject.'
        },
      ],
      'temperature': 0.7,
    });

    final response = await http.post(
      Uri.parse(_kGroqEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      debugPrint('Groq API error ${response.statusCode}: ${response.body}');
      throw Exception('Groq API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        data['choices'][0]['message']['content'] as String;

    // Extract JSON array from content (strip any markdown code fences)
    final jsonStr = _extractJson(content);
    final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;

    return raw.map((item) {
      final map = item as Map<String, dynamic>;
      return StudyQuestion(
        id: _uuid.v4(),
        subject: subject,
        questionText: map['question'] as String,
        options: (map['options'] as List<dynamic>).cast<String>(),
        correctIndex: map['correctIndex'] as int,
        type: QuestionType.multipleChoice,
      );
    }).toList();
  }

  String _extractJson(String content) {
    // Strip markdown code fences if present
    final cleaned = content.trim();
    if (cleaned.startsWith('```')) {
      final start = cleaned.indexOf('[');
      final end = cleaned.lastIndexOf(']');
      if (start != -1 && end != -1) return cleaned.substring(start, end + 1);
    }
    final start = cleaned.indexOf('[');
    final end = cleaned.lastIndexOf(']');
    if (start != -1 && end != -1) return cleaned.substring(start, end + 1);
    return cleaned;
  }
}
