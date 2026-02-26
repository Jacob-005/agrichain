class HarvestScoreModel {
  final String crop;
  final int overallScore;
  final int weatherScore;
  final int soilScore;
  final int marketScore;
  final String recommendation;
  final String recommendationHi;
  final String status; // good | caution | danger

  HarvestScoreModel({
    required this.crop,
    required this.overallScore,
    required this.weatherScore,
    required this.soilScore,
    required this.marketScore,
    required this.recommendation,
    required this.recommendationHi,
    required this.status,
  });

  factory HarvestScoreModel.fromJson(Map<String, dynamic> json) {
    return HarvestScoreModel(
      crop: json['crop'] ?? '',
      overallScore: json['overall_score'] ?? 0,
      weatherScore: json['weather_score'] ?? 0,
      soilScore: json['soil_score'] ?? 0,
      marketScore: json['market_score'] ?? 0,
      recommendation: json['recommendation'] ?? '',
      recommendationHi: json['recommendation_hi'] ?? '',
      status: json['status'] ?? 'good',
    );
  }
}
