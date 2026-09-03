# ============================================================
# Policy Data Explorer
# Global configuration
# DfE GSS Hackathon 2026
# ============================================================


# ------------------------------------------------------------
# Shiny options
# ------------------------------------------------------------

max_file_size_mb <- 2000

options(
  shiny.maxRequestSize = max_file_size_mb * 1e6
)


# ------------------------------------------------------------
# Packages
# ------------------------------------------------------------

library(shiny)
library(bslib)

library(dplyr)
library(tidyr)
library(readr)
library(vroom)
library(stringr)
library(purrr)
library(tibble)

library(DT)
library(plotly)
library(scales)


# ------------------------------------------------------------
# Configuration and helper functions
# ------------------------------------------------------------

source("R/config.R")
source("R/helpers.R")


# ------------------------------------------------------------
# Data guidance parser
# ------------------------------------------------------------

source("R/parse_data_guidance.R")


# ------------------------------------------------------------
# Default metadata
#
# This is used as the fallback when the user has not uploaded
# a separate data-guidance file.
# ------------------------------------------------------------

variables_master <- readr::read_csv(
  "metadata/variables_master.csv",
  show_col_types = FALSE
)



if (file.exists("R/demo_data.R")) {
  source("R/demo_data.R")
}


# ------------------------------------------------------------
# Shiny modules
# ------------------------------------------------------------

source("R/mod_data.R")
source("R/mod_filters.R")
source("R/mod_summary.R")
source("R/mod_chart.R")
source("R/mod_table.R")