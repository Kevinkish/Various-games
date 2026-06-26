import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGenerateScreen extends StatefulWidget {
  const QrGenerateScreen({super.key});

  @override
  State<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends State<QrGenerateScreen> {
  final _dataController = TextEditingController();
  Color _qrColor = Colors.black;
  String _selectedType = 'URL';
  final _types = ['URL', 'Texte', 'WiFi'];

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  String get _displayData {
    final raw = _dataController.text.trim();
    if (_selectedType == 'WiFi') {
      return 'WIFI:S:MyNetwork;T:WPA;P:$raw;;';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Générateur QR')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aperçu QR',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: QrImageView(
                      data: _displayData.isEmpty ? ' ' : _displayData,
                      size: 220,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: _qrColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: _qrColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Contenu généré',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _displayData.isEmpty
                        ? 'Entrez du texte, une URL ou un mot de passe WiFi.'
                        : _displayData,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
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
                    'Type de QR',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: _types.map((type) {
                      final selected = _selectedType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedType = type),
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        labelStyle: TextStyle(
                          color: selected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _dataController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: _selectedType == 'URL'
                          ? 'URL'
                          : _selectedType == 'Texte'
                          ? 'Texte'
                          : 'Mot de passe WiFi',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
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
                    'Couleur du QR',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children:
                        [
                          Colors.black,
                          Colors.blue,
                          Colors.green,
                          Colors.purple,
                          Colors.orange,
                        ].map((color) {
                          final selected = _qrColor == color;
                          return GestureDetector(
                            onTap: () => setState(() => _qrColor = color),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
