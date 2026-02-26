class PreservationModel {
  final String method;
  final String methodHi;
  final String icon;
  final int extendsLifeHours;
  final double costPerKg;
  final String availability;

  PreservationModel({
    required this.method,
    required this.methodHi,
    required this.icon,
    required this.extendsLifeHours,
    required this.costPerKg,
    required this.availability,
  });

  factory PreservationModel.fromJson(Map<String, dynamic> json) {
    return PreservationModel(
      method: json['method'] ?? '',
      methodHi: json['method_hi'] ?? '',
      icon: json['icon'] ?? '📦',
      extendsLifeHours: json['extends_life_hours'] ?? 0,
      costPerKg: (json['cost_per_kg'] ?? 0).toDouble(),
      availability: json['availability'] ?? '',
    );
  }
}
