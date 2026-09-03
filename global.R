# ============================================================
# Policy Data Explorer
# Global configuration
# DfE GSS Hackathon 2026
# ============================================================

options(
  shiny.maxRequestSize = 500 * 1024^2
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
library(DT)
library(plotly)
library(scales)
library(tibble)


# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

source("R/config.R")


# ------------------------------------------------------------
# Load metadata
# ------------------------------------------------------------

variables_master <- readr::read_csv("metadata/variables_master.csv",
                                    show_col_types = FALSE)
# print(names(variables_master)) #for sense checking that variables_master has imported as expected/intended
# ------------------------------------------------------------
# Shiny modules
# ------------------------------------------------------------

source("R/mod_filters.R")
source("R/mod_summary.R")
source("R/mod_chart.R")
source("R/mod_table.R")
source("R/mod_data.R")