# ============================================================
# Policy Data Explorer
# DfE GSS Hackathon 2026
# ============================================================

source("global.R")

max_file_size_mb <- 2000
options(shiny.maxRequestSize = max_file_size_mb * 1e6)


# ------------------------------------------------------------
# Temporary demo data
# ------------------------------------------------------------

set.seed(2026)

demo_data <- tibble::tibble(
  academic_year = sample(
    c("2023/24", "2024/25", "2025/26"),
    1000,
    replace = TRUE
  ),
  
  age_group = sample(
    c("16-18", "19-23", "24+"),
    1000,
    replace = TRUE
  ),
  
  provision_type = sample(
    c(
      "Education and Training",
      "Apprenticeships",
      "Community Learning"
    ),
    1000,
    replace = TRUE
  ),
  
  sector_subject_area = sample(
    c(
      "Construction",
      "Engineering and Manufacturing",
      "Health",
      "Business",
      "Digital",
      "Science"
    ),
    1000,
    replace = TRUE
  ),
  
  region_name = sample(
    c(
      "London",
      "South West",
      "South East",
      "West Midlands",
      "North West",
      "North East"
    ),
    1000,
    replace = TRUE
  ),
  
  enrolments = sample(
    10:200,
    1000,
    replace = TRUE
  ),
  
  achievements = sample(
    5:150,
    1000,
    replace = TRUE
  )
)


# ------------------------------------------------------------
# User interface
# ------------------------------------------------------------

ui <- fluidPage(
  
  tags$head(
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "custom.css"
    )
  ),
  
  div(
    class = "app-header",
    
    h1(
      class = "app-title",
      APP_TITLE
    ),
    
    div(
      class = "app-subtitle",
      APP_SUBTITLE
    )
  ),
  
  fluidRow(
    
    column(
      width = 3,
      
      div(
        class = "filter-panel",
        
        mod_data_ui(
          "data"
        ),
        
        h3("Build your data cut"),
        
        p(
          "Select the information you need."
        ),
        
        mod_filters_ui(
          "filters"
        )
      )
    ),
    
    column(
      width = 9,
      
      mod_summary_ui(
        "summary"
      ),
      
      div(
        class = "panel-card",
        
        h3("Explore the results"),
        
        mod_chart_ui(
          "chart"
        )
      ),
      
      div(
        class = "panel-card",
        
        mod_table_ui(
          "table"
        )
      )
    )
  )
)


# ------------------------------------------------------------
# Server
# ------------------------------------------------------------

server <- function(
    input,
    output,
    session
) {
  
  # ----------------------------------------------------------
  # Data module
  # ----------------------------------------------------------
  
  app_data <- mod_data_server(
    "data",
    demo_data = demo_data
  )
  
  
  # ----------------------------------------------------------
  # Filter module
  # ----------------------------------------------------------
  
  filters <- mod_filters_server(
    "filters",
    data = app_data
  )
  
  
  # ----------------------------------------------------------
  # Summary module
  # ----------------------------------------------------------
  
  mod_summary_server(
    "summary",
    filtered_data = filters$data,
    measure = filters$measure,
    filters = filters$filters
  )
  
  
  # ----------------------------------------------------------
  # Chart module
  # ----------------------------------------------------------
  
  mod_chart_server(
    "chart",
    filtered_data = filters$data,
    measure = filters$measure
  )
  
  
  # ----------------------------------------------------------
  # Table module
  # ----------------------------------------------------------
  
  mod_table_server(
    "table",
    filtered_data = filters$data
  )
}


# ------------------------------------------------------------
# Run application
# ------------------------------------------------------------

shinyApp(
  ui = ui,
  server = server
)