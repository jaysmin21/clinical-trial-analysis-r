# ================================================================================
# Simulated Clinical Trial Analysis: Drug vs. Placebo
# Author: Jay Sminchak
# Date:   2026
# ================================================================================
# Objective: Estimate the effect of an active drug vs. placebo on blood pressure
#            reduction in a simulated randomized clinical trial.
# Outputs:   Table 1 (baseline characteristics), Table 2 (regression estimates),
#            exported to a single Excel workbook and a Word document.
# ================================================================================

# ---- Packages ------------------------------------------------------------------
library(tidyverse)
library(broom)
library(gtsummary)
library(flextable)
library(openxlsx)
library(here)

# ---- Output directory ----------------------------------------------------------
dir.create(here("outputs"), showWarnings = FALSE, recursive = TRUE)

# ================================================================================
#                          Simulate the trial population
# ================================================================================
set.seed(1321)

n <- 400

trial_data <- tibble(
  id        = 1:n,
  treatment = rbinom(n, 1, prob = 0.5),                 # 1 = drug, 0 = placebo
  age       = round(rnorm(n, mean = 55, sd = 10)),
  sex       = rbinom(n, 1, prob = 0.5),                 # 1 = male, 0 = female
  baseline  = rnorm(n, mean = 150, sd = 15)
) %>%
  mutate(
    # True treatment effect: drug -8, placebo -2
    treatment_effect = if_else(treatment == 1, -8, -2),
    error            = rnorm(n, mean = 0, sd = 5),
    follow_up        = baseline + treatment_effect + error,
    change           = follow_up - baseline
  ) %>%
  select(id, treatment, age, sex, baseline, follow_up, change)

# Labeled dataset for reporting (factors for human-readable output)
table_data <- trial_data %>%
  mutate(
    treatment = factor(treatment, levels = c(0, 1),
                       labels = c("Placebo", "Drug")),
    sex       = factor(sex,       levels = c(0, 1),
                       labels = c("Female", "Male"))
  )

# Quick QC
head(trial_data)
head(table_data)

# ================================================================================
#                              Descriptive analyses
# ================================================================================

# Frequency checks
table(table_data$treatment)
table(table_data$sex)
table(table_data$treatment, table_data$sex)

# Distribution checks for continuous variables (interactive use only)
# hist(table_data$age)
# hist(table_data$baseline)
# Both age and baseline appear approximately normal — report mean (SD).

# ---- Table 1: Baseline characteristics -----------------------------------------
tab1 <- tbl_summary(
  data      = table_data,
  by        = treatment,
  include   = c(age, sex, baseline),
  statistic = list(
    all_continuous()  ~ "{mean} ({sd})",
    all_categorical() ~ "{n} ({p}%)"
  ),
  digits  = all_continuous() ~ 1,
  missing = "no",
  label   = list(
    age      ~ "Age (years)",
    sex      ~ "Sex",
    baseline ~ "Baseline Blood Pressure (mmHg)"
  )
) %>%
  add_overall() %>%
  add_p(test = list(
    all_continuous()  ~ "t.test",
    all_categorical() ~ "chisq.test"
  )) %>%
  bold_labels() %>%
  modify_footnote(everything() ~ NA) %>%
  modify_caption("**Table 1. Baseline Characteristics**")

tab1

# Tidy version of Table 1 for Excel export
table1_tidy <- table_data %>%
  group_by(treatment) %>%
  summarise(
    N                = n(),
    Age              = sprintf("%.0f (%.0f)", mean(age), sd(age)),
    `Baseline Value` = sprintf("%.0f (%.0f)", mean(baseline), sd(baseline)),
    Female           = paste0(
      sum(sex == "Female"), " (",
      round(mean(sex == "Female") * 100, 1), "%)"
    ),
    .groups          = "drop"
  ) %>%
  mutate(treatment = as.character(treatment))

# Totals row
table1_total <- table_data %>%
  summarise(
    treatment        = "Total",
    N                = n(),
    Age              = sprintf("%.0f (%.0f)", mean(age), sd(age)),
    `Baseline Value` = sprintf("%.0f (%.0f)", mean(baseline), sd(baseline)),
    Female           = paste0(
      sum(sex == "Female"), " (",
      round(mean(sex == "Female") * 100, 1), "%)"
    )
  )

table1_final <- bind_rows(table1_tidy, table1_total)
table1_final

# ================================================================================
#                       Treatment effect: regression analysis
# ================================================================================

# Unadjusted model
fit_unadj <- lm(change ~ treatment, data = table_data)
summary(fit_unadj)

# Adjusted model (age, sex, baseline)
fit_adj <- lm(change ~ treatment + age + sex + baseline, data = table_data)
summary(fit_adj)

# Diagnostic plots (interactive use only — uncomment to view)
# par(mfrow = c(2, 2))
# plot(fit_adj)
# par(mfrow = c(1, 1))

# Tidy estimates table
table2 <- tidy(fit_adj, conf.int = TRUE, conf.level = 0.95) %>%
  mutate(
    CI_95 = sprintf("[%.2f, %.2f]", conf.low, conf.high)
  ) %>%
  select(
    Parameter = term,
    Estimate  = estimate,
    SE        = std.error,
    CI_95,
    P_value   = p.value
  ) %>%
  mutate(
    Estimate = round(Estimate, 3),
    SE       = round(SE, 3),
    P_value  = round(P_value, 4)
  )

table2

# ================================================================================
#                              Export deliverables
# ================================================================================

# ---- Excel workbook (raw data + both tables in one file) -----------------------
wb <- createWorkbook()

addWorksheet(wb, "Raw_data")
writeData(wb, "Raw_data", trial_data)

addWorksheet(wb, "Table1_Baseline")
writeData(wb, "Table1_Baseline", table1_final)

addWorksheet(wb, "Table2_Estimates")
writeData(wb, "Table2_Estimates", table2)

saveWorkbook(
  wb,
  file      = here("outputs", "Clinical_Trial_Analysis.xlsx"),
  overwrite = TRUE
)

# ---- Word document (publication-style Table 1) ---------------------------------
tab1 %>%
  as_flex_table() %>%
  save_as_docx(path = here("outputs", "Table1_Baseline.docx"))

# ---- Session info for reproducibility ------------------------------------------
sessionInfo()
