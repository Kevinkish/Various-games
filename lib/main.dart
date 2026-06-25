import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/data/providers/category_provider.dart';
import 'package:quiz_master/data/providers/quiz_provider.dart';
import 'package:quiz_master/domain/models/match_record.dart';
import 'package:quiz_master/ui/screens/home_screen.dart';
import 'package:quiz_master/ui/styles/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MatchRecordAdapter());
  await Hive.openBox<MatchRecord>('match_records');

  runApp(const QuizMasterApp());
}

class QuizMasterApp extends StatelessWidget {
  const QuizMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              QuizProvider(matchBox: Hive.box<MatchRecord>('match_records')),
        ),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: 'Quiz Master',

        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: theme,

        darkTheme: darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
