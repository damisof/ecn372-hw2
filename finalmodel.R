# Create a final model using the full train.csv dataset

library(tidyverse)
library(tidymodels)
library(here)
source(here("src", "config.R"))
source(here("src", "nested_cv.R"))
source(here("src", "data.R"))
source(here("src", "setup.R"))

# Load the full dataset 
full_data <- clean_data(RAW_DATA_PATH)

# Use the same recipe and model as the practice model
ridge_rec <- recipe(log_shares ~ ., data = full_data) %>%
   step_dummy(all_nominal_predictors()) %>%
    step_log(kw_avg_avg, timedelta, self_reference_avg_sharess, n_tokens_content, offset = 1) %>%
        step_interact(terms = ~ 
                          data_channel_is_entertainment:weekday_is_friday + 
                          data_channel_is_bus:weekday_is_monday 
                            ) %>%
    step_zv(all_predictors()) %>%
    step_normalize(all_numeric_predictors())

ridge_spec <- linear_reg(penalty = tune(), mixture = 0) %>%
    set_engine("glmnet")

ridge_wf <- workflow() %>%
    add_recipe(ridge_rec) %>%
    add_model(ridge_spec)

ridge_grid <- grid_regular(penalty(range = RIDGE_RANGE), levels = RIDGE_LEVELS)


# Nested CV on full dataset

ridge_grid <- grid_regular(penalty(range = RIDGE_RANGE), levels = RIDGE_LEVELS)

set.seed(SEED)
outer_folds <- vfold_cv(full_data, v = OUTER_FOLDS)

nested_cv_results <- outer_folds %>%
  mutate(
    inner_resamples = map(splits, ~ vfold_cv(analysis(.x), v = INNER_FOLDS)), 
    best_penalty = map_dbl(inner_resamples, ~ tune_inner(
      inner_resamples = .x, 
      model_spec = ridge_spec, 
      rec = ridge_rec, 
      grid = ridge_grid, 
      metric = "rmse"
    )),
    best_penalty_results = map2(splits, best_penalty, ~ eval_outer(
      outer_split = .x, 
      penalty_val = .y, 
      model_spec = ridge_spec, 
      rec = ridge_rec, 
      outcome = "log_shares"
    ))
  )


# Tuning for final model
set.seed(SEED)
final_inner_folds <- vfold_cv(full_data, v = INNER_FOLDS)

tune_results <- tune_grid(
    ridge_wf,
    resamples = final_inner_folds,
    grid = ridge_grid,
    metrics = metric_set(rmse)
)

# Find best model and fit
best_ridge <- select_best(tune_results, metric = "rmse")
final_wf <- finalize_workflow(ridge_wf, best_ridge)
final_model <- fit(final_wf, data = full_data)

# Save the model as an rds file
if (!dir.exists(here("models"))) dir.create(here("models"))
saveRDS(final_model, here("models", "final_model.rds"))


