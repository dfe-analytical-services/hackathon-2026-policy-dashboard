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
    
    # --------------------------------------------------------
    # Left-hand panel
    # --------------------------------------------------------
    
    column(
      width = 3,
      
      div(
        class = "filter-panel",
        
        # Data upload module
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
    
    
    # --------------------------------------------------------
    # Main results area
    # --------------------------------------------------------
    
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
  # Data upload / extract
  # ----------------------------------------------------------
  
  app_data <- mod_data_server(
    "data",
    demo_data = demo_data
  )
  
  
  # ----------------------------------------------------------
  # Filters
  # ----------------------------------------------------------
  
  filters <- mod_filters_server(
    "filters",
    data = app_data
  )
  
  
  # ----------------------------------------------------------
  # Apply filters
  # ----------------------------------------------------------
  
  filtered_data <- reactive({
    
    data <- app_data()
    
    
    if (length(filters$academic_year()) > 0) {
      
      data <- data |>
        dplyr::filter(
          academic_year %in%
            filters$academic_year()
        )
    }
    
    
    if (length(filters$age_group()) > 0) {
      
      data <- data |>
        dplyr::filter(
          age_group %in%
            filters$age_group()
        )
    }
    
    
    if (length(filters$provision_type()) > 0) {
      
      data <- data |>
        dplyr::filter(
          provision_type %in%
            filters$provision_type()
        )
    }
    
    
    if (length(filters$subject()) > 0) {
      
      data <- data |>
        dplyr::filter(
          sector_subject_area %in%
            filters$subject()
        )
    }
    
    
    if (length(filters$region()) > 0) {
      
      data <- data |>
        dplyr::filter(
          region_name %in%
            filters$region()
        )
    }
    
    
    data
  })
  
  
  # ----------------------------------------------------------
  # Current filters
  # ----------------------------------------------------------
  
  current_filters <- reactive({
    
    list(
      academic_year =
        filters$academic_year(),
      
      age_group =
        filters$age_group(),
      
      provision_type =
        filters$provision_type(),
      
      subject =
        filters$subject(),
      
      region =
        filters$region()
    )
  })
  
  
  # ----------------------------------------------------------
  # Summary
  # ----------------------------------------------------------
  
  mod_summary_server(
    "summary",
    filtered_data = filtered_data,
    measure = filters$measure,
    filters = current_filters
  )
  
  
  # ----------------------------------------------------------
  # Chart
  # ----------------------------------------------------------
  
  mod_chart_server(
    "chart",
    filtered_data = filtered_data,
    measure = filters$measure
  )
  
  
  # ----------------------------------------------------------
  # Table / download
  # ----------------------------------------------------------
  
  mod_table_server(
    "table",
    filtered_data = filtered_data
  )
}


# ------------------------------------------------------------
# Run application
# ------------------------------------------------------------

shinyApp(
  ui = ui,
  server = server
)