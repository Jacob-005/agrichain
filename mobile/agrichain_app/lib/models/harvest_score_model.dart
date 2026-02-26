import 'package:flutter/material.dart';

class HarvestScoreModel {
  final String crop;
  final int overallScore;
  final int weatherScore;
  final int soilScore;
  final int marketScore;
  final String recommendation;
  final String recommendationHi;
  final String status; // good | caution | danger
  final String explanation;
  final String explanationHi;

  HarvestScoreModel({
    required this.crop,
    required this.overallScore,
    required this.weatherScore,
    required this.soilScore,
    required this.marketScore,
    required this.recommendation,
    required this.recommendationHi,
    required this.status,
    this.explanation = '',
    this.explanationHi = '',
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
      explanation: json['explanation'] ?? '',
      explanationHi: json['explanation_hi'] ?? '',
    );
  }

  Color get statusColor {
    switch (status) {
      case 'good':
        return const Color(0xFF2E7D32);
      case 'caution':
        return const Color(0xFFF9A825);
      case 'danger':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String get statusEmoji {
    switch (status) {
      case 'good':
        return '✅';
      case 'caution':
        return '⏳';
      case 'danger':
        return '⛔';
      default:
        return '✅';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'good':
        return 'Harvest Now ✅';
      case 'caution':
        return 'Wait 2-3 Days ⏳';
      case 'danger':
        return 'Don\'t Harvest ⛔';
      default:
        return 'Harvest Now ✅';
    }
  }

  Map<String, int> get breakdown => {
        'Weather': weatherScore,
        'Market': marketScore,
        'Soil/Readiness': soilScore,
      };
}
