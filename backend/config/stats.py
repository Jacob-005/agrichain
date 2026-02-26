"""
stats.py — Request counting and success rate tracking.

Useful for demo: "Our system handled X requests with Y% success rate."
"""

import time


class RequestStats:
    def __init__(self):
        self.started_at = time.time()
        self.counts = {
            "total": 0,
            "success": 0,
            "error": 0,
            "cache_hit": 0,
            "by_agent": {
                "harvest": 0,
                "market": 0,
                "spoilage": 0,
                "preservation": 0,
                "chat": 0,
                "voice": 0,
            },
        }

    def record(self, agent: str, success: bool, cached: bool = False):
        self.counts["total"] += 1
        if success:
            self.counts["success"] += 1
        else:
            self.counts["error"] += 1
        if cached:
            self.counts["cache_hit"] += 1
        if agent in self.counts["by_agent"]:
            self.counts["by_agent"][agent] += 1

    def get_summary(self) -> dict:
        uptime = int(time.time() - self.started_at)
        total = max(1, self.counts["total"])
        return {
            "uptime_seconds": uptime,
            "uptime_minutes": round(uptime / 60, 1),
            **self.counts,
            "success_rate": round(self.counts["success"] / total * 100, 1),
            "cache_hit_rate": round(self.counts["cache_hit"] / total * 100, 1),
        }


# Global stats instance
stats = RequestStats()
