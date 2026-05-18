#!/usr/bin/env python
"""
Scans a folder of Praat TextGrid files (one per speaker) and counts instances
of existential constructions followed by a plural noun:
 
    "there is [PL. NOUN]"
    "there's [PL. NOUN]"
    "there are [PL. NOUN]"
    "there be [PL. NOUN]"
    "there was [PL. NOUN]"
    "there were [PL. NOUN]"
 
Output: a CSV file with per-speaker counts broken down by construction type,
plus raw matched tokens.
"""
 
import argparse
import csv
import re
from pathlib import Path
 

import spacy
import tgt
 

nlp = spacy.load("en_core_web_sm") 


# Construction patterns (label, compiled_regex)
PATTERNS = [
    ("there_is",  re.compile(r"\bthere\s+is\s+(\w+)", re.IGNORECASE)),
    ("theres",    re.compile(r"\bthere's\s+(\w+)",    re.IGNORECASE)),
    ("there_are", re.compile(r"\bthere\s+are\s+(\w+)", re.IGNORECASE)),
    ("there_be",  re.compile(r"\bthere\s+be\s+(\w+)", re.IGNORECASE)),
    ("there_was",  re.compile(r"\bthere\s+was\s+(\w+)",  re.IGNORECASE)),
    ("there_were", re.compile(r"\bthere\s+were\s+(\w+)", re.IGNORECASE))
]
 
CONSTRUCTION_LABELS = [label for label, _ in PATTERNS]
 

# TextGrid text extraction 
def extract_via_tgt(path: Path) -> str:
    for encoding in ("utf-8", "utf-16", "utf-16-le", "utf-16-be", "latin-1"):
        try:
            tg = tgt.io.read_textgrid(str(path), encoding=encoding)
            chunks = []
            for tier in tg.tiers:
                if hasattr(tier, "intervals"):
                    for interval in tier.intervals:
                        if interval.text.strip():
                            chunks.append(interval.text.strip())
                elif hasattr(tier, "points"):
                    for point in tier.points:
                        if point.text.strip():
                            chunks.append(point.text.strip())
            return " ".join(chunks)
        except (UnicodeDecodeError, ValueError):
            continue
        except IndexError:
            print(f"[WARNING] Skipping {path.name}: malformed TextGrid structure")
            return ""
    raise ValueError(
        f"Could not decode {path.name} "
        "— tried utf-8, utf-16, utf-16-le, utf-16-be, latin-1"
    )


def extract_text_from_textgrid(path: Path) -> str:
    """Return all interval/point text from a TextGrid as one lowercased 
    string."""
    return extract_via_tgt(path)


# Extracting existential phrases with plural nouns using spaCy 
def count_constructions(text: str) -> dict:
    """Given a context window, return a dict mapping each construction label to
    a list of matched tokens (the noun following the trigger phrase)."""
    results = {label: [] for label in CONSTRUCTION_LABELS}

    for label, pattern in PATTERNS:
        for match in pattern.finditer(text):
            noun_candidate = match.group(1)

            window_start = max(0, match.start() - 50)
            window = text[window_start : match.end() + 50]
            doc = nlp(window)

            noun_offset = (match.start() - window_start + len(match.group(0)) - 
                           len(noun_candidate))
            token = next((t for t in doc if t.idx == noun_offset), None)
            tag = token.tag_ if token else nlp(noun_candidate)[0].tag_

            if tag in ("NNS", "NNPS"):
                results[label].append(match.group(0).lower())

    return results


def process_corpus(input_dir: Path, output_path: Path):
    textgrid_files = sorted(input_dir.glob("*.TextGrid"))
  
    rows = []
 
    for tg_path in textgrid_files:
        speaker_id = tg_path.stem    
        text    = extract_text_from_textgrid(tg_path)
        counts  = count_constructions(text)
 
        total = sum(len(v) for v in counts.values())
 
        row = {
            "speaker":    speaker_id,
            "total":      total,
        }
        for label in CONSTRUCTION_LABELS:
            row[f"n_{label}"] = len(counts[label])
 
        for label in CONSTRUCTION_LABELS:
            row[f"tokens_{label}"] = " | ".join(counts[label]) if counts[label] else ""
 
        rows.append(row)
 
    # Write CSV
    fieldnames = (
        ["speaker", "total"]
        + [f"n_{label}" for label in CONSTRUCTION_LABELS]
        + [f"tokens_{label}" for label in CONSTRUCTION_LABELS]
    )
 
    with output_path.open("w", newline="", encoding="utf-8") as sink:
        writer = csv.DictWriter(sink, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
 
    print(f"\nResults written to '{output_path}'.")


def main():
    parser = argparse.ArgumentParser(
        description="Extract existential constructions from Praat TextGrids."
    )
    parser.add_argument(
        "--input", "-i",
        required=True,
        help="Directory containing .TextGrid files (one per speaker).",
    )
    parser.add_argument(
        "--output", "-o",
        default="existentials.csv",
        help="Path for the output CSV (default: existentials.csv).",
    )
    args = parser.parse_args()
 
    input_dir   = Path(args.input)
    output_path = Path(args.output)
 
    process_corpus(input_dir, output_path)
 
 
if __name__ == "__main__":
    main()