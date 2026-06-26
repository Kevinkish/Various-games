import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/scan_history_entry.dart';
import '../providers/scan_history_provider.dart';
import 'qr_generate_screen.dart';

class QrHomeScreen extends StatefulWidget {
  const QrHomeScreen({super.key});

  @override
  State<QrHomeScreen> createState() => _QrHomeScreenState();
}

class _QrHomeScreenState extends State<QrHomeScreen> {
  String? _scannedCode;
  bool _isScannerActive = true;
  String? _productName;
  String? _nutriScore;

  void _onDetect(Barcode barcode, MobileScannerArguments? arguments) async {
    if (!_isScannerActive) return;
    final rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isScannerActive = false);
    _scannedCode = rawValue;
    await _fetchProductInfo(rawValue);
    if (!mounted) return;

    final provider = context.read<ScanHistoryProvider>();
    provider.addScan(
      ScanHistoryEntry(
        code: rawValue,
        scannedAt: DateTime.now(),
        productName: _productName,
        nutriScore: _nutriScore,
      ),
    );
    setState(() {});
  }

  Future<void> _fetchProductInfo(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
        ),
      );
      if (response.statusCode != 200) {
        throw Exception('API error');
      }
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final product = map['product'] as Map<String, dynamic>?;
      setState(() {
        _productName = product?['product_name'] as String?;
        _nutriScore = product?['nutriscore_grade'] as String?;
      });
    } catch (_) {
      setState(() {
        _productName = null;
        _nutriScore = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanHistoryProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Co'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QrGenerateScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 360,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: MobileScanner(onDetect: _onDetect, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          if (_scannedCode != null) ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résultat du scan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Code: $_scannedCode',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Produit: ${_productName ?? 'Non trouvé'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NutriScore: ${_nutriScore?.toUpperCase() ?? 'N/A'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    QrImageView(data: _scannedCode!, size: 140),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isScannerActive = true;
                    _scannedCode = null;
                    _productName = null;
                    _nutriScore = null;
                  });
                },
                child: const Text('Réactiver le scan'),
              ),
              TextButton(
                onPressed: () {
                  provider.loadHistory();
                },
                child: const Text('Actualiser l’historique'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Historique des scans',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...provider.history.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Dismissible(
              key: ValueKey(item.scannedAt.toIso8601String() + item.code),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: theme.colorScheme.error,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => provider.removeScan(index),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  title: Text(item.code),
                  subtitle: Text(item.productName ?? 'Produit inconnu'),
                  trailing: Text(item.nutriScore?.toUpperCase() ?? '--'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
