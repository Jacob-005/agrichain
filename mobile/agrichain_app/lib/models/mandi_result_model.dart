import 'package:flutter/material.dart';

class MandiResultModel {
  final int rank;
  final String name;
  final double pricePerKg;
  final double distanceKm;
  final double fuelCost;
  final double spoilageLoss;
  final double spoilagePct;
  final double pocketCash;
  final String riskLevel; // low | medium | high
  final String explanation;
  final String demand;

  MandiResultModel({
    required this.rank,
    required this.name,
    required this.pricePerKg,
    required this.distanceKm,
    required this.fuelCost,
    required this.spoilageLoss,
    required this.spoilagePct,
    required this.pocketCash,
    required this.riskLevel,
    this.explanation = '',
    this.demand = 'medium',
  });

  factory MandiResultModel.fromJson(Map<String, dynamic> json) {
    return MandiResultModel(
      rank: json['rank'] ?? 0,
      name: json['name'] ?? '',
      pricePerKg: (json['price_per_kg'] ?? 0).toDouble(),
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      fuelCost: (json['fuel_cost'] ?? 0).toDouble(),
      spoilageLoss: (json['spoilage_loss'] ?? 0).toDouble(),
      spoilagePct: (json['spoilage_pct'] ?? 0).toDouble(),
      pocketCash: (json['pocket_cash'] ?? 0).toDouble(),
      riskLevel: json['risk_level'] ?? 'low',
      explanation: json['explanation'] ?? '',
      demand: json['demand'] ?? 'medium',
    );
  }

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

  double get rottingBarFraction => (spoilagePct / 100).clamp(0.0, 1.0);

  String get rankEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }
}
