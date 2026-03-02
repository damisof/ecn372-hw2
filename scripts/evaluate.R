# Script to evaluate the final model on the test.csv dataset


# Only output the MSE 
suppressMessages(suppressWarnings({
    library(here)
    library(tidyverse)
    library(tidymodels)
    source(here("src", "data.R"))
    source(here("src", "setup.R"))
    source(here("src", "config.R"))
    source(here("src", "nested_cv.R"))
}))

# Path for new test data
NEW_TEST_DATA <- here("data", "raw", "test.csv")

# Clean the new test data
test_data <- clean_data(NEW_TEST_DATA)

# Load final model
final_model <- readRDS(here("models", "final_model.rds"))

# Predict on new test data
predictions <- predict(final_model, new_data = test_data)


# Find log of predicted shares and find actual shares
pred_log <- as.numeric(predictions$.pred)
actual_shares <- exp(as.numeric(test_data$log_shares))

# Calculate the Smearing Factor to account for the log transformation
resids <- as.numeric(test_data$log_shares) - pred_log
smearing_factor <- mean(exp(resids))

#  Apply Smearing Factor to predicted shares
predicted_shares <- exp(pred_log) * smearing_factor

# Calculate final MSE
mse <- mean((actual_shares - predicted_shares)^2)
print(mse)


