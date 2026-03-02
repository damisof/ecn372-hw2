# Split data into train and test sets


if (!require("here")) install.packages("here")
library(here)

library(here)
source(here("src", "config.R"))
source(here("src", "data.R"))
source(here("src", "setup.R"))
library(tidyverse)


# Clean the raw data, save it to the processed data folder  
all_data_cleaned <- clean_data(RAW_DATA_PATH)
write_csv(all_data_cleaned, here(PROCESSED_DATA_PATH, "all_data_cleaned.csv"))

# Split the data into train and test sets
set.seed(SEED)
n <- nrow(all_data_cleaned)
train_index <- sample(1:n, size = floor(DATA_SPLIT * n))
train_data <- all_data_cleaned[train_index, ]
test_data <- all_data_cleaned[-train_index, ]
write_csv(train_data, TRAIN_DATA_PATH)
write_csv(test_data, TEST_DATA_PATH)