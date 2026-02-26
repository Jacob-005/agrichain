class SpoilageModel {
  final String crop;
  final String storageType;
  final double hoursSinceHarvest;
  final double spoilagePercentage;
  final double remainingHours;
  final String status; // good | caution | danger
  final String tip;
  final String tipHi;

  SpoilageModel({
    required this.crop,
    required this.storageType,
    required this.hoursSinceHarvest,
    required this.spoilagePercentage,
    required this.remainingHours,
    required this.status,
    required this.tip,
    required this.tipHi,
  });

  factory SpoilageModel.fromJson(Map<String, dynamic> json) {
    return SpoilageModel(
      crop: json['crop'] ?? '',
      storageType: json['storage_type'] ?? '',
      hoursSinceHarvest: (json['hours_since_harvest'] ?? 0).toDouble(),
      spoilagePercentage: (json['spoilage_percentage'] ?? 0).toDouble(),
      remainingHours: (json['remaining_hours'] ?? 0).toDouble(),
      status: json['status'] ?? 'good',
      tip: json['tip'] ?? '',
      tipHi: json['tip_hi'] ?? '',
    );
  }
}
