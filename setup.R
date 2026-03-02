# Setup file for the project





# Install and load packages for cleaning, tuning, and ridge:
.pkgs <- c("tidymodels", "glmnet", "tidyverse", "here")
install_and_load <- function(pkgs = .pkgs) {
  if (length(pkgs) == 0L) return(invisible())
  missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing) > 0L) {
    install.packages(missing, repos = "https://cloud.r-project.org/")
  }
  for (p in pkgs) {
    library(p, character.only = TRUE)
  }
  invisible()
}
install_and_load()  

# Install and load the here package, and load the config file:
install.packages("here")
library(here)
source(here("src", "config.R"))


# Make sure the data folder exists:
if (!dir.exists(here("data"))) {    
  dir.create(here("data"))
}

