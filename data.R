# Data cleaning function for the project
library(here)
source(here("src", "config.R"))
library(tidyverse)


# Create a function to clean the data by removing the url column (if there), creating a log of shares, and dropping the shares column
clean_data <- function(my_data) {
    read_csv(my_data, show_col_types = FALSE) %>%
    select(-any_of("url")) %>%
    mutate(log_shares = log(shares)) %>%
    select(-any_of("shares"))
}

