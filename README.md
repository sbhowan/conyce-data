# Agreement optionality of existential 'there' in the Corpus of New York City English (CoNYCE)

Three command-line tools for corpus linguists to extract existential constructions from the Corpus of NYC English, join the output with a speaker demographics CSV, and reshape the data from one-row-per-speaker to one-row-per-token for statistical analysis using R, respectively. Both the corpus TextGrids and demographics file are saved locally for privacy reasons, but can be requested [here](https://conyce.commons.gc.cuny.edu).

## `extract_existentials.py`

Scans a directory of Praat TextGrid files and counts instances of existential constructions followed by a plural noun:

* there is  [PL. NOUN]
* there's   [PL. NOUN]
* there be  [PL. NOUN]
* there are [PL. NOUN]   <- canonical
* there was [PL. NOUN]
* there were [PL. NOUN]  <- canonical

Note: non-canonical agreement = "there is/'s/be/was" with a plural noun

Results are written to a CSV with per-speaker counts and the raw matched tokens.

### Dependencies

Praat TextGrid parsing + spaCy:

```
pip install tgt spacy
```

English model for POS tagging: 

```
python -m spacy download en_core_web_sm
```

### Usage

```
    python extract_existentials.py \
        --input /local/path/to/textgrids \
        --output results.csv
```

## `merge_demographics.py`

Joins the existentials.csv output of `extract_existentials.py` with a speaker demographics CSV, aligning on the participant code embedded in the speaker filename stem.

### Usage

```
    python merge_demographics.py \
        --existentials existentials.csv \
        --demographics demographics.csv \
        --output merged.csv
```

## `prepare_regression.py`

Reshapes the merged.csv output from `merge_demographics.py` from one-row-per-speaker to one-row-per-token. Additionally, adds the binary outcome variable as well as columns for linguistic predictors. 

Note: In the Outcomes column, 1 refers to singular agreement ("there is/'s/was [PL. NOUN]"), while 0 refers to plural agreement ("there are/were [PL. NOUN]"). "There be [PL. NOUN]" is an ambiguous case excluded from the analysis, since there is only one such case.

### Usage

```
    python prepare_regression.py \
        --input merged.csv \
        --output regression_input.csv
```
