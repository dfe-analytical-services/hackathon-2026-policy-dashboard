---
title: "README"
output: html_document
date: "2026-09-03"
---

# Policy Data Explorer

## Overview

Policy Data Explorer is an R Shiny application developed for the DfE GSS Hackathon 2026.

The application allows users to upload a dataset and its associated data guidance document, then automatically generates appropriate measures and filters based on the uploaded metadata. Users can explore, filter and summarise data without needing to manually interpret the underlying dataset structure.

---

## Why this matters

Policy analysts often spend considerable time:

- Finding the correct variables within unfamiliar datasets
- Interpreting data guidance documents
- Creating bespoke data cuts for different policy questions
- Repeating similar exploratory analysis tasks

Policy Data Explorer reduces this effort by automatically identifying available measures and filters from the uploaded data and guidance files, allowing users to focus on analysis rather than data preparation.

---

## Key Features

- Upload CSV datasets
- Upload accompanying data guidance documents
- Automatically identify available measures
- Automatically identify available filters
- Dynamically adapt the user interface based on uploaded data
- Explore data through charts, tables and summary statistics
- Apply multiple filters simultaneously
- Reset filters with a single click

---

## How It Works

### Step 1: Upload Data

Users upload a CSV dataset.

### Step 2: Upload Guidance

Users upload an associated data guidance document.

### Step 3: Parse Metadata

The application parses the guidance document to identify:

- Variable names
- Variable labels
- Variable roles:
  - Measure
  - Dimension
  - Identifier
  - Review

### Step 4: Generate Dynamic Controls

The application automatically identifies:

- Available measures
- Available filter variables

based on both:

- The uploaded dataset
- The uploaded metadata

### Step 5: Explore Results

Users can:

- Select a measure
- Apply filters
- View summary outputs
- Explore visualisations
- Review tabular data

---

## Project Structure

```text
.
├── app.R
├── global.R
├── README.md
├── metadata
│   └── variables_master.csv
├── R
│   ├── config.R
│   ├── mod_data.R
│   ├── mod_filters.R
│   ├── mod_summary.R
│   ├── mod_chart.R
│   ├── mod_table.R
│   └── parse_data_guidance.R
├── scripts
│   └── build_metadata.R
└── www
    └── custom.css
```

---

## Module Overview

### mod_data.R

Responsible for:

- Uploading datasets
- Uploading guidance files
- Reading uploaded files
- Parsing metadata

### mod_filters.R

Responsible for:

- Dynamic measure selection
- Dynamic filter generation
- Applying user-selected filters

### mod_summary.R

Responsible for:

- Summary statistics
- High-level KPI outputs

### mod_chart.R

Responsible for:

- Visualising filtered data

### mod_table.R

Responsible for:

- Displaying filtered datasets
- Export functionality

### parse_data_guidance.R

Responsible for:

- Extracting metadata from uploaded guidance files
- Assigning variable roles
- Creating metadata used by the dashboard

---

## Required Packages

```r
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
```

Install missing packages using:

```r
install.packages(
  c(
    "shiny",
    "bslib",
    "dplyr",
    "tidyr",
    "readr",
    "vroom",
    "stringr",
    "purrr",
    "DT",
    "plotly",
    "scales",
    "tibble"
  )
)
```

---

## Running the Application

Open the project in RStudio and run:

```r
shiny::runApp()
```

Alternatively:

```r
source("global.R")
shiny::runApp()
```

---

## Metadata Approach

The application uses uploaded guidance documents to identify metadata dynamically.

Variables are categorised into:

| Role | Description |
|--------|-------------|
| measure | Numeric outputs for analysis and visualisation |
| dimension | Variables suitable for filtering and grouping |
| identifier | Unique reference variables |
| review | Variables requiring manual review |

This allows the dashboard to adapt automatically to different dataset structures without requiring hard-coded filter definitions.

---

## Current Limitations

- Variable classification is rule-based.
- Some variables may require manual review.
- Not all guidance document formats are currently supported.
- Dynamic numeric range filters are not yet implemented.
- Variable labels may differ between datasets where the same variable name is used in multiple contexts.

---

## Future Enhancements

Potential future improvements include:

- Numeric range filters
- Date filtering
- Improved variable standardisation
- Enhanced metadata validation
- Export of filtered visualisations
- Additional supported metadata formats

---

## Authors

Developed as part of the DfE GSS Hackathon 2026.
