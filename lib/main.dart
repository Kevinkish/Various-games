import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/cashFlow/data/database/cash_flow_database.dart';
import 'package:quiz_master/cashFlow/ui/providers/cash_flow_provider.dart';
import 'package:quiz_master/moodly/data/database/mood_database.dart';
import 'package:quiz_master/moodly/ui/providers/mood_provider.dart';
import 'package:quiz_master/nearby/ui/providers/nearby_provider.dart';
import 'package:quiz_master/qr_code/ui/providers/scan_history_provider.dart';
import 'package:quiz_master/quiz_master/data/providers/category_provider.dart';
import 'package:quiz_master/quiz_master/data/providers/quiz_provider.dart';
import 'package:quiz_master/quiz_master/domain/models/match_record.dart';
import 'package:quiz_master/host_page.dart';
import 'package:quiz_master/quiz_master/ui/styles/app_theme.dart';

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
        ChangeNotifierProvider(
          create: (_) =>
              CashFlowProvider(CashFlowDatabase.instance)..loadData(),
        ),
        ChangeNotifierProvider(
          create: (_) => MoodProvider(MoodDatabase.instance)..loadEntries(),
        ),
        ChangeNotifierProvider(create: (_) => NearbyProvider()..loadPlaces()),
        ChangeNotifierProvider(
          create: (_) => ScanHistoryProvider()..loadHistory(),
        ),
        ChangeNotifierProvider(create: (_) => NearbyProvider()..loadPlaces()),
      ],
      child: MaterialApp(
        title: 'Quiz Master',

        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: theme,

        darkTheme: darkTheme,
        home: const HostPage(),
      ),
    );
  }
}
