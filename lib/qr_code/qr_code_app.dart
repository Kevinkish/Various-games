import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/providers/scan_history_provider.dart';
import 'ui/screens/qr_home_screen.dart';

class QrCodeApp extends StatelessWidget {
  const QrCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanHistoryProvider()..loadHistory(),
      child: MaterialApp(
        title: 'Scan & Co',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: const QrHomeScreen(),
      ),
    );
  }
}
