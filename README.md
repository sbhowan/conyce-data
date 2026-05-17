extract_existentials.py
=======================

A command-line tool for corpus linguists. Scans a directory of Praat TextGrid files from the Corpus of NYC English and counts instances of existential constructions followed by a plural noun:

* there is  [PL. NOUN]
* there's   [PL. NOUN]
* there be  [PL. NOUN]
* there are [PL. NOUN]   <- canonical
* there was [PL. NOUN]
* there were [PL. NOUN]  <- canonical

Note: non-canonical agreement = "there is/'s/be/WAS" with a plural noun

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
