class PinData {
  final String pinSalt;
  final String pinHash;
  final DateTime validUntil;

  PinData({
    required this.pinSalt,
    required this.pinHash,
    required this.validUntil,
  });

  Map<String, String> toMap() => {
    'pinSalt': pinSalt,
    'pinHash': pinHash,
    'validUntil': validUntil.toIso8601String(),
  };

  factory PinData.fromMap(Map<String, String> map) => PinData(
    pinSalt: map['pinSalt'] ?? '',
    pinHash: map['pinHash'] ?? '',
    validUntil: DateTime.parse(map['validUntil']!),
  );

  bool isValid() {
    return DateTime.now().isBefore(validUntil);
  }
}
