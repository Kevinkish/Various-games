class ScanHistoryEntry {
  final String code;
  final DateTime scannedAt;
  final String? productName;
  final String? nutriScore;

  ScanHistoryEntry({
    required this.code,
    required this.scannedAt,
    this.productName,
    this.nutriScore,
  });

  factory ScanHistoryEntry.fromMap(Map<String, Object?> map) {
    return ScanHistoryEntry(
      code: map['code'] as String,
      scannedAt: DateTime.parse(map['scannedAt'] as String),
      productName: map['productName'] as String?,
      nutriScore: map['nutriScore'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
    'code': code,
    'scannedAt': scannedAt.toIso8601String(),
    'productName': productName,
    'nutriScore': nutriScore,
  };
}
