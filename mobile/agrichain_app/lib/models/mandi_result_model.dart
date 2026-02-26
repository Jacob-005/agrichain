class MandiResultModel {
  final String name;
  final int distanceKm;
  final double pricePerKg;
  final double totalRevenue;
  final double transportCost;
  final double netProfit;
  final String demand;

  MandiResultModel({
    required this.name,
    required this.distanceKm,
    required this.pricePerKg,
    required this.totalRevenue,
    required this.transportCost,
    required this.netProfit,
    required this.demand,
  });

  factory MandiResultModel.fromJson(Map<String, dynamic> json) {
    return MandiResultModel(
      name: json['name'] ?? '',
      distanceKm: json['distance_km'] ?? 0,
      pricePerKg: (json['price_per_kg'] ?? 0).toDouble(),
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      transportCost: (json['transport_cost'] ?? 0).toDouble(),
      netProfit: (json['net_profit'] ?? 0).toDouble(),
      demand: json['demand'] ?? 'low',
    );
  }
}
