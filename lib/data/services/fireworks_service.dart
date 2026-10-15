import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../models/study_question.dart';

const _fireworksEndpoint =
    'https://api.fireworks.ai/inference/v1/chat/completions';
// Verified against the configured account's current serverless model catalogue.
const _fireworksModel = 'accounts/fireworks/models/glm-5p3-flash';

/// Fireworks' OpenAI-compatible endpoint. A mobile-shipped API key is suitable
/// only for this competition build; production must proxy requests server-side.
class FireworksService extends GetxService {
  FireworksService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final _uuid = const Uuid();

  String get _apiKey => dotenv.env['FIREWORKS_API_KEY'] ?? '';

  Future<List<StudyQuestion>> generateQuestions({
    required String courseName,
    String? textbookName,
    String? materialNotes,
    int count = 5,
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw const FireworksException('FIREWORKS_API_KEY is missing.');
    }

    final boundedNotes = (materialNotes ?? '').trim();
    final context = <String>[
      'Course: $courseName',
      if ((textbookName ?? '').trim().isNotEmpty)
        'Textbook: ${textbookName!.trim()}',
      if (boundedNotes.isNotEmpty)
        'Course material notes (use only as context): ${boundedNotes.substring(0, boundedNotes.length.clamp(0, 6000))}',
    ].join('\n');

    final schema = {
      'type': 'json_schema',
      'json_schema': {
        'name': 'study_questions',
        'strict': true,
        'schema': {
          'type': 'object',
          'additionalProperties': false,
          'required': ['questions'],
          'properties': {
            'questions': {
              'type': 'array',
              'minItems': count,
              'maxItems': count,
              'items': {
                'type': 'object',
                'additionalProperties': false,
                'required': [
                  'question',
                  'options',
                  'correctIndex',
                  'explanation',
                ],
                'properties': {
                  'question': {'type': 'string'},
                  'options': {
                    'type': 'array',
                    'minItems': 4,
                    'maxItems': 4,
                    'items': {'type': 'string'},
                  },
                  'correctIndex': {
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 3,
                  },
                  'explanation': {'type': 'string'},
                },
              },
            },
          },
        },
      },
    };

    final response = await _client.post(
      Uri.parse(_fireworksEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _fireworksModel,
        'temperature': 0.3,
        'response_format': schema,
        'messages': [
          {
            'role': 'system',
            'content':
                'You create concise, accurate university multiple-choice questions. Return the requested schema only.',
          },
          {'role': 'user', 'content': 'Create $count questions.\n$context'},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw FireworksException(_providerError(response));
    }

    try {
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final content = payload['choices']?[0]?['message']?['content'];
      final decoded = content is String ? jsonDecode(content) : content;
      final rows =
          (decoded as Map<String, dynamic>)['questions'] as List<dynamic>;
      if (rows.length != count)
        throw const FormatException('Incorrect question count');
      return rows
          .map((raw) {
            final row = Map<String, dynamic>.from(raw as Map);
            final options = List<String>.from(row['options'] as List);
            final correctIndex = row['correctIndex'] as int;
            if (options.length != 4 ||
                correctIndex < 0 ||
                correctIndex >= options.length) {
              throw const FormatException('Invalid question options');
            }
            return StudyQuestion(
              id: _uuid.v4(),
              subject: courseName,
              questionText: row['question'] as String,
              type: QuestionType.multipleChoice,
              options: options,
              correctIndex: correctIndex,
              explanation: row['explanation'] as String,
            );
          })
          .toList(growable: false);
    } catch (_) {
      throw const FireworksException(
        'Fireworks returned malformed questions. Please retry.',
      );
    }
  }
}

String _providerError(http.Response response) {
  try {
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final detail = payload['error']?['message'] ?? payload['message'];
    if (detail is String && detail.isNotEmpty) {
      return 'Fireworks request failed (${response.statusCode}): $detail';
    }
  } catch (_) {
    // Keep the response body out of the UI unless it is a known error shape.
  }
  return 'Fireworks request failed (${response.statusCode}).';
}

class FireworksException implements Exception {
  const FireworksException(this.message);
  final String message;
  @override
  String toString() => message;
}
