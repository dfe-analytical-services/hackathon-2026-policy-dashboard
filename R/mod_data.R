# ============================================================
# Policy Data Explorer
# Data upload module
# ============================================================


# ------------------------------------------------------------
# UI
# ------------------------------------------------------------

mod_data_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    
    h3("Load data"),
    
    fileInput(
      inputId = ns("upload_data"),
      label = "Choose a CSV file",
      accept = ".csv",
      buttonLabel = "Browse...",
      placeholder = "No file selected"
    ),
    
    textOutput(
      ns("current_file")
    ),
    
    tags$hr()
  )
}


# ------------------------------------------------------------
# Server
# ------------------------------------------------------------

mod_data_server <- function(
    id,
    demo_data
) {
  
  moduleServer(
    id,
    function(input, output, session) {
      
      # ------------------------------------------------------
      # Show which file is being used
      # ------------------------------------------------------
      
      output$current_file <- renderText({
        
        if (is.null(input$upload_data)) {
          return("Using demo data")
        }
        
        paste(
          "Loaded file:",
          input$upload_data$name
        )
      })
      
      
      # ------------------------------------------------------
      # Return uploaded data
      # Use demo data if no file has been uploaded
      # ------------------------------------------------------
      
      app_data <- reactive({
        
        if (is.null(input$upload_data)) {
          return(demo_data)
        }
        
        readr::read_csv(
          input$upload_data$datapath,
          show_col_types = FALSE
        )
      })
      
      
      # ------------------------------------------------------
      # Return reactive dataset to the rest of the app
      # ------------------------------------------------------
      
      return(app_data)
    }
  )
}