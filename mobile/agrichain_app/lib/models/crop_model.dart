class CropModel {
  final String id;
  final String name;
  final String nameHi;
  final String icon;

  CropModel({
    required this.id,
    required this.name,
    required this.nameHi,
    required this.icon,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameHi: json['name_hi'] ?? '',
      icon: json['icon'] ?? '🌱',
    );
  }
}
