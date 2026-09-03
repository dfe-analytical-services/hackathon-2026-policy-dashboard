# ============================================================
# Policy Data Explorer
# Demo data
# Used when no CSV file has been uploaded
# ============================================================

set.seed(2026)

demo_data <- tibble::tibble(
  
  academic_year = sample(
    c(
      "2022/23",
      "2023/24",
      "2024/25",
      "2025/26"
    ),
    1000,
    replace = TRUE
  ),
  
  age_group = sample(
    c(
      "16-18",
      "19-23",
      "24+"
    ),
    1000,
    replace = TRUE
  ),
  
  provision_type = sample(
    c(
      "Apprenticeships",
      "Education and Training"
    ),
    1000,
    replace = TRUE
  ),
  
  sector_subject_area = sample(
    c(
      "Business",
      "Construction",
      "Engineering and Manufacturing",
      "Health, Public Services and Care",
      "Information and Communication Technology"
    ),
    1000,
    replace = TRUE
  ),
  
  region_name = sample(
    c(
      "London",
      "North East",
      "North West",
      "South East",
      "South West",
      "West Midlands",
      "Yorkshire and The Humber"
    ),
    1000,
    replace = TRUE
  ),
  
  enrolments = sample(
    50:500,
    1000,
    replace = TRUE
  ),
  
  achievements = sample(
    20:150,
    1000,
    replace = TRUE
  )
)