# ============================================================
# Parse FE&S data guidance into a variable metadata registry
# ============================================================

#' Clean text imported from the data guidance file
#'
#' @param x Character vector.
#'
#' @return Cleaned character vector.
clean_guidance_text <- function(x) {
  
  x |>
    stringr::str_replace_all("\\\\_", "_") |>
    stringr::str_replace_all("\u00a0", " ") |>
    stringr::str_squish()
}


#' Assign a role to a variable using explicit reproducible rules
#'
#' @param variable Character vector of variable names.
#'
#' @return Character vector containing "measure", "dimension",
#'   "identifier" or "review".
classify_variable_role <- function(variable) {
  
  variable <- stringr::str_to_lower(variable)
  
  dplyr::case_when(
    
    # Identifiers and reference fields
    stringr::str_detect(
      variable,
      paste0(
        "(^|_)",
        "(ukprn|code|reference|reference_number|identifier)",
        "($|_)"
      )
    ) ~ "identifier",
    
    # Rates, percentages and numerical outputs
    stringr::str_detect(
      variable,
      paste0(
        "(achievement_rate|retention_rate|pass_rate|",
        "achievers|completers|leavers|",
        "participation|achievements|enrolments|starts|",
        "applications_received|applications_approved|",
        "loan_amount|population_estimate|",
        "_percent$|_percentage$|_rate_|_rate$)"
      )
    ) ~ "measure",
    
    # Common categorical dimensions
    stringr::str_detect(
      variable,
      paste0(
        "(age|sex|ethnicity|minority_ethnic|",
        "difficulty|disability|lldd|",
        "provider_type|provider_name|provision_type|",
        "level|subject|ssa_|stem|regulated|",
        "breakdown|reporting_period|time_coverage|",
        "geographic|region|local_authority|",
        "constituency|devolved|country_name|",
        "tailored_learning|family_learning|employer_facing|",
        "qualification_type|gcse_type)"
      )
    ) ~ "dimension",
    
    # Anything not covered by an explicit rule must be reviewed
    TRUE ~ "review"
  )
}


#' Parse variables from the FE&S data guidance
#'
#' @param path Path to data-guidance.txt.
#'
#' @return Tibble with one row per dataset-variable combination.
parse_data_guidance <- function(path) {
  
  stopifnot(
    file.exists(path),
    length(path) == 1
  )
  
  guidance_lines <- readr::read_lines(
    path,
    progress = FALSE
  ) |>
    clean_guidance_text()
  
  # Retain lines which look like:
  # variable_name | Variable description
  variable_lines <- guidance_lines[
    stringr::str_detect(
      guidance_lines,
      "^[A-Za-z][A-Za-z0-9_]*\\s*\\|"
    )
  ]
  
  parsed <- tibble::tibble(
    source_line = variable_lines
  ) |>
    tidyr::separate_wider_delim(
      source_line,
      delim = "|",
      names = c("variable", "label"),
      too_many = "merge",
      cols_remove = TRUE
    ) |>
    dplyr::mutate(
      variable = variable |>
        stringr::str_squish() |>
        stringr::str_to_lower(),
      
      label = label |>
        stringr::str_squish(),
      
      role = classify_variable_role(variable)
    ) |>
    dplyr::filter(
      variable != "variable_name",
      variable != "variable",
      variable != "",
      label != ""
    )
  
  parsed
}


#' Create one master row per unique variable
#'
#' @param parsed_metadata Output from parse_data_guidance().
#'
#' @return Deduplicated variable registry.
create_variables_master <- function(parsed_metadata) {
  
  required_columns <- c(
    "variable",
    "label",
    "role"
  )
  
  missing_columns <- setdiff(
    required_columns,
    names(parsed_metadata)
  )
  
  if (length(missing_columns) > 0) {
    stop(
      "Metadata is missing required columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }
  
  parsed_metadata |>
    dplyr::distinct(
      variable,
      label,
      role
    ) |>
    dplyr::group_by(variable) |>
    dplyr::mutate(
      label_count = dplyr::n_distinct(label),
      role_count = dplyr::n_distinct(role)
    ) |>
    dplyr::arrange(
      role,
      variable,
      label
    ) |>
    dplyr::ungroup()
}