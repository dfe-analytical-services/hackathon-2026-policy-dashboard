# ============================================================
# Policy Data Explorer
# DfE GSS Hackathon 2026
# ============================================================

source("global.R")


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
  
  # ----------------------------------------------------------
  # Header
  # ----------------------------------------------------------
  
  div(
    class = "app-header",
    
    h1(
      class = "app-title",
      APP_TITLE
    ),
    
    p(
      class = "app-subtitle",
      APP_SUBTITLE
    )
  ),
  
  
  # ----------------------------------------------------------
  # Main page layout
  # ----------------------------------------------------------
  
  fluidRow(
    
    # --------------------------------------------------------
    # Left sidebar
    # --------------------------------------------------------
    
    column(
      width = 3,
      
      div(
        class = "filter-panel",
        
        mod_data_ui("data"),
        
        mod_filters_ui("filters")
      )
    ),
    
    
    # --------------------------------------------------------
    # Main dashboard content
    # --------------------------------------------------------
    
    column(
      width = 9,
      
      mod_summary_ui("summary"),
      
      mod_chart_ui("chart"),
      
      mod_table_ui("table")
    )
  )
)


# ------------------------------------------------------------
# Server
# ------------------------------------------------------------

server <- function(input, output, session) {
  
  
  # ----------------------------------------------------------
  # Data + metadata
  # ----------------------------------------------------------
  
  data_module <- mod_data_server(
    "data",
    demo_data = demo_data
  )
  
  
  # ----------------------------------------------------------
  # Dynamic filters
  # ----------------------------------------------------------
  
  filters <- mod_filters_server(
    "filters",
    data = data_module$data,
    metadata = data_module$metadata
  )
  
  
  # ----------------------------------------------------------
  # Summary / KPI cards
  # ----------------------------------------------------------
  
  mod_summary_server(
    "summary",
    filtered_data = filters$data,
    measure = filters$measure,
    filters = filters$filters
  )
  
  
  # ----------------------------------------------------------
  # Chart
  # ----------------------------------------------------------
  
  mod_chart_server(
    "chart",
    filtered_data = filters$data,
    measure = filters$measure
  )
  
  
  # ----------------------------------------------------------
  # Table + download
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