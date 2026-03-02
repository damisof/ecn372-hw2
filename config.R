#------------------------------------------------------------------------------
# Configuration file for this project: define constants for the project


library(here)
# Set the seed for reproducibility
SEED <- 777

# Create relative data paths
RAW_DATA_PATH <- here("data", "raw", "train.csv")
EVAL_DATA_PATH <- here("data", "raw", "test.csv")
TRAIN_DATA_PATH <- here("data", "processed", "train_split.csv")
TEST_DATA_PATH <- here("data", "processed", "test_split.csv")
PROCESSED_DATA_PATH <- here("data", "processed")

# Make sure the folders exist
if (!dir.exists(here("data", "processed"))) {
  dir.create(here("data", "processed"), recursive = TRUE)
}

# Define the train/test split:
DATA_SPLIT <- 0.8

# Define the number of folds for cross-validation:
OUTER_FOLDS <- 5
INNER_FOLDS <- 5


# Define range and levels for ridge penalty:
RIDGE_RANGE <- c(-5, 5)
RIDGE_LEVELS <- 50    

