import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_master/data/datasource/remote/dto/trivia_category.dart';
import 'package:quiz_master/domain/utils/constants.dart';

class CategoryService {
  // Fonction asynchrone qui retourne une Liste de TriviaCategory
  Future<List<TriviaCategory>> fetchCategories() async {
    final url = Uri.parse('https://opentdb.com/api_category.php');

    try {
      // 1. On lance la requête GET
      final response = await http
          .get(url)
          .timeout(Duration(seconds: Constants.timeoutDuration));

      // 2. On vérifie si le serveur a répondu avec succès (Code 200)
      if (response.statusCode == 200) {
        // 3. On décode le corps de la réponse JSON
        final Map<String, dynamic> data = json.decode(response.body);

        // 4. On extrait la liste "trivia_categories"
        final List<dynamic> categoriesJson = data['trivia_categories'];

        // 5. On transforme chaque élément JSON en objet TriviaCategory
        return categoriesJson
            .map((json) => TriviaCategory.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur serveur : Code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau ou de parsing : $e');
    }
  }
}
