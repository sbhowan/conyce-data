# Variable agreement with existential 'there' in CoNYCE

This repository contains Python and R scripts for extracting, preparing, and analyzing singular vs. plural agreement in existential constructions in the CUNY Corpus of New York City English (CUNY-CoNYCE).

The analysis uses mixed-effects logistic regression to examine agreement in the combined dataset and separately within present- and past-tense constructions.

Both the corpus TextGrids and demographics file are saved locally for privacy reasons, but can be requested [here](https://conyce.commons.gc.cuny.edu).

## Python dependencies

Praat TextGrid parsing + spaCy:

```
pip install tgt spacy
```

English model for POS tagging: 

```
python -m spacy download en_core_web_sm
```

## Data extraction workflow
1. `extract_existentials.py` - scans a directory of Praat TextGrid files and counts instances of existential constructions followed by a plural noun.

    **Existential constructions of interest:**
   
    * there is  [PL. NOUN]
    * there's   [PL. NOUN]
    * there be  [PL. NOUN]
    * there are [PL. NOUN]   <- canonical
    * there was [PL. NOUN]
    * there were [PL. NOUN]  <- canonical

    **Note:** non-canonical agreement = "there is/'s/be/was" with a plural noun

    ```
        python extract_existentials.py \
            --input /local/path/to/textgrids \
            --output existentials.csv
    ```

    Results are written to a CSV with per-speaker counts and the raw matched tokens.

2. `merge_demographics.py` - joins the output of `extract_existentials.py` with a speaker demographics CSV, aligning on the participant code embedded in the speaker filename stem.

    ```
        python merge_demographics.py \
            --existentials existentials.csv \
            --demographics demographics.csv \
            --output merged.csv
    ```
3. `prepare_regression.py` - reshapes the output from `merge_demographics.py` from one-row-per-speaker to one-row-per-token. Adds the binary outcome variable and columns for linguistic predictors. 

    ```
        python prepare_regression.py \
            --input merged.csv \
            --output regression_input.csv
    ```

    **Note:** In the Outcomes column, 1 refers to singular agreement ("there is/'s/was [PL. NOUN]"), while 0 refers to plural agreement ("there are/were [PL. NOUN]"). "There be [PL. NOUN]" is an ambiguous case excluded from the analysis, since there is only one such case.

## R requirements

The analysis requires the following packages:

```r
install.packages(c(
  "jmvReadWrite",
  "lme4",
  "ggeffects",
  "ggplot2",
  "performance",
  "effectsize",
  "broom.mixed"
))
```

## Analysis workflow

Run the scripts in numerical order:

1. `01_combined_model.R` — fits the mixed-effects model to the combined data and calculates the tense × agreement chi-square test.
2. `02_present_model.R` — fits the model to present-tense tokens.
3. `03_past_model.R` — fits the model to past-tense tokens.
4. `04_model_statistics.R` — calculates odds ratios, confidence intervals, speaker variance, ICC, and marginal/conditional R².
5. `05_create_figures.R` — generates predicted-probability plots.

The regression models predict singular vs. plural agreement from year of birth, gender, and household language background, with a random intercept for speaker.

## Output

Fitted model objects and summary statistics are saved to `output/`. Figures are saved to `plots/`.
