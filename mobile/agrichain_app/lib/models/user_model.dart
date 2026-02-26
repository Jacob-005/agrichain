class UserModel {
  final String id;
  final String name;
  final String phone;
  final String village;
  final String district;
  final String state;
  final List<String> crops;
  final String? soilType;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.village,
    required this.district,
    required this.state,
    this.crops = const [],
    this.soilType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      village: json['village'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      crops: List<String>.from(json['crops'] ?? []),
      soilType: json['soil_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'village': village,
        'district': district,
        'state': state,
        'crops': crops,
        'soil_type': soilType,
      };
}
