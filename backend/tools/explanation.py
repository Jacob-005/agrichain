"""
explanation.py — LLM-powered explanation generator using Google Gemini.

Falls back to template strings if API key is missing or call fails.
"""

import os

_llm = None


def get_llm():
    """Lazy-load the Gemini LLM singleton."""
    global _llm
    if _llm is None:
        try:
            from langchain_google_genai import ChatGoogleGenerativeAI

            api_key = os.getenv("GOOGLE_API_KEY", "")
            if not api_key:
                raise ValueError("No GOOGLE_API_KEY set")

            _llm = ChatGoogleGenerativeAI(
                model="gemini-2.0-flash",
                temperature=0.7,
                google_api_key=api_key,
            )
        except Exception as e:
            print(f"LLM init error: {e}")
            _llm = None
    return _llm


SYSTEM_PROMPT = (
    "You are a friendly agricultural advisor speaking to an Indian "
    "farmer in simple {language}. Use short sentences. Never use "
    "English technical terms unless no local word exists. Always "
    "mention specific rupee amounts with the ₹ symbol. The farmer "
    "may have limited formal education. Be warm, supportive, and "
    "direct. Keep your response under 100 words."
)

USER_PROMPTS = {
    "harvest": (
        "Based on this data, explain why the harvest score is "
        "{score}/100 and what the farmer should do next: {context}"
    ),
    "market": (
        "Explain why {recommended_mandi} is the best place to sell, "
        "considering price, distance, and spoilage during transport. "
        "Data: {context}"
    ),
    "spoilage": (
        "The farmer's {crop} has {remaining_hours} hours left before "
        "it spoils. Explain the urgency and what action they should "
        "take immediately: {context}"
    ),
    "preservation": (
        "Explain why {method} is worth the ₹{cost} investment to "
        "protect their {crop}: {context}"
    ),
}

FALLBACK_RESPONSES = {
    "harvest": (
        "Your harvest score is {score}/100. Higher means better time "
        "to harvest. Check weather and market prices."
    ),
    "market": (
        "We recommend selling at the nearest mandi with best price "
        "after transport costs."
    ),
    "spoilage": (
        "Your crop needs attention soon. Consider better storage "
        "or selling quickly."
    ),
    "preservation": (
        "Better storage can help your crop last longer and save money."
    ),
}


def generate_explanation(
    context: dict, language: str = "hindi", explanation_type: str = "harvest"
) -> str:
    """
    Generate an LLM-powered explanation using Gemini.
    Raises on failure — use generate_explanation_safe for production.
    """
    from langchain_core.messages import SystemMessage, HumanMessage

    llm = get_llm()
    if llm is None:
        raise RuntimeError("LLM not available")

    system_msg = SystemMessage(content=SYSTEM_PROMPT.format(language=language))

    prompt_template = USER_PROMPTS.get(explanation_type, USER_PROMPTS["harvest"])
    # Format with available context keys, using defaults for missing ones
    safe_context = {
        "score": context.get("score", "N/A"),
        "context": str(context),
        "recommended_mandi": context.get("recommended_mandi", "nearest mandi"),
        "crop": context.get("crop", "your crop"),
        "remaining_hours": context.get("remaining_hours", "unknown"),
        "method": context.get("method", "this method"),
        "cost": context.get("cost", "0"),
    }
    user_msg = HumanMessage(content=prompt_template.format(**safe_context))

    response = llm.invoke([system_msg, user_msg])
    return response.content


def generate_explanation_safe(
    context: dict, language: str = "hindi", explanation_type: str = "harvest"
) -> str:
    """
    Safe wrapper — always returns a string, never crashes.
    Falls back to template responses if LLM fails.
    """
    try:
        return generate_explanation(context, language, explanation_type)
    except Exception as e:
        print(f"LLM Error: {e}")

        # Try to format the fallback with available context
        fallback_template = FALLBACK_RESPONSES.get(
            explanation_type, FALLBACK_RESPONSES["harvest"]
        )
        try:
            safe_context = {
                "score": context.get("score", "N/A"),
                "crop": context.get("crop", "your crop"),
                "remaining_hours": context.get("remaining_hours", "unknown"),
                "method": context.get("method", "this method"),
                "cost": context.get("cost", "0"),
            }
            return fallback_template.format(**safe_context)
        except Exception:
            return fallback_template


if __name__ == "__main__":
    print("=== Explanation Tool Self-Test ===")
    test_context = {
        "score": 78,
        "crop": "tomato",
        "temp_c": 35,
        "price_trend": "rising",
        "recommended_mandi": "Kalamna Mandi",
        "remaining_hours": 36,
        "method": "clay pot cooling",
        "cost": 50,
    }

    for etype in ["harvest", "market", "spoilage", "preservation"]:
        result = generate_explanation_safe(test_context, "hindi", etype)
        print(f"\n[{etype}] {result[:100]}...")
