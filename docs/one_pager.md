# AgriChain — Farm to Market Intelligence

## Problem

Indian farmers lose **30% of crops** to post-harvest spoilage. They sell at the nearest mandi, not the most profitable one. The result: lower income despite hard work.

## Solution

4 AI agents that calculate:
- **Best harvest timing** — weather + market + soil analysis → score 0-100
- **Most profitable mandi** — "pocket cash" ranking after fuel + spoilage costs
- **Real-time freshness** — hours remaining before crop spoils
- **Preservation advice** — storage methods ranked by ROI with step-by-step instructions

## Key Insight

> The highest-priced mandi is not always the most profitable.

AgriChain calculates **"pocket cash"** — what actually reaches the farmer after fuel costs and crop spoilage during transport. A nearby mandi at ₹15/kg often beats a far mandi at ₹22/kg.

## Technology

- **Multi-agent AI**: LangGraph + Google Gemini 2.0 Flash
- **4 specialized agents** with 7 backend tools
- **Explainable recommendations** in Hindi (Devanagari)
- **Flutter mobile app** designed for low-literacy users
- **Real-time integration**: OpenWeatherMap + mandi price data

## Impact

Estimated **₹3,000-5,000** additional income per farmer per harvest cycle through:
- Smarter mandi selection (₹800-1,200 saved per trip)
- Reduced spoilage (₹300-500 saved per batch)
- Better harvest timing (₹500-600 gained per cycle)
- Low-cost preservation (₹500+ saved per batch)

## Team

| Role | Owner | Deliverables |
|------|-------|-------------|
| Backend + AI Agents | J | FastAPI, tools, agents, database |
| Backend Architecture | G | Models, API scaffold, config |
| Mobile App | M | Flutter app, UI/UX |
