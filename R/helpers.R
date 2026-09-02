# ============================================================
# Policy Data Explorer - Helper functions
# ============================================================

clean_names_simple <- function(x) {
  
  x |>
    stringr::str_to_lower() |>
    stringr::str_replace_all(
      "[^a-z0-9]+",
      "_"
    ) |>
    stringr::str_replace_all(
      "^_+|_+$",
      ""
    )
}


pretty_name <- function(x) {
  
  labels <- c(
    academic_year = "Academic year",
    time_period = "Academic year",
    age_group = "Age group",
    age_band = "Age group",
    provision_type = "Provision type",
    sector_subject_area = "Sector subject area",
    ssa_tier_1 = "Sector subject area",
    region_name = "Region",
    local_authority_name = "Local authority",
    provider_type = "Provider type",
    provider_name = "Provider",
    provider_ukprn = "UKPRN",
    notional_nvq_level = "Level",
    sex = "Sex",
    ethnicity = "Ethnicity",
    enrolments = "Enrolments",
    aim_enrolments = "Enrolments",
    achievements = "Achievements",
    aim_achievements = "Achievements",
    learner_achievements = "Achievements",
    participation = "Participation"
  )
  
  if (x %in% names(labels)) {
    return(
      unname(
        labels[[x]]
      )
    )
  }
  
  x |>
    stringr::str_replace_all(
      "_",
      " "
    ) |>
    stringr::str_to_title()
}


as_measure_numeric <- function(x) {
  
  readr::parse_number(
    as.character(x),
    na = SUPPRESSION_VALUES
  )
}