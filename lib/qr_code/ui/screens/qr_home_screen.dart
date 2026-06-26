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
  bool _isLoadingProduct = false;
  String? _productName;
  String? _nutriScore;
  Map<String, dynamic>? _productDetails;

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
    setState(() {
      _isLoadingProduct = true;
      _productDetails = null;
      _productName = null;
      _nutriScore = null;
    });

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
        _productDetails = product;
        _productName = product?['product_name'] as String?;
        _nutriScore = product?['nutriscore_grade'] as String?;
      });
    } catch (_) {
      setState(() {
        _productDetails = null;
        _productName = null;
        _nutriScore = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProduct = false;
        });
      }
    }
  }

  void _showProductDetails() {
    if (_productDetails == null) return;
    final product = _productDetails!;
    final imageUrl =
        (product['selected_images']
                as Map<String, dynamic>?)?['front']?['thumb']?['en']
            as String? ??
        product['image_front_thumb_url'] as String?;
    final brand = product['brands'] as String?;
    final categories = product['categories'] as String?;
    final allergens = product['allergens'] as String?;
    final ingredients = product['ingredients_text'] as String?;
    final quantity = product['quantity'] as String?;
    final origins = product['origins'] as String?;
    final labels = product['labels'] as String?;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            product['product_name'] as String? ?? 'Détails du produit',
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (imageUrl != null) const SizedBox(height: 16),
                if (brand != null) ...[
                  Text('Marque', style: Theme.of(context).textTheme.labelLarge),
                  Text(brand),
                  const SizedBox(height: 12),
                ],
                if (categories != null) ...[
                  Text(
                    'Catégories',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(categories),
                  const SizedBox(height: 12),
                ],
                if (labels != null) ...[
                  Text('Labels', style: Theme.of(context).textTheme.labelLarge),
                  Text(labels),
                  const SizedBox(height: 12),
                ],
                if (allergens != null) ...[
                  Text(
                    'Allergènes',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(allergens),
                  const SizedBox(height: 12),
                ],
                if (ingredients != null) ...[
                  Text(
                    'Ingrédients',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(ingredients),
                  const SizedBox(height: 12),
                ],
                if (quantity != null) ...[
                  Text(
                    'Quantité',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(quantity),
                  const SizedBox(height: 12),
                ],
                if (origins != null) ...[
                  Text(
                    'Origine',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(origins),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
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
                          if (_isLoadingProduct)
                            Row(
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Chargement des détails...',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    (_productDetails == null ||
                                        _isLoadingProduct)
                                    ? null
                                    : _showProductDetails,
                                icon: const Icon(Icons.info_outline),
                                label: const Text('Détails produit'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isScannerActive = true;
                                    _scannedCode = null;
                                    _productName = null;
                                    _nutriScore = null;
                                    _productDetails = null;
                                  });
                                  _scannerController.start();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Relancer'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
