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

  /// Per-subject MCQ quiz (5 questions by default).
  Future<List<StudyQuestion>> generateQuestions(
    String subject, {
    String? syllabusBook,
    int count = 5,
  }) async {
    final context =
        (syllabusBook != null && syllabusBook.isNotEmpty) ? ' (textbook: $syllabusBook)' : '';
    final systemPrompt =
        'You are a university study assistant. Generate $count multiple-choice '
        'questions for the subject \'$subject\'$context at university level. '
        'Respond with ONLY a JSON array. Each element has: '
        'question (string), options (array of 4 strings), correctIndex (0-3 int).';

    final content = await _chat(systemPrompt, 'Generate $count questions for $subject.');
    final raw = jsonDecode(_extractJson(content)) as List<dynamic>;

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

  /// Multi-subject mixed quiz: MCQ, true/false, open-ended.
  Future<List<StudyQuestion>> generateMixedQuestions({
    required List<String> subjectDescriptions,
    int count = 10,
  }) async {
    final subjectsStr = subjectDescriptions.join('; ');
    final systemPrompt = '''You are a university study assistant.
Generate $count questions covering these subjects: $subjectsStr.
Include a mix of question types. Respond with ONLY a JSON array.
Each item must have:
- "type": "mcq" | "trueOrFalse" | "openEnded"
- "subject": the subject this question belongs to
- "question": the question text
For "mcq": add "options" (array of 4 strings) and "correctIndex" (0-3 int).
For "trueOrFalse": add "answer" (boolean) and "explanation" (1-2 sentences explaining why).
For "openEnded": add "expectedAnswer" (concise model answer, 2-3 sentences max).''';

    final content = await _chat(
        systemPrompt, 'Generate $count mixed questions covering: $subjectsStr');
    final raw = jsonDecode(_extractJson(content)) as List<dynamic>;

    return raw.map((item) {
      final map = item as Map<String, dynamic>;
      final typeStr = (map['type'] as String?) ?? 'mcq';
      final subject = (map['subject'] as String?) ?? subjectDescriptions.first;

      switch (typeStr) {
        case 'trueOrFalse':
          return StudyQuestion(
            id: _uuid.v4(),
            subject: subject,
            questionText: map['question'] as String,
            type: QuestionType.trueOrFalse,
            correctBool: map['answer'] as bool? ?? true,
            explanation: map['explanation'] as String?,
          );
        case 'openEnded':
          return StudyQuestion(
            id: _uuid.v4(),
            subject: subject,
            questionText: map['question'] as String,
            type: QuestionType.openEnded,
            expectedAnswer: map['expectedAnswer'] as String?,
          );
        default: // mcq
          return StudyQuestion(
            id: _uuid.v4(),
            subject: subject,
            questionText: map['question'] as String,
            type: QuestionType.multipleChoice,
            options: (map['options'] as List<dynamic>).cast<String>(),
            correctIndex: map['correctIndex'] as int? ?? 0,
          );
      }
    }).toList();
  }

  Future<String> _chat(String systemPrompt, String userMessage) async {
    final body = jsonEncode({
      'model': _kGroqModel,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userMessage},
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
    return data['choices'][0]['message']['content'] as String;
  }

  String _extractJson(String content) {
    final cleaned = content.trim();
    final start = cleaned.indexOf('[');
    final end = cleaned.lastIndexOf(']');
    if (start != -1 && end != -1) return cleaned.substring(start, end + 1);
    return cleaned;
  }
}
