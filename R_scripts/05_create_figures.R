# ============================================================
# Create figures for social predictors
# ============================================================

library(ggeffects)
library(ggplot2)

# ------------------------------------------------------------
# Load fitted combined model
# ------------------------------------------------------------
model_combined <- readRDS(
  "output/combined_model.rds"
)

# YEAR OF BIRTH
pred_yob <- ggeffects::ggpredict(
  model_combined,
  terms = "Year.of.Birth [all]"
)

pred_yob <- ggplot(
  pred_yob,
  aes(x = x, y = predicted, group = 1)
) +
  geom_line(linewidth = 1) +
  geom_ribbon(
    aes(ymin = conf.low, ymax = conf.high),
    alpha = 0.2
  ) +
  scale_x_continuous(
    breaks = seq(
      floor(min(pred_yob$x) / 10) * 10,
      ceiling(max(pred_yob$x) / 10) * 10,
      by = 10
    )
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.2),
    labels = scales::label_percent(accuracy = 1)
  ) +
  labs(
    x = "Year of Birth",
    y = "Predicted Probability of Singular Agreement"
  ) +
  theme_classic() +
  theme(
    text = element_text(family = "serif"),
    plot.title = element_text(
      size = 14,
      hjust = 0.5
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11)
  )

pred_yob

ggsave(
  "plots/outcome_by_yob.png",
  plot = pred_yob,
  width = 7,
  height = 5
)

# HOUSEHOLD LANGUAGE BACKGROUND
pred_hlb <- ggeffects::ggpredict(
  model_combined,
  terms = "Household.language.background [all]"
)

pred_hlb <- ggplot(
  pred_hlb,
  aes(x = x, y = predicted)
) +
  geom_point(size = 3) +
  geom_errorbar(
    aes(ymin = conf.low, ymax = conf.high),
    width = 0.15
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.2),
    labels = scales::label_percent(accuracy = 1)
  ) +
  labs(
    x = "Household Language Background",
    y = "Predicted Probability of Singular Agreement"
  ) +
  theme_classic() +
  theme(
    text = element_text(family = "serif"),
    plot.title = element_text(
      size = 14,
      hjust = 0.5
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11),
    axis.text.x = element_text(
      angle = 35,
      hjust = 1
    )
  )

pred_hlb

ggsave(
  "plots/outcome_by_hlb.png",
  plot = pred_hlb,
  width = 7,
  height = 5
)

# GENDER
pred_gend <- ggeffects::ggpredict(
  model_combined,
  terms = "Gender"
)

pred_gend <- ggplot(
  pred_gend,
  aes(x = x, y = predicted)
) +
  geom_point(size = 3) +
  geom_errorbar(
    aes(ymin = conf.low, ymax = conf.high),
    width = 0.15
  ) +
  scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.2),
    labels = scales::label_percent(accuracy = 1)
  ) +
  labs(
    x = "Gender",
    y = "Predicted Probability of Singular Agreement"
  ) +
  theme_classic() +
  theme(
    text = element_text(family = "serif"),
    plot.title = element_text(
      size = 14,
      hjust = 0.5
    ),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 11)
  )

pred_gend

ggsave(
  "plots/outcome_by_gender.png",
  plot = pred_gend,
  width = 7,
  height = 5
)