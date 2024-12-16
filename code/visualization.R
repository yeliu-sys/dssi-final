
# Load required libraries
library(gt)
library(tidyverse)
library(haven)

# Import Stata results if saved as CSV
# If you saved results from Stata using 'outsheet' command
# results <- read.csv("stata_results.csv")

# Or create results data frame directly
results <- data.frame(
  measure = "Effect\nestimate\n(95% CI)",
  model1 = "-0.02 (-0.11 to 0.07)",
  model2 = "-0.10 (-0.21 to 0.02)",
  model3 = "-0.13 (-0.29 to 0.03)",
  stringsAsFactors = FALSE
)

# Create formatted table
main_table <- gt(results) %>%
  # Add title and subtitle
  tab_header(
    title = md("**Table 4**  Main results from linear regression for the mean"),
    subtitle = "effect of a 1-month increase in legislated paid maternity leave on height-for-age z score"
  ) %>%
  # Rename columns with significance indicators
  cols_label(
    measure = "",
    model1 = "Model 1*",
    model2 = "Model 2†",
    model3 = "Model 3‡"
  ) %>%
  # Add lavender background
  tab_style(
    style = list(
      cell_fill(color = "#E6E6FA")
    ),
    locations = cells_body()
  ) %>%
  # Set font to Times New Roman
  opt_table_font(
    font = "Times New Roman"
  ) %>%
  # Add borders
  tab_options(
    table_body.border.top.width = px(1),
    table_body.border.bottom.width = px(1),
    column_labels.border.bottom.width = px(1),
    table.width = pct(100)
  ) %>%
  # Make column headers bold
  tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels()
  ) %>%
  # Set column alignment
  cols_align(
    align = "center",
    columns = c("model1", "model2", "model3")
  ) %>%
  cols_align(
    align = "left",
    columns = "measure"
  )

# Add footnotes
main_table <- main_table %>%
  tab_footnote(
    footnote = "Base model with country and year fixed effects",
    locations = cells_column_labels(columns = "model1")
  ) %>%
  tab_footnote(
    footnote = "Model 1 + individual and household controls",
    locations = cells_column_labels(columns = "model2")
  ) %>%
  tab_footnote(
    footnote = "Model 2 + country-level controls",
    locations = cells_column_labels(columns = "model3")
  )

# Save the table
gtsave(main_table, "regression_results_table.html")
# For PDF output (if needed)
# gtsave(main_table, "regression_results_table.pdf")

# Display the table in R
main_table


