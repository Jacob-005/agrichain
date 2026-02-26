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
    // Handle real API wrapper
    final d = json.containsKey('data') && json['data'] is Map
        ? json['data'] as Map<String, dynamic>
        : json;

    // Map urgency/color to risk_level
    String riskLevel = d['risk_level'] ?? '';
    if (riskLevel.isEmpty) {
      final urgency = d['urgency'] ?? '';
      final color = d['color'] ?? 'green';
      if (urgency == 'urgent' || color == 'red') {
        riskLevel = 'high';
      } else if (urgency == 'attention' || color == 'yellow') {
        riskLevel = 'medium';
      } else {
        riskLevel = 'low';
      }
    }

    return SpoilageModel(
      crop: d['crop'] ?? '',
      remainingHours: (d['remaining_hours'] ?? 0).toDouble(),
      initialHours: (d['initial_hours'] ?? d['remaining_hours'] ?? 72)
          .toDouble(),
      riskLevel: riskLevel,
      hasWeatherAlert: d['has_weather_alert'] ?? false,
      alertMessage: d['alert_message'],
      explanation: d['explanation'] ?? d['explanation_text'] ?? '',
      storageMethod: d['storage_method'] ?? 'Open Floor',
      temperature: (d['temperature'] ?? 32).toDouble(),
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
