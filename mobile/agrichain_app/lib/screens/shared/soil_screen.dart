import 'package:flutter/material.dart';
import '../../app/theme.dart';

class SoilScreen extends StatelessWidget {
  const SoilScreen({super.key});

  // This would come from user profile — hardcode for now
  final String userSoilType = "black_cotton";

  static const Map<String, Map<String, dynamic>> soilData = {
    "black_cotton": {
      "name": "Black Cotton Soil (काली मिट्टी)",
      "emoji": "⬛",
      "color": 0xFF3E2723,
      "moisture": 0.85,
      "ph": "7.5 - 8.5",
      "description":
          "Deep, heavy clay soil that retains moisture well. "
          "Expands when wet and shrinks when dry, forming cracks.",
      "best_crops": [
        {"name": "Cotton", "emoji": "🌿"},
        {"name": "Soybean", "emoji": "🫘"},
        {"name": "Wheat", "emoji": "🌾"},
        {"name": "Jowar", "emoji": "🌽"},
        {"name": "Tomato", "emoji": "🍅"},
        {"name": "Onion", "emoji": "🧅"},
      ],
      "avoid_crops": ["Rice", "Potato (waterlogging risk)"],
      "strengths": [
        "High water retention — needs less irrigation",
        "Rich in calcium, magnesium, iron",
        "Good for deep-rooted crops",
        "Self-ploughing (cracks aerate soil)",
      ],
      "weaknesses": [
        "Poor drainage — waterlogging in heavy rain",
        "Hard to plough when dry",
        "Sticky when wet — difficult to work",
        "Low nitrogen and phosphorus",
      ],
      "tips": [
        {
          "icon": "💧",
          "title": "Irrigation",
          "text":
              "Water less frequently but deeply. "
              "Black soil holds moisture for 5-7 days.",
        },
        {
          "icon": "🌱",
          "title": "Organic Matter",
          "text":
              "Add farmyard manure (FYM) every season. "
              "2-3 tonnes per acre improves drainage.",
        },
        {
          "icon": "⚗️",
          "title": "Fertilizer",
          "text":
              "Needs extra nitrogen (Urea) and phosphorus (DAP). "
              "Apply 50kg Urea + 25kg DAP per acre.",
        },
        {
          "icon": "🚜",
          "title": "Ploughing",
          "text":
              "Best ploughed when slightly moist — not too "
              "wet (sticky) or too dry (hard). Early morning is ideal.",
        },
        {
          "icon": "🌿",
          "title": "Cover Crop",
          "text":
              "Grow green manure (dhaincha) between seasons. "
              "It adds nitrogen naturally — saves ₹500/acre on fertilizer.",
        },
      ],
    },
    "red": {
      "name": "Red Soil (लाल मिट्टी)",
      "emoji": "🟥",
      "color": 0xFFC62828,
      "moisture": 0.45,
      "ph": "6.0 - 7.0",
      "description":
          "Light, porous soil with good drainage. Rich in iron "
          "which gives the red color. Found in Deccan plateau regions.",
      "best_crops": [
        {"name": "Groundnut", "emoji": "🥜"},
        {"name": "Potato", "emoji": "🥔"},
        {"name": "Tomato", "emoji": "🍅"},
        {"name": "Millet", "emoji": "🌾"},
        {"name": "Pulses", "emoji": "🫘"},
        {"name": "Maize", "emoji": "🌽"},
      ],
      "avoid_crops": ["Rice", "Sugarcane (needs more water)"],
      "strengths": [
        "Good drainage — no waterlogging",
        "Easy to plough and work with",
        "Warms up quickly — good for early planting",
        "Rich in iron and potash",
      ],
      "weaknesses": [
        "Low moisture retention — needs frequent watering",
        "Low in nitrogen, phosphorus, humus",
        "Can be acidic in some areas",
        "Erodes easily on slopes",
      ],
      "tips": [
        {
          "icon": "💧",
          "title": "Irrigation",
          "text":
              "Water frequently in small amounts. "
              "Drip irrigation saves 40% water.",
        },
        {
          "icon": "🌱",
          "title": "Organic Matter",
          "text":
              "Add compost generously — 3-4 tonnes/acre. "
              "Red soil badly needs organic matter.",
        },
        {
          "icon": "⚗️",
          "title": "Fertilizer",
          "text":
              "Needs heavy nitrogen + phosphorus. "
              "Apply 60kg Urea + 30kg DAP per acre.",
        },
        {
          "icon": "🧱",
          "title": "Mulching",
          "text":
              "Cover soil with crop residue or dry leaves. "
              "Reduces water evaporation by 30%.",
        },
        {
          "icon": "🌿",
          "title": "Green Manure",
          "text":
              "Grow sun hemp between seasons. "
              "Adds nitrogen and improves water holding.",
        },
      ],
    },
    "alluvial": {
      "name": "Alluvial Soil (जलोढ़ मिट्टी)",
      "emoji": "🟫",
      "color": 0xFF795548,
      "moisture": 0.65,
      "ph": "6.5 - 7.5",
      "description":
          "Deposited by rivers. Very fertile, most productive "
          "soil in India. Found in Indo-Gangetic plains.",
      "best_crops": [
        {"name": "Rice", "emoji": "🌾"},
        {"name": "Wheat", "emoji": "🌾"},
        {"name": "Sugarcane", "emoji": "🎋"},
        {"name": "Potato", "emoji": "🥔"},
        {"name": "Vegetables", "emoji": "🥬"},
        {"name": "Banana", "emoji": "🍌"},
      ],
      "avoid_crops": ["Few restrictions — very versatile"],
      "strengths": [
        "Highly fertile — rich in potash and lime",
        "Good water retention AND drainage balance",
        "Easy to cultivate",
        "Renewed by river flooding",
      ],
      "weaknesses": [
        "Can lose fertility without crop rotation",
        "Prone to flooding near rivers",
        "May need zinc and sulfur supplements",
        "Sandy variants dry out fast",
      ],
      "tips": [
        {
          "icon": "🔄",
          "title": "Crop Rotation",
          "text":
              "Rotate between cereals and pulses every season. "
              "Keeps soil healthy for decades.",
        },
        {
          "icon": "💧",
          "title": "Irrigation",
          "text":
              "Moderate watering works well. "
              "Avoid overwatering — nutrients wash away.",
        },
        {
          "icon": "⚗️",
          "title": "Fertilizer",
          "text":
              "Balanced NPK works. Add zinc sulfate "
              "5kg/acre if leaves turn yellow.",
        },
        {
          "icon": "🌱",
          "title": "Organic Matter",
          "text":
              "2 tonnes FYM per acre is enough. "
              "Vermicompost gives best results.",
        },
        {
          "icon": "🌿",
          "title": "Cover Crop",
          "text":
              "Never leave alluvial soil bare — it erodes. "
              "Plant moong between main crops.",
        },
      ],
    },
    "laterite": {
      "name": "Laterite Soil (लेटराइट मिट्टी)",
      "emoji": "🧱",
      "color": 0xFFBF360C,
      "moisture": 0.35,
      "ph": "5.0 - 6.0",
      "description":
          "Formed in hot, humid conditions by leaching. "
          "Low fertility but good for plantation crops with care.",
      "best_crops": [
        {"name": "Cashew", "emoji": "🥜"},
        {"name": "Tea", "emoji": "🍵"},
        {"name": "Coffee", "emoji": "☕"},
        {"name": "Rubber", "emoji": "🌳"},
        {"name": "Coconut", "emoji": "🥥"},
        {"name": "Tapioca", "emoji": "🌱"},
      ],
      "avoid_crops": ["Wheat", "Most vegetables without heavy amendment"],
      "strengths": [
        "Good for plantation/tree crops",
        "Excellent drainage",
        "Hardens into bricks — useful for construction",
        "Responds well to fertilization",
      ],
      "weaknesses": [
        "Very low fertility — heavy leaching",
        "Acidic — needs liming",
        "Low humus and nitrogen",
        "Poor moisture retention",
      ],
      "tips": [
        {
          "icon": "⚗️",
          "title": "Liming",
          "text":
              "Apply 2-3 quintals lime per acre to reduce acidity. "
              "Do this before monsoon.",
        },
        {
          "icon": "💧",
          "title": "Irrigation",
          "text":
              "Frequent light irrigation needed. "
              "Drip irrigation is best for laterite.",
        },
        {
          "icon": "🌱",
          "title": "Heavy Composting",
          "text":
              "Add 5+ tonnes FYM per acre. Laterite soil "
              "desperately needs organic matter.",
        },
        {
          "icon": "🧱",
          "title": "Mulching",
          "text":
              "Thick mulch layer (6 inches) is essential. "
              "Prevents nutrients from washing away.",
        },
        {
          "icon": "🌿",
          "title": "Green Manure",
          "text":
              "Grow sun hemp or dhaincha every year. "
              "Adds nitrogen that laterite soil lacks.",
        },
      ],
    },
    "sandy": {
      "name": "Sandy Soil (रेतीली मिट्टी)",
      "emoji": "🏜️",
      "color": 0xFFFFB74D,
      "moisture": 0.25,
      "ph": "6.0 - 7.0",
      "description":
          "Large particles, very porous. Drains quickly, heats "
          "up fast. Common in Rajasthan and coastal areas.",
      "best_crops": [
        {"name": "Bajra", "emoji": "🌾"},
        {"name": "Groundnut", "emoji": "🥜"},
        {"name": "Watermelon", "emoji": "🍉"},
        {"name": "Cucumber", "emoji": "🥒"},
        {"name": "Dates", "emoji": "🌴"},
        {"name": "Guar", "emoji": "🌱"},
      ],
      "avoid_crops": ["Rice", "Banana", "Sugarcane"],
      "strengths": [
        "Very easy to plough and work",
        "Warms up fast in spring",
        "No waterlogging ever",
        "Good for root vegetables",
      ],
      "weaknesses": [
        "Very poor moisture retention",
        "Nutrients wash away quickly",
        "Low organic matter",
        "Needs constant irrigation",
      ],
      "tips": [
        {
          "icon": "💧",
          "title": "Irrigation",
          "text":
              "Drip irrigation mandatory. Water daily in summer. "
              "Flood irrigation wastes 60% water in sandy soil.",
        },
        {
          "icon": "🌱",
          "title": "Organic Matter",
          "text":
              "Add as much compost as possible — 5+ tonnes/acre. "
              "This is the #1 thing to improve sandy soil.",
        },
        {
          "icon": "🧱",
          "title": "Mulching",
          "text":
              "Thick mulch is critical. Reduces evaporation "
              "by 50%. Use straw, leaves, or plastic mulch.",
        },
        {
          "icon": "🪱",
          "title": "Vermicompost",
          "text":
              "Vermicompost works better than FYM in sandy soil. "
              "Holds 9x its weight in moisture.",
        },
        {
          "icon": "🌿",
          "title": "Windbreaks",
          "text":
              "Plant rows of trees around fields. "
              "Reduces wind erosion and evaporation.",
        },
      ],
    },
    "clay": {
      "name": "Clay Soil (चिकनी मिट्टी)",
      "emoji": "🟤",
      "color": 0xFF5D4037,
      "moisture": 0.80,
      "ph": "7.0 - 8.0",
      "description":
          "Very fine particles, holds water tightly. "
          "Fertile but hard to work. Needs good management.",
      "best_crops": [
        {"name": "Rice", "emoji": "🌾"},
        {"name": "Wheat", "emoji": "🌾"},
        {"name": "Cotton", "emoji": "🌿"},
        {"name": "Lentils", "emoji": "🫘"},
        {"name": "Cabbage", "emoji": "🥬"},
        {"name": "Broccoli", "emoji": "🥦"},
      ],
      "avoid_crops": ["Carrot", "Potato (tubers deform)"],
      "strengths": [
        "Very high fertility",
        "Excellent water retention",
        "Rich in nutrients",
        "Good for paddy/rice cultivation",
      ],
      "weaknesses": [
        "Very poor drainage — waterlogging risk",
        "Extremely hard to plough when dry",
        "Sticky and heavy when wet",
        "Slow to warm up in spring",
      ],
      "tips": [
        {
          "icon": "🚜",
          "title": "Ploughing",
          "text":
              "Plough only at right moisture level. "
              "Too wet = clumps. Too dry = impossible.",
        },
        {
          "icon": "🌱",
          "title": "Add Sand + Compost",
          "text":
              "Mix river sand + FYM to improve drainage. "
              "1 tonne sand + 2 tonnes FYM per acre.",
        },
        {
          "icon": "💧",
          "title": "Drainage",
          "text":
              "Make raised beds for vegetables. "
              "Dig drainage channels to prevent waterlogging.",
        },
        {
          "icon": "🪱",
          "title": "Earthworms",
          "text":
              "Encourage earthworms — they break up clay naturally. "
              "Add cow dung to attract them.",
        },
        {
          "icon": "🌿",
          "title": "Green Manure",
          "text":
              "Deep-rooted green manure (sun hemp) breaks up "
              "hard clay layers. Plant before monsoon.",
        },
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final soil = soilData[userSoilType] ?? soilData["black_cotton"]!;
    final soilColor = Color(soil["color"] as int);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Your Soil'),
        backgroundColor: Colors.white,
        foregroundColor: AgriChainTheme.darkText,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SOIL IDENTITY CARD ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    soilColor.withValues(alpha: 0.8),
                    soilColor.withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    soil["emoji"] as String,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    soil["name"] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    soil["description"] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _soilStat(
                        "💧 Moisture",
                        "${((soil["moisture"] as double) * 100).round()}%",
                      ),
                      _soilStat("⚗️ pH", soil["ph"] as String),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── MOISTURE METER ──
            const Text(
              "Moisture Retention",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: soil["moisture"] as double,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                color: (soil["moisture"] as double) > 0.6
                    ? Colors.blue
                    : (soil["moisture"] as double) > 0.35
                    ? Colors.orange
                    : Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                (soil["moisture"] as double) > 0.6
                    ? "High — needs less watering"
                    : (soil["moisture"] as double) > 0.35
                    ? "Medium — regular watering needed"
                    : "Low — frequent watering essential",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 20),

            // ── BEST CROPS ──
            const Text(
              "✅ Best Crops for Your Soil",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (soil["best_crops"] as List).map((crop) {
                return Chip(
                  avatar: Text(
                    crop["emoji"],
                    style: const TextStyle(fontSize: 16),
                  ),
                  label: Text(
                    crop["name"],
                    style: const TextStyle(fontSize: 13),
                  ),
                  backgroundColor: Colors.green[50],
                  side: BorderSide(color: Colors.green[200]!),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── AVOID CROPS ──
            const Text(
              "❌ Avoid These Crops",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (soil["avoid_crops"] as List).map((crop) {
                return Chip(
                  label: Text(
                    crop.toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                  backgroundColor: Colors.red[50],
                  side: BorderSide(color: Colors.red[200]!),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── STRENGTHS & WEAKNESSES ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildListCard(
                    "💪 Strengths",
                    Colors.green,
                    soil["strengths"] as List,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildListCard(
                    "⚠️ Weaknesses",
                    Colors.orange,
                    soil["weaknesses"] as List,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── FARMING TIPS ──
            const Text(
              "🧑‍🌾 Farming Tips for Your Soil",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(soil["tips"] as List).map((tip) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tip["icon"], style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip["title"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip["text"],
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _soilStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildListCard(String title, Color color, List items) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• ",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: const TextStyle(fontSize: 12, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
