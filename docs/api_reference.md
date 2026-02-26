# AgriChain API Reference

Base URL: `http://localhost:8000/api/v1`

All authenticated endpoints require the header:
```
Authorization: Bearer <token>
```

---

## Health Check

### `GET /health`

Returns the health status of the API.

**Auth Required:** No

**Request:** None

**Response:**
```json
{
  "status": "ok",
  "version": "1.0.0"
}
```

---

## Authentication

### `POST /auth/send-otp`

Send a one-time password to the given phone number.

**Auth Required:** No

**Request Body:**
```json
{
  "phone": "9999999999"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "OTP sent successfully"
}
```

---

### `POST /auth/verify-otp`

Verify the OTP and receive an authentication token.

**Auth Required:** No

**Request Body:**
```json
{
  "phone": "9999999999",
  "otp": "123456"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "phone": "9999999999",
    "name": "Ramesh",
    "created_at": "2026-02-26T10:00:00Z"
  }
}
```

**Response (401 — Wrong OTP):**
```json
{
  "detail": "Invalid OTP"
}
```

---

## Harvest

### `POST /harvest/score`

Calculate a harvest readiness score (0-100) for the given conditions.

**Auth Required:** Yes

**Request Body:**
```json
{
  "crop_id": "tomato",
  "quantity_kg": 800,
  "soil_type": "black",
  "temperature": 32,
  "humidity": 65
}
```

| Field          | Type   | Required | Description                        |
|---------------|--------|----------|------------------------------------|
| crop_id       | string | Yes      | ID from crops.json                 |
| quantity_kg   | number | Yes      | Harvest quantity in kg             |
| soil_type     | string | Yes      | ID from soil_types.json            |
| temperature   | number | Yes      | Current temperature in °C          |
| humidity      | number | Yes      | Current relative humidity (%)      |

**Response (200):**
```json
{
  "score": 78,
  "explanation": "Good conditions for harvest. Temperature is within optimal range...",
  "factors": {
    "weather": 80,
    "soil": 85,
    "market_timing": 70
  },
  "recommendation": "harvest_now"
}
```

---

## Market

### `POST /market/compare`

Compare mandi prices for a crop and compute pocket cash (net revenue).

**Auth Required:** Yes

**Request Body:**
```json
{
  "crop_id": "tomato",
  "quantity_kg": 800,
  "lat": 21.1458,
  "lng": 79.0882
}
```

| Field        | Type   | Required | Description                          |
|-------------|--------|----------|--------------------------------------|
| crop_id     | string | Yes      | ID from crops.json                   |
| quantity_kg | number | Yes      | Quantity in kg                       |
| lat         | number | Yes      | Farmer's current latitude            |
| lng         | number | Yes      | Farmer's current longitude           |

**Response (200):**
```json
{
  "mandis": [
    {
      "mandi": "Wardha APMC",
      "price_per_kg": 15,
      "distance_km": 12,
      "transport_cost": 600,
      "gross_revenue": 12000,
      "pocket_cash": 11400,
      "recommended": true
    },
    {
      "mandi": "Nashik APMC",
      "price_per_kg": 25,
      "distance_km": 580,
      "transport_cost": 8000,
      "gross_revenue": 20000,
      "pocket_cash": 12000,
      "recommended": false
    }
  ]
}
```

---

## Spoilage

### `POST /spoilage/check`

Check remaining shelf life for a crop under current conditions.

**Auth Required:** Yes

**Request Body:**
```json
{
  "crop_id": "tomato",
  "storage_method": "open_floor",
  "temperature": 32,
  "hours_since_harvest": 12
}
```

| Field               | Type   | Required | Description                            |
|--------------------|--------|----------|----------------------------------------|
| crop_id            | string | Yes      | ID from crops.json                     |
| storage_method     | string | Yes      | One of: open_floor, jute_bags, plastic_crates, cold_storage |
| temperature        | number | Yes      | Current temperature in °C              |
| hours_since_harvest| number | Yes      | Hours elapsed since harvest            |

**Response (200):**
```json
{
  "remaining_hours": 36,
  "urgency": "medium",
  "total_shelf_life": 48,
  "spoilage_percentage": 25.0,
  "advice": "Sell within 36 hours or upgrade to plastic crates for 36 more hours."
}
```

---

## Preservation

### `POST /preservation/options`

Get preservation methods ranked by cost and effectiveness.

**Auth Required:** Yes

**Request Body:**
```json
{
  "crop_id": "tomato",
  "budget_rupees": 100
}
```

| Field         | Type   | Required | Description                     |
|--------------|--------|----------|---------------------------------|
| crop_id      | string | Yes      | ID from crops.json              |
| budget_rupees| number | No       | Maximum budget in ₹ (optional) |

**Response (200):**
```json
{
  "methods": [
    {
      "id": "wet_jute",
      "name_en": "Wet Jute Bag Cover",
      "name_hi": "गीली जूट की बोरी से ढकना",
      "level": 1,
      "cost_rupees": 0,
      "extra_days": 1,
      "saves_rupees": 200,
      "instructions_en": "Step 1: Soak jute bags...",
      "instructions_hi": "चरण 1: जूट की बोरियों को...",
      "effectiveness": "basic",
      "requires_purchase": false
    }
  ]
}
```
