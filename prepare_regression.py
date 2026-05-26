#!/usr/bin/env python
"""
Reshapes merged.csv from one-row-per-speaker to one-row-per-token,
adds the binary outcome variable, and adds columns for linguistic
predictors.

Outcomes: 1 = singular agreement, 0 = plural agreement
"""

import argparse
import pandas as pd
from pathlib import Path


CONSTRUCTION_META = {
    "there_is":   {"agreement": "singular", "contracted": 0, "tense": "present"},
    "theres":     {"agreement": "singular", "contracted": 1, "tense": "present"},
    "there_are":  {"agreement": "plural",   "contracted": 0, "tense": "present"},
    "there_be":   {"agreement": "plural",   "contracted": 0, "tense": "present"},
    "there_was":  {"agreement": "singular", "contracted": 0, "tense": "past"},
    "there_were": {"agreement": "plural",   "contracted": 0, "tense": "past"},
}

def expand_tokens(row: dict) -> list[dict]:
    """Convert one speaker row into one dict per token."""
    records = []
    for label, meta in CONSTRUCTION_META.items():
        col = f"tokens_{label}"
        # Checks whether column exists
        if col not in row or pd.isna(row[col]) or str(row[col]).strip() == "":
            continue
        # Converts column value to list of strings
        tokens = [t.strip() for t in str(row[col]).split("|") if t.strip()]
        # Adds linguistic predictors
        for token in tokens:
            record = {
                "speaker":       row["speaker"],
                "token":         token,
                "outcome":       1 if meta["agreement"] == "singular" else 0,
                "construction":  label,
                "contracted":    meta["contracted"],
                "tense":         meta["tense"],
            }
            # Avoid copying summary/count columns
            for col in row.index:
                if col not in record and not col.startswith(
                    ("n_", "tokens_", "total")
                ):
                    record[col] = row[col]
            records.append(record)
    return records


def prepare(input_path: Path, output_path: Path):
    df = pd.read_csv(input_path)
    rows = []
    for _, row in df.iterrows():
        rows.extend(expand_tokens(row))

    out = pd.DataFrame(rows)
    out.to_csv(output_path, index=False, encoding="utf-8")
    print(f"Wrote {len(out)} token-level rows to '{output_path}'.")
    print(f"Outcome distribution:\n{out['outcome'].value_counts().to_string()}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input",  "-i", required=True)
    parser.add_argument("--output", "-o", default="regression_input.csv")
    args = parser.parse_args()
    prepare(Path(args.input), Path(args.output))


if __name__ == "__main__":
    main()
