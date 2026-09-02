packages <- c(
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
  "tibble",
  "testthat"
)

missing_packages <- packages[
  !vapply(
    packages,
    requireNamespace,
    quietly = TRUE,
    FUN.VALUE = logical(1)
  )
]

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

message("All project dependencies are installed.")