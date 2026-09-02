# ============================================================
# Policy Data Explorer - Configuration
# ============================================================

APP_TITLE <- "Policy Data Explorer"

APP_SUBTITLE <-
  "DfE GSS Hackathon 2026 | Policy self-service prototype"


# ------------------------------------------------------------
# Measures we may find in EES data
# ------------------------------------------------------------

MEASURE_ALIASES <- list(
  
  enrolments = c(
    "enrolments",
    "aim_enrolments",
    "aim_enrolment"
  ),
  
  achievements = c(
    "achievements",
    "aim_achievements",
    "learner_achievements"
  ),
  
  participation = c(
    "participation"
  )
)


# ------------------------------------------------------------
# Dimensions we may find in EES data
# ------------------------------------------------------------

DIMENSION_ALIASES <- list(
  
  academic_year = c(
    "academic_year",
    "time_period",
    "year"
  ),
  
  age_group = c(
    "age_group",
    "age_band",
    "age_group_with_unknowns",
    "age_youth_adult",
    "age"
  ),
  
  provision_type = c(
    "provision_type",
    "provision"
  ),
  
  subject = c(
    "sector_subject_area",
    "ssa_tier_1",
    "sector_subject_area_tier_1",
    "ssa"
  ),
  
  geography = c(
    "region_name",
    "local_authority_name",
    "local_authority",
    "area_name",
    "country_name"
  ),
  
  provider_type = c(
    "provider_type"
  ),
  
  provider_name = c(
    "provider_name",
    "provider"
  ),
  
  level = c(
    "notional_nvq_level",
    "detailed_level",
    "level"
  ),
  
  sex = c(
    "sex",
    "gender"
  ),
  
  ethnicity = c(
    "ethnicity",
    "ethnicity_major"
  )
)


# ------------------------------------------------------------
# User-friendly filter labels
# ------------------------------------------------------------

FILTER_LABELS <- c(
  
  academic_year = "Academic year",
  age_group = "Age group",
  provision_type = "Provision type",
  subject = "Subject area",
  geography = "Geography",
  provider_type = "Provider type",
  provider_name = "Provider",
  level = "Level",
  sex = "Sex",
  ethnicity = "Ethnicity"
)


# ------------------------------------------------------------
# EES disclosure / missing values
# ------------------------------------------------------------

SUPPRESSION_VALUES <- c(
  "",
  "NA",
  "N/A",
  "c",
  "z",
  "x",
  "low"
)