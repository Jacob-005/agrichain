import 'package:flutter/material.dart';

class SpoilageModel {
  final String crop;
  final double remainingHours;
  final double initialHours;
  final String riskLevel; // low | medium | high
  final bool hasWeatherAlert;
  final String? alertMessage;
  final String explanation;
  final String storageMethod;
  final double temperature;

  SpoilageModel({
    required this.crop,
    required this.remainingHours,
    required this.initialHours,
    required this.riskLevel,
    this.hasWeatherAlert = false,
    this.alertMessage,
    this.explanation = '',
    required this.storageMethod,
    this.temperature = 32,
  });

  factory SpoilageModel.fromJson(Map<String, dynamic> json) {
    return SpoilageModel(
      crop: json['crop'] ?? '',
      remainingHours: (json['remaining_hours'] ?? 0).toDouble(),
      initialHours: (json['initial_hours'] ?? 72).toDouble(),
      riskLevel: json['risk_level'] ?? 'low',
      hasWeatherAlert: json['has_weather_alert'] ?? false,
      alertMessage: json['alert_message'],
      explanation: json['explanation'] ?? '',
      storageMethod: json['storage_method'] ?? 'Open Floor',
      temperature: (json['temperature'] ?? 32).toDouble(),
    );
  }

  double get timerFraction => (remainingHours / initialHours).clamp(0.0, 1.0);

  double get remainingDays => remainingHours / 24;

  Color get riskColor {
    switch (riskLevel) {
      case 'low':
        return const Color(0xFF2E7D32);
      case 'medium':
        return const Color(0xFFF9A825);
      case 'high':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String get timeDisplay {
    final h = remainingHours.floor();
    final m = ((remainingHours - h) * 60).round();
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }
}
