# ============================================================
# Combined mixed-effects logistic regression
#
# Predicts singular (1) vs. plural (0) existential agreement
# using Year of Birth, Gender, and Household Language
# Background, with a random intercept for speaker. 
#
# Adds chi-square test of independence for tense x agreement.
# ============================================================

library(jmvReadWrite)
library(lme4)

# ------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------

df <- jmvReadWrite::read_omv(
  "/Users/sophiebrown/regression_results_combined_2.omv"
)

# Convert column names to R-friendly names
names(df) <- make.names(names(df), unique = TRUE)

# ------------------------------------------------------------
# 2. Set variable types
# ------------------------------------------------------------

df$Outcome <- factor(
  as.character(df$Outcome),
  levels = c("0", "1")
)

df$Gender <- factor(df$Gender)

df$Household.language.background <-
  factor(df$Household.language.background)

df$speaker <- factor(df$speaker)

df$Year.of.Birth <-
  as.numeric(as.character(df$Year.of.Birth))

# ------------------------------------------------------------
# 3. Fit model
# ------------------------------------------------------------

model_combined <- glmer(
  Outcome ~
    Year.of.Birth +
    Gender +
    Household.language.background +
    (1 | speaker),
  data = df,
  family = binomial(link = "logit")
)

# ------------------------------------------------------------
# 4. Display model results
# ------------------------------------------------------------

summary(model_combined)

# ------------------------------------------------------------
# 5. Chi-square test of independence
# ------------------------------------------------------------

tab <- table(df$tense,df$Outcome)
chi <- chisq.test(tab, correct = FALSE)
chi

# ------------------------------------------------------------
# 6. Save fitted model
# ------------------------------------------------------------

saveRDS(
  model_combined,
  "output/combined_model.rds"
)