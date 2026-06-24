import 'package:hive/hive.dart';

part 'match_record.g.dart';

@HiveType(typeId: 0)
class MatchRecord extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int scorePlayer1;

  @HiveField(2)
  final int scorePlayer2;

  @HiveField(3)
  final String categoryName;

  MatchRecord({
    required this.date,
    required this.scorePlayer1,
    required this.scorePlayer2,
    required this.categoryName,
  });
}
