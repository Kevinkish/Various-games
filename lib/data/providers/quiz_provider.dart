import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:quiz_master/data/datasource/remote/trivia_api.dart';
import 'package:quiz_master/domain/models/match_record.dart';
import 'package:quiz_master/data/datasource/remote/dto/trivia_question.dart';

enum QuizPhase { idle, loading, player1, transition, player2, completed, error }

class QuizProvider extends ChangeNotifier {
  final TriviaApiService apiService;
  final Box<MatchRecord> matchBox;

  QuizProvider({required this.matchBox, TriviaApiService? apiService})
    : apiService = apiService ?? TriviaApiService();

  List<TriviaQuestion> _questions = [];
  List<String> _currentAnswers = [];
  Timer? _timer;

  QuizPhase phase = QuizPhase.idle;
  String? errorMessage;
  String categoryName = '';
  int currentQuestionIndex = 0;
  int player1Score = 0;
  int player2Score = 0;
  int timeLeft = 10;

  List<TriviaQuestion> get questions => List.unmodifiable(_questions);
  List<String> get currentAnswers => List.unmodifiable(_currentAnswers);

  TriviaQuestion? get currentQuestion {
    if (_questions.isEmpty || currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[currentQuestionIndex];
  }

  int get totalQuestions => _questions.length;
  int get currentQuestionNumber => currentQuestionIndex + 1;

  Future<void> fetchQuestions(int categoryId, String categoryName) async {
    _cancelTimer();
    phase = QuizPhase.loading;
    errorMessage = null;
    currentQuestionIndex = 0;
    player1Score = 0;
    player2Score = 0;
    timeLeft = 10;
    this.categoryName = categoryName;
    notifyListeners();

    try {
      final questions = await apiService.fetchQuestions(categoryId);
      if (questions.isEmpty) {
        throw Exception('Aucune question trouvée pour cette catégorie.');
      }
      _questions = questions;
      phase = QuizPhase.player1;
      _prepareCurrentAnswers();
      _startTimer();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('QuizProvider.fetchQuestions error: $error\n$stackTrace');
      }
      phase = QuizPhase.error;
      errorMessage = error.toString();
    }
    notifyListeners();
  }

  void submitAnswer(String answer) {
    if (phase != QuizPhase.player1 && phase != QuizPhase.player2) {
      return;
    }

    final isCorrect = currentQuestion?.correctAnswer == answer;
    if (isCorrect) {
      if (phase == QuizPhase.player1) {
        player1Score++;
      } else {
        player2Score++;
      }
    }

    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    _cancelTimer();

    if (currentQuestionIndex + 1 >= _questions.length) {
      if (phase == QuizPhase.player1) {
        phase = QuizPhase.transition;
      } else {
        _saveResult();
        phase = QuizPhase.completed;
      }
      notifyListeners();
      return;
    }

    currentQuestionIndex++;
    timeLeft = 10;
    _prepareCurrentAnswers();
    _startTimer();
    notifyListeners();
  }

  void startPlayer2Turn() {
    if (_questions.isEmpty) {
      return;
    }

    currentQuestionIndex = 0;
    player2Score = 0;
    timeLeft = 10;
    phase = QuizPhase.player2;
    _prepareCurrentAnswers();
    _startTimer();
    notifyListeners();
  }

  void _saveResult() {
    final record = MatchRecord(
      date: DateTime.now(),
      scorePlayer1: player1Score,
      scorePlayer2: player2Score,
      categoryName: categoryName,
    );
    matchBox.add(record);
  }

  void _startTimer() {
    _cancelTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft <= 1) {
        timer.cancel();
        onTimeExpired();
        return;
      }

      timeLeft--;
      notifyListeners();
    });
  }

  void onTimeExpired() {
    if (phase != QuizPhase.player1 && phase != QuizPhase.player2) {
      return;
    }
    _moveToNextQuestion();
  }

  void _prepareCurrentAnswers() {
    _currentAnswers = currentQuestion?.shuffledAnswers ?? [];
  }

  void resetGame() {
    _cancelTimer();
    _questions = [];
    _currentAnswers = [];
    phase = QuizPhase.idle;
    errorMessage = null;
    categoryName = '';
    currentQuestionIndex = 0;
    player1Score = 0;
    player2Score = 0;
    timeLeft = 10;
    notifyListeners();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
