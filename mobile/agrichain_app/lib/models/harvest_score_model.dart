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
    // Handle real API ("data" wrapper) or direct mock
    final d = json.containsKey('data') && json['data'] is Map
        ? json['data'] as Map<String, dynamic>
        : json;

    // Real API uses 'score' and 'action', mock uses 'overall_score' and 'status'
    final score = d['overall_score'] ?? d['score'] ?? 65;
    final color = d['color'] ?? 'yellow';
    String status;
    if (d.containsKey('status')) {
      status = d['status'] as String;
    } else if (d.containsKey('action')) {
      // Convert action → status: harvest_now→good, wait→caution, do_not_harvest→danger
      final action = d['action'] as String? ?? '';
      status = action == 'harvest_now'
          ? 'good'
          : action == 'do_not_harvest'
          ? 'danger'
          : color == 'green'
          ? 'good'
          : color == 'red'
          ? 'danger'
          : 'caution';
    } else {
      status = color == 'green'
          ? 'good'
          : color == 'red'
          ? 'danger'
          : 'caution';
    }

    return HarvestScoreModel(
      crop: d['crop'] ?? '',
      overallScore: score is int ? score : (score as num).toInt(),
      weatherScore: d['weather_score'] ?? (d['breakdown']?['weather'] ?? 0),
      soilScore: d['soil_score'] ?? (d['breakdown']?['readiness'] ?? 0),
      marketScore: d['market_score'] ?? (d['breakdown']?['market'] ?? 0),
      recommendation: d['recommendation'] ?? d['explanation_text'] ?? '',
      recommendationHi: d['recommendation_hi'] ?? '',
      status: status,
      explanation: d['explanation'] ?? d['explanation_text'] ?? '',
      explanationHi: d['explanation_hi'] ?? '',
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
