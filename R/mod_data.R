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
    
    fileInput(
      inputId = ns("upload_guidance"),
      label = "Choose data guidance file (.txt or .csv only)",
      accept = c(".txt", ".csv")
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
      # Return uploaded guidance file path
      # ------------------------------------------------------
      
      guidance_file <- reactive({
        
        if (is.null(input$upload_guidance)) {
          return(NULL)
        }
        
        input$upload_guidance$datapath
        
      })
      
      # ------------------------------------------------------
      # Parse data guidance
      # ------------------------------------------------------
      
      metadata <- reactive({
        
        req(guidance_file())
        
        parse_data_guidance(
          guidance_file()
        )
        
      })
      
      # temp test - is metadata being parsed and matched correctly
      observe({
        
        req(metadata())
        req(app_data())
        
        matched_variables <- metadata() |>
          dplyr::filter(
            variable %in% names(app_data())
          ) |>
          dplyr::distinct(
            variable,
            .keep_all = TRUE
          )
        
        message(
          "Variables in uploaded data: ",
          ncol(app_data())
        )
        
        message(
          "Unique variables matched to metadata: ",
          nrow(matched_variables)
        )
        
      })
      
      # ------------------------------------------------------
      # Return reactive dataset and metadata to the rest of the app
      # ------------------------------------------------------
      
      return(
        list(
          data = app_data,
          metadata = metadata
        )
      )
      
    }
  )
}