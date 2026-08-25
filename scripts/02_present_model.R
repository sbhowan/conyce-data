# ============================================================
# Present-tense mixed-effects logistic regression
# ============================================================

library(jmvReadWrite)
library(lme4)

# ------------------------------------------------------------
# 1. Load and prepare data
# ------------------------------------------------------------

df <- jmvReadWrite::read_omv(
  "/Users/sophiebrown/regression_results_combined_2.omv"
)

names(df) <- make.names(names(df), unique = TRUE)

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
# 2. Keep present-tense tokens only
# ------------------------------------------------------------

df_pres <- subset(
  df,
  tense == "present"
)

# Check number of tokens
nrow(df_pres)

# ------------------------------------------------------------
# 3. Fit present-tense model
# ------------------------------------------------------------

model_present <- glmer(
  Outcome ~
    Year.of.Birth +
    Gender +
    Household.language.background +
    (1 | speaker),
  data = df_pres,
  family = binomial(link = "logit")
)

# ------------------------------------------------------------
# 4. Display results
# ------------------------------------------------------------

summary(model_present)

# ------------------------------------------------------------
# 5. Save fitted model
# ------------------------------------------------------------

saveRDS(
  model_present,
  "output/present_model.rds"
)