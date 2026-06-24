import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quiz_master/data/datasource/remote/dto/trivia_question.dart';

class TriviaApiService {
  final http.Client _client;

  TriviaApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<TriviaQuestion>> fetchQuestions(int categoryId) async {
    final uri = Uri.parse(
      'https://opentdb.com/api.php?amount=10&type=multiple&encode=base64&category=$categoryId',
    );

    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Échec réseau (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final responseCode = body['response_code'] as int? ?? -1;
    if (responseCode != 0) {
      throw Exception('Aucune question disponible (code $responseCode).');
    }

    final results = body['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      throw Exception('Aucune question trouvée.');
    }

    return results
        .cast<Map<String, dynamic>>()
        .map(TriviaQuestion.fromJson)
        .toList();
  }
}
