"""
cache.py — Simple in-memory TTL cache for agent responses.

Prevents Gemini API rate limits when the Flutter app or testers
hammer the endpoints repeatedly with the same data.
"""

import time
import hashlib
import json


class SimpleCache:
    def __init__(self, ttl_seconds: int = 300):
        self._cache: dict = {}
        self._ttl = ttl_seconds

    def make_key(self, *args) -> str:
        raw = json.dumps(args, sort_keys=True, default=str)
        return hashlib.md5(raw.encode()).hexdigest()

    def get(self, key: str):
        if key in self._cache:
            value, timestamp = self._cache[key]
            if time.time() - timestamp < self._ttl:
                return value
            else:
                del self._cache[key]
        return None

    def set(self, key: str, value):
        self._cache[key] = (value, time.time())

    def clear(self):
        self._cache.clear()

    @property
    def size(self) -> int:
        return len(self._cache)


# Global cache instance — 5 minute TTL
agent_cache = SimpleCache(ttl_seconds=300)
