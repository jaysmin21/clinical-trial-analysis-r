# Simulated Clinical Trial Analysis: Drug vs. Placebo

End-to-end R analysis of a simulated randomized controlled trial evaluating the effect of an active drug versus placebo on blood pressure reduction. Demonstrates reproducible workflow from data simulation through publication-quality deliverables.

**Author:** Jay Sminchak
**Last updated:** May 2026

---

## Overview

This project simulates a 400-patient randomized trial and walks through a complete analytic workflow: data generation, descriptive statistics (Table 1), regression modeling (unadjusted and covariate-adjusted), and export of results to client-ready Excel and Word deliverables.

The analysis is designed to mirror the structure of an industry biostatistics deliverable while remaining fully reproducible from a single script.


## Methods summary

| Component | Approach |
|-----------|----------|
| Population | n = 400, 1:1 randomization (simulated) |
| Outcome | Change in blood pressure from baseline to follow-up |
| Covariates | Age, sex, baseline blood pressure |
| Descriptive | Table 1 via `gtsummary` (means/SDs, proportions, t-tests, chi-square) |
| Inferential | Linear regression — unadjusted and covariate-adjusted models |
| Reporting | `flextable` for Word, `openxlsx` for Excel |

True treatment effect in the simulation: −8 mmHg (drug) vs. −2 mmHg (placebo).
Reproducibility: `set.seed(1321)`.

## Skills demonstrated

- **R / tidyverse** data manipulation and reproducible analysis
- **Statistical modeling** with `lm`, `broom::tidy` for clean estimate extraction
- **Publication-ready tables** using `gtsummary` and `flextable`
- **Multi-format deliverables** — single script produces both Excel and Word outputs
- **Reproducibility practices** — seeded simulation, `here()` for portable paths, `sessionInfo()` for environment capture

## How to run

```r
# install dependencies if needed
install.packages(c(
  "tidyverse", "broom", "gtsummary",
  "flextable", "openxlsx", "here"
))

# from the project root
source("Sminchak_Jay_Trial_Analysis.R")
```

The script creates an `outputs/` directory automatically and writes both deliverables there.

## About this sample

This script is intended as a code sample illustrating clean, reproducible R workflow for a clinical or observational analysis pipeline. Simulated data is used throughout — no real patient information is included.

## Contact

Jay Sminchak — jaysmin@bu.edu# clinical-trial-analysis-r
