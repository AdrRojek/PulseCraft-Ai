"""Download public pose/form datasets (metadata only in repo).

Usage:
    python -m ml.download_dataset --out data/raw

Does not commit large raw dumps; writes manifest JSON.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path


SAMPLE_MANIFEST = {
    "sources": [
        {"name": "openpose-samples", "license": "research-only", "url": "https://example.com/dataset"},
    ]
}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=Path, default=Path("data/raw"))
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    manifest = args.out / "manifest.json"
    manifest.write_text(json.dumps(SAMPLE_MANIFEST, indent=2), encoding="utf-8")
    print(f"Wrote {manifest}")


if __name__ == "__main__":
    main()
