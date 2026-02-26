class PreservationModel {
  final int level;
  final String name;
  final String icon;
  final double costRupees;
  final int extraDays;
  final double savesRupees;
  final String instructions;
  final String explanation;

  PreservationModel({
    required this.level,
    required this.name,
    this.icon = '📦',
    required this.costRupees,
    required this.extraDays,
    required this.savesRupees,
    this.instructions = '',
    this.explanation = '',
  });

  factory PreservationModel.fromJson(Map<String, dynamic> json) {
    return PreservationModel(
      level: json['level'] ?? 1,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '📦',
      costRupees: (json['cost_rupees'] ?? 0).toDouble(),
      extraDays: json['extra_days'] ?? 0,
      savesRupees: (json['saves_rupees'] ?? 0).toDouble(),
      instructions: json['instructions'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  String get roiText {
    if (costRupees == 0) return 'FREE 🎉';
    return 'Spend ₹${costRupees.toStringAsFixed(0)}, Save ₹${savesRupees.toStringAsFixed(0)}';
  }

  String get stars => '⭐' * level;
}
