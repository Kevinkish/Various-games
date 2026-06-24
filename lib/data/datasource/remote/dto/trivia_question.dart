import 'dart:convert';

class TriviaQuestion {
  final String category;
  final String type;
  final String difficulty;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  TriviaQuestion({
    required this.category,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    String decodeBase64(String value) {
      return utf8.decode(base64.decode(value));
    }

    final decodedCategory = decodeBase64(json['category'] as String);
    final decodedType = decodeBase64(json['type'] as String);
    final decodedDifficulty = decodeBase64(json['difficulty'] as String);
    final decodedQuestion = decodeBase64(json['question'] as String);
    final decodedCorrectAnswer = decodeBase64(json['correct_answer'] as String);
    final decodedIncorrectAnswers = (json['incorrect_answers'] as List<dynamic>)
        .map((item) => decodeBase64(item as String))
        .toList();

    return TriviaQuestion(
      category: decodedCategory,
      type: decodedType,
      difficulty: decodedDifficulty,
      question: decodedQuestion,
      correctAnswer: decodedCorrectAnswer,
      incorrectAnswers: decodedIncorrectAnswers,
    );
  }

  List<String> get shuffledAnswers {
    final answers = [...incorrectAnswers, correctAnswer];
    answers.shuffle();
    return answers;
  }
}
