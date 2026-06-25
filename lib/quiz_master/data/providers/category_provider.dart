import 'package:flutter/widgets.dart';
import 'package:quiz_master/quiz_master/data/datasource/remote/category_service/trivia_category_service.dart';
import 'package:quiz_master/quiz_master/data/datasource/remote/dto/trivia_category.dart';

enum CategoryState { idle, empty, loading, error, completed }

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  CategoryState state = .idle;
  String? errorMessage;
  List<TriviaCategory> categories = [];

  Future<void> fetchCategories() async {
    try {
      // state = .loading;
      categories = await _categoryService.fetchCategories();
      state = .completed;
    } catch (e) {
      errorMessage = e.toString();
      state = .error;
    }
    notifyListeners();
  }
}
