# ============================================================
# Model statistics and comparison
#
# Loads the combined, present, and past mixed-effects models
# and calculates statistics used in the paper.
# ============================================================

library(lme4)
library(performance)
library(broom.mixed)

# ------------------------------------------------------------
# 1. Load fitted models
# ------------------------------------------------------------

model_combined <- readRDS(
  "output/combined_model.rds"
)

model_present <- readRDS(
  "output/present_model.rds"
)

model_past <- readRDS(
  "output/past_model.rds"
)

# ------------------------------------------------------------
# 2. Fixed effects: odds ratios and confidence intervals
# ------------------------------------------------------------

combined_fixed <- broom.mixed::tidy(
  model_combined,
  effects = "fixed",
  conf.int = TRUE,
  conf.level = 0.95,
  exponentiate = TRUE
)

present_fixed <- broom.mixed::tidy(
  model_present,
  effects = "fixed",
  conf.int = TRUE,
  conf.level = 0.95,
  exponentiate = TRUE
)

past_fixed <- broom.mixed::tidy(
  model_past,
  effects = "fixed",
  conf.int = TRUE,
  conf.level = 0.95,
  exponentiate = TRUE
)

# ------------------------------------------------------------
# 3. Marginal and conditional R-squared
# ------------------------------------------------------------

r2_combined <- performance::r2_nakagawa(
  model_combined
)

r2_present <- performance::r2_nakagawa(
  model_present
)

r2_past <- performance::r2_nakagawa(
  model_past
)

# ------------------------------------------------------------
# 4. Intraclass correlation coefficients
# ------------------------------------------------------------

icc_combined <- performance::icc(
  model_combined
)

icc_present <- performance::icc(
  model_present
)

icc_past <- performance::icc(
  model_past
)

# ------------------------------------------------------------
# 5. Speaker random-intercept variance
# ------------------------------------------------------------

speaker_var_combined <- as.numeric(
  VarCorr(model_combined)$speaker
)

speaker_var_present <- as.numeric(
  VarCorr(model_present)$speaker
)

speaker_var_past <- as.numeric(
  VarCorr(model_past)$speaker
)

# ------------------------------------------------------------
# 6. Build model comparison table
# ------------------------------------------------------------

comparison <- data.frame(
  Model = c(
    "Present tense",
    "Past tense",
    "Combined"
  ),
  
  Tokens = c(
    nobs(model_present),
    nobs(model_past),
    nobs(model_combined)
  ),
  
  Groups = c(
    ngrps(model_present),
    ngrps(model_past),
    ngrps(model_combined)
  ),
  
  Speaker_variance = c(
    speaker_var_present,
    speaker_var_past,
    speaker_var_combined
  ),
  
  ICC = c(
    icc_present$ICC_adjusted,
    icc_past$ICC_adjusted,
    icc_combined$ICC_adjusted
  ),
  
  Marginal_R2 = c(
    r2_present$R2_marginal,
    r2_past$R2_marginal,
    r2_combined$R2_marginal
  ),
  
  Conditional_R2 = c(
    r2_present$R2_conditional,
    r2_past$R2_conditional,
    r2_combined$R2_conditional
  )
)

comparison