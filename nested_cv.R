# Nested CV function for ridge regression


#' @param outer_split 
#' @param inner_resamples 
#' @param model_spec 
#' @param rec 
#' @param grid 
#' @param metric 
#' @return 

# Tune inner folds
tune_inner <- function(outer_split, inner_resamples, model_spec, rec, grid, metric = "rmse") {
  wf <- workflow() %>%
    add_recipe(rec) %>%
    add_model(model_spec)
  tune_res <- tune_grid(
    wf,
    resamples = inner_resamples,
    grid = grid,
    control = control_grid(save_workflow = TRUE),
    metrics = metric_set(rmse)
  )
  best <- select_best(tune_res, metric = metric)
  best$penalty
}


#' @param outer_split 
#' @param penalty_val 
#' @param model_spec 
#' @param rec 
#' @param outcome 
#' @return 
#' 
# Evaluate best penalty on outer fold
eval_outer <- function(outer_split, penalty_val, model_spec, rec, outcome = "log_shares") {
  wf <- workflow() %>%
    add_recipe(rec) %>%
    add_model(model_spec) %>%
    finalize_workflow(tibble(penalty = penalty_val))
  fit <- fit(wf, data = analysis(outer_split))
  pred <- predict(fit, new_data = assessment(outer_split))
  truth <- assessment(outer_split)[[outcome]]
  tibble(
    rmse = rmse_vec(truth = truth, estimate = pred$.pred),
    mae  = mae_vec(truth = truth, estimate = pred$.pred)
  )
}
