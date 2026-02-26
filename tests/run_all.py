"""
Run all AgriChain tests — data validation and tool unit tests.
"""

import subprocess
import sys

sections = [
    ("Data Validation Tests", "tests/test_data/"),
    ("Tool Unit Tests", "tests/test_tools/"),
]

all_passed = True
for name, path in sections:
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"{'='*60}")
    result = subprocess.run(
        [sys.executable, "-m", "pytest", path, "-v"],
        cwd=".",
    )
    if result.returncode != 0:
        all_passed = False

print(f"\n{'='*60}")
if all_passed:
    print("  ALL TESTS PASSED ✅")
else:
    print("  SOME TESTS FAILED — review output above ❌")
print(f"{'='*60}")

sys.exit(0 if all_passed else 1)
