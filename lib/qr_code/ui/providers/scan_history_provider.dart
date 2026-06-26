import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/scan_history_entry.dart';

class ScanHistoryProvider extends ChangeNotifier {
  static const _historyKey = 'qr_scan_history';
  final List<ScanHistoryEntry> _history = [];

  List<ScanHistoryEntry> get history => List.unmodifiable(_history);

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_historyKey) ?? [];
    _history.clear();
    _history.addAll(
      stored.map((item) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return ScanHistoryEntry.fromMap(map);
      }),
    );
    notifyListeners();
  }

  Future<void> addScan(ScanHistoryEntry entry) async {
    _history.insert(0, entry);
    await _save();
    notifyListeners();
  }

  Future<void> removeScan(int index) async {
    _history.removeAt(index);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _historyKey,
      _history.map((entry) => jsonEncode(entry.toMap())).toList(),
    );
  }
}
