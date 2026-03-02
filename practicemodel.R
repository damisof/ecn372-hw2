# Create a practice model using the train/test split on train.csv

library(tidyverse)
library(tidymodels)
library(here)
source(here("src", "config.R"))
source(here("src", "nested_cv.R"))
source(here("src", "data.R"))
source(here("src", "setup.R"))


# Load the data
train_data <- read_csv(TRAIN_DATA_PATH)
test_data <- read_csv(TEST_DATA_PATH)


#Set up Ridge/model
# Drop all predictors with zero variance and dummy code all nominal predictors.
ridge_rec <- recipe(log_shares ~ ., data = train_data) %>%
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

# Define ridge grid
ridge_grid <- grid_regular(penalty(range = RIDGE_RANGE), levels = RIDGE_LEVELS)


# Nested CV - outer folds 
set.seed(SEED)
outer_folds <- vfold_cv(train_data, v = OUTER_FOLDS)



# Nested CV - inner folds
nested_cv_results <- outer_folds %>%
    mutate(
        # Inner folds for each outer fold
        inner_resamples = map(splits, ~ vfold_cv(analysis(.x), v = INNER_FOLDS)), 

    #Find the best penalty
    best_penalty = map2(splits, inner_resamples, ~ tune_inner(outer_split = .x, inner_resamples = .y, model_spec = ridge_spec, rec = ridge_rec, grid = ridge_grid, metric = "rmse")),


   # Evaluate best penalty on outer fold
   best_penalty_results = map2(splits, best_penalty, ~ eval_outer(outer_split = .x, penalty_val = .y, model_spec = ridge_spec, rec = ridge_rec, outcome = "log_shares"))


)



# Tuning for practice model
# Best penalty on entire training sample
inner_folds <- vfold_cv(train_data, v = INNER_FOLDS)
tune_results <- tune_grid(
    ridge_wf,
    resamples = inner_folds,
    grid = ridge_grid,
    metrics = metric_set(rmse)
)

best_ridge <- select_best(tune_results, metric = "rmse")
final_wf <- finalize_workflow(ridge_wf, best_ridge)

# Fit best model
practice_model <- fit(final_wf, data = train_data)

# Predict on test data
predictions <- predict(practice_model, new_data = test_data)

# Turn log shares back to actual shares:
actual_shares <- exp(test_data$log_shares)
predicted_shares <- exp(predictions$.pred)

# Calculate  MSE
mse <- (mean((actual_shares - predicted_shares)^2))



