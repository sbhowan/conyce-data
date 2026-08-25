# ============================================================
# Past-tense mixed-effects logistic regression
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
# 2. Keep past-tense tokens only
# ------------------------------------------------------------

df_past <- subset(
  df,
  tense == "past"
)

# Check number of tokens
nrow(df_past)

# ------------------------------------------------------------
# 3. Fit past-tense model
# ------------------------------------------------------------

model_past <- glmer(
  Outcome ~
    Year.of.Birth +
    Gender +
    Household.language.background +
    (1 | speaker),
  data = df_past,
  family = binomial(link = "logit")
)

# ------------------------------------------------------------
# 4. Display results
# ------------------------------------------------------------

summary(model_past)

# ------------------------------------------------------------
# 5. Save fitted model
# ------------------------------------------------------------

saveRDS(
  model_past,
  "output/past_model.rds"
)