#!/usr/bin/env python
"""
Joins the existentials.csv output with a speaker demographics CSV,
aligning on the participant code embedded in the speaker filename stem.

The existentials CSV has speaker IDs like "conyce_AC", "conyce_AD-2".
The demographics CSV has a "Participant Code" column with values like
"AC", "AD-2".

Output: a merged CSV
"""

import argparse
import pandas as pd
from pathlib import Path


def extract_participant_code(speaker: str) -> str:
    """
    Strip the corpus prefix from a speaker ID.
    e.g. "conyce_AC" -> "AC", "conyce_AD-2" -> "AD-2"
    """
    parts = speaker.split("_", maxsplit=1)
    return parts[1] if len(parts) > 1 else speaker


def merge(existentials_path: Path, demographics_path: Path,
          output_path: Path):
    exist = pd.read_csv(existentials_path)
    demo  = pd.read_csv(demographics_path)

    exist["Participant Code"] = exist["speaker"].apply(
        extract_participant_code
    )

    merged = exist.merge(demo, on="Participant Code", how="left")
    merged = merged.drop(columns=["Participant Code"])

    merged.to_csv(output_path, index=False, encoding="utf-8")
    print(f"Merged {len(merged)} rows. Output written to '{output_path}'.")


def main():
    parser = argparse.ArgumentParser(
        description="Merge existentials counts with speaker demographics."
    )
    parser.add_argument(
        "--existentials", "-e",
        required=True,
        help="Path to existentials.csv (output of extract_existentials.py).",
    )
    parser.add_argument(
        "--demographics", "-d",
        required=True,
        help="Path to the demographics CSV.",
    )
    parser.add_argument(
        "--output", "-o",
        default="merged.csv",
        help="Path for the merged output CSV (default: merged.csv).",
    )
    args = parser.parse_args()

    merge(
        Path(args.existentials),
        Path(args.demographics),
        Path(args.output),
    )


if __name__ == "__main__":
    main()
