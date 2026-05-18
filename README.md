conyce-data
===========

Two command-line tools for corpus linguists to extract constructions of interest from the Corpus of NYC English and join the output with a speaker demographics CSV (both locally saved).

extract_existentials.py
=======================

Scans a directory of Praat TextGrid files and counts instances of existential constructions followed by a plural noun:

* there is  [PL. NOUN]
* there's   [PL. NOUN]
* there be  [PL. NOUN]
* there are [PL. NOUN]   <- canonical
* there was [PL. NOUN]
* there were [PL. NOUN]  <- canonical

Note: non-canonical agreement = "there is/'s/be/was" with a plural noun

Results are written to a CSV with per-speaker counts and the raw matched tokens for manual review.

Dependencies:
-------------

Praat TextGrid parsing:

`pip install tgt spacy`

spaCy + English model for POS tagging:

`python -m spacy download en_core_web_sm`

Usage:
------

`python extract_existentials.py --input /local/path/to/textgrids --output results.csv`

merge_demographics.py
=====================

Joins the existentials.csv output of `extract_existentials.py` with a speaker demographics CSV, aligning on the participant code embedded in the speaker filename stem.

Usage:
------

```
    python merge_demographics.py \
        --existentials existentials.csv \
        --demographics demographics.csv \
        --output merged.csv
```
