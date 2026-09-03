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
      accept = c(".txt", ".csv"),
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
      
      
      # --------------------------------------------------------
      # Show which data file is being used
      # --------------------------------------------------------
      
      output$current_file <- renderText({
        
        if (is.null(input$upload_data)) {
          return("Using demo data")
        }
        
        paste(
          "Loaded file:",
          input$upload_data$name
        )
      })
      
      
      # --------------------------------------------------------
      # Main dataset
      # Use demo data if no CSV has been uploaded
      # --------------------------------------------------------
      
      app_data <- reactive({
        
        if (is.null(input$upload_data)) {
          return(demo_data)
        }
        
        readr::read_csv(
          input$upload_data$datapath,
          show_col_types = FALSE
        )
      })
      
      
      # --------------------------------------------------------
      # Guidance file path
      # --------------------------------------------------------
      
      guidance_file <- reactive({
        
        if (is.null(input$upload_guidance)) {
          return(NULL)
        }
        
        input$upload_guidance$datapath
      })
      
      
      # --------------------------------------------------------
      # Metadata
      #
      # No guidance uploaded:
      #   use built-in variables_master metadata
      #
      # Guidance uploaded:
      #   parse the uploaded guidance file
      # --------------------------------------------------------
      
      metadata <- reactive({
        
        if (is.null(guidance_file())) {
          
          return(
            variables_master
          )
        }
        
        parsed_metadata <- parse_data_guidance(
          guidance_file()
        )
        
        parsed_metadata
      })
      
      
      # --------------------------------------------------------
      # Temporary diagnostic checks
      # Useful during hackathon development
      # --------------------------------------------------------
      
      observe({
        
        req(app_data())
        req(metadata())
        
        matched_variables <- metadata() |>
          dplyr::filter(
            variable %in% names(app_data())
          ) |>
          dplyr::distinct(
            variable,
            .keep_all = TRUE
          )
        
        message(
          "Variables in current data: ",
          ncol(app_data())
        )
        
        message(
          "Variables matched to metadata: ",
          nrow(matched_variables)
        )
        
        message(
          "Current data columns:"
        )
        
        print(
          names(app_data())
        )
        
        message(
          "Matched metadata variables:"
        )
        
        print(
          matched_variables$variable
        )
      })
      
      
      # --------------------------------------------------------
      # Return data and metadata
      # --------------------------------------------------------
      
      return(
        list(
          data = app_data,
          metadata = metadata
        )
      )
    }
  )
}