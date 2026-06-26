import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart'; // v7.0.0
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

  // Initialisation du contrôleur pour mobile_scanner v7
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void dispose() {
    _scannerController.dispose(); // Toujours libérer le contrôleur
    super.dispose();
  }

  // Mise à jour de la signature pour mobile_scanner v7
  void _onDetect(BarcodeCapture capture) async {
    if (!_isScannerActive) return;

    // Récupération du premier code détecté dans la liste
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isScannerActive = false;
      _scannedCode = rawValue;
    });

    // Optionnel mais recommandé en v7 : mettre en pause la caméra physiquement
    _scannerController.stop();

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
        title: const Text('Scan & Co', style: TextStyle(color: Colors.black)),
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
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.hardEdge,
            elevation: 4,
            child: Stack(
              children: [
                SizedBox(
                  height: 360,
                  width: double.infinity,
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _isScannerActive ? 'Scanner actif' : 'Scan en pause',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _scannedCode == null
                ? Card(
                    key: const ValueKey('empty'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Scannez un code pour voir le résultat ici.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  )
                : Card(
                    key: const ValueKey('result'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Résultat du scan',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Code : $_scannedCode',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Produit : ${_productName ?? 'Non trouvé'}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NutriScore : ${_nutriScore?.toUpperCase() ?? 'N/A'}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: QrImageView(
                              data: _scannedCode!,
                              size: 180,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: theme.colorScheme.primary,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isScannerActive = true;
                      _scannedCode = null;
                      _productName = null;
                      _nutriScore = null;
                    });
                    _scannerController.start();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Relancer le scan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: provider.loadHistory,
                  child: const Text('Actualiser historique'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Historique des scans',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (provider.history.isEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Aucun scan pour le moment. Essayez de scanner un code.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else
            Column(
              children: provider.history.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Dismissible(
                  key: ValueKey(item.scannedAt.toIso8601String() + item.code),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => provider.removeScan(index),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      title: Text(
                        item.code,
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(item.productName ?? 'Produit inconnu'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 31,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(item.nutriScore?.toUpperCase() ?? '--'),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
