# ============================================================
# Policy Data Explorer
# Dynamic filters module
# ============================================================


# ------------------------------------------------------------
# UI
# ------------------------------------------------------------

mod_filters_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    
    selectInput(
      ns("measure"),
      "Measure",
      choices = NULL
    ),
    
    uiOutput(
      ns("dynamic_filters")
    ),
    
    actionButton(
      ns("reset"),
      "Reset filters"
    )
  )
}


# ------------------------------------------------------------
# Server
# ------------------------------------------------------------

mod_filters_server <- function(
    id,
    data,
    metadata
) {
  
  moduleServer(
    id,
    function(input, output, session) {
      
      
      # --------------------------------------------------------
      # Match metadata to columns actually present in data
      # --------------------------------------------------------
      
      matched_metadata <- reactive({
        
        req(data())
        req(metadata())
        
        metadata() |>
          dplyr::filter(
            variable %in% names(data())
          ) |>
          dplyr::distinct(
            variable,
            .keep_all = TRUE
          )
      })
      
      
      # --------------------------------------------------------
      # Available measures
      # --------------------------------------------------------
      
      available_measures <- reactive({
        
        measures <- matched_metadata() |>
          dplyr::filter(
            role == "measure"
          )
        
        if (
          "display_order" %in% names(measures)
        ) {
          
          measures <- measures |>
            dplyr::arrange(
              display_order
            )
        }
        
        measures
      })
      
      
      # --------------------------------------------------------
      # Update measure selector
      # --------------------------------------------------------
      
      observe({
        
        measures <- available_measures()
        
        req(
          nrow(measures) > 0
        )
        
        current_measure <- isolate(
          input$measure
        )
        
        choices <- stats::setNames(
          measures$variable,
          measures$label
        )
        
        selected_measure <-
          if (
            !is.null(current_measure) &&
            current_measure %in% measures$variable
          ) {
            
            current_measure
            
          } else {
            
            measures$variable[[1]]
          }
        
        updateSelectInput(
          session = session,
          inputId = "measure",
          choices = choices,
          selected = selected_measure
        )
      })
      
      
      # --------------------------------------------------------
      # Available filters
      # --------------------------------------------------------
      
      available_filters <- reactive({
        
        filters <- matched_metadata() |>
          dplyr::filter(
            role %in% c(
              "filter",
              "dimension"
            )
          )
        
        
        # Respect default_filterable where available
        if (
          "default_filterable" %in%
          names(filters)
        ) {
          
          filters <- filters |>
            dplyr::filter(
              is.na(default_filterable) |
                default_filterable == TRUE
            )
        }
        
        
        if (
          "display_order" %in%
          names(filters)
        ) {
          
          filters <- filters |>
            dplyr::arrange(
              display_order
            )
        }
        
        
        filters |>
          dplyr::select(
            variable,
            label
          ) |>
          dplyr::distinct()
      })
      
      
      # --------------------------------------------------------
      # Create dynamic filters
      # --------------------------------------------------------
      
      output$dynamic_filters <- renderUI({
        
        req(data())
        
        filters <- available_filters()
        
        if (
          nrow(filters) == 0
        ) {
          
          return(
            tags$p(
              "No filters available for this dataset."
            )
          )
        }
        
        
        filter_controls <- lapply(
          seq_len(
            nrow(filters)
          ),
          function(i) {
            
            filter_var <- filters$variable[[i]]
            filter_label <- filters$label[[i]]
            
            
            # Get values from actual data column
            values <- data()[[
              filter_var
            ]]
            
            
            # Remove NA
            values <- values[
              !is.na(values)
            ]
            
            
            # Convert to character
            values <- as.character(
              values
            )
            
            
            # Remove blanks
            values <- values[
              trimws(values) != ""
            ]
            
            
            # Unique + sorted
            values <- sort(
              unique(values)
            )
            
            
            selectizeInput(
              inputId = session$ns(
                filter_var
              ),
              label = filter_label,
              choices = values,
              selected = character(0),
              multiple = TRUE,
              options = list(
                placeholder = paste(
                  "All",
                  filter_label
                ),
                closeAfterSelect = TRUE
              )
            )
          }
        )
        
        
        do.call(
          tagList,
          filter_controls
        )
      })
      
      
      # --------------------------------------------------------
      # Apply selected filters
      # --------------------------------------------------------
      
      filtered_data <- reactive({
        
        req(data())
        
        filtered <- data()
        
        filters <- available_filters()
        
        
        if (
          nrow(filters) == 0
        ) {
          
          return(
            filtered
          )
        }
        
        
        for (
          filter_var in filters$variable
        ) {
          
          selected_values <- input[[
            filter_var
          ]]
          
          
          # Only filter when user selected something
          if (
            !is.null(selected_values) &&
            length(selected_values) > 0
          ) {
            
            filtered <- filtered[
              as.character(
                filtered[[
                  filter_var
                ]]
              ) %in%
                as.character(
                  selected_values
                ),
              ,
              drop = FALSE
            ]
          }
        }
        
        
        filtered
      })
      
      
      # --------------------------------------------------------
      # Current selected filters
      # --------------------------------------------------------
      
      current_filters <- reactive({
        
        filters <- available_filters()
        
        
        if (
          nrow(filters) == 0
        ) {
          
          return(
            list()
          )
        }
        
        
        selected <- lapply(
          filters$variable,
          function(filter_var) {
            
            value <- input[[
              filter_var
            ]]
            
            if (
              is.null(value)
            ) {
              
              character(0)
              
            } else {
              
              value
            }
          }
        )
        
        
        names(selected) <- filters$variable
        
        selected
      })
      
      
      # --------------------------------------------------------
      # Reset filters
      # --------------------------------------------------------
      
      observeEvent(
        input$reset,
        {
          
          filters <- available_filters()
          
          if (
            nrow(filters) > 0
          ) {
            
            for (
              filter_var in filters$variable
            ) {
              
              updateSelectizeInput(
                session = session,
                inputId = filter_var,
                selected = character(0)
              )
            }
          }
        }
      )
      
      
      # --------------------------------------------------------
      # Diagnostics
      # --------------------------------------------------------
      
      observe({
        
        req(data())
        
        message(
          "Rows in current dataset: ",
          nrow(data())
        )
        
        message(
          "Columns in current dataset:"
        )
        
        print(
          names(data())
        )
        
        message(
          "Available measures:"
        )
        
        print(
          available_measures()
        )
        
        message(
          "Available filters:"
        )
        
        print(
          available_filters()
        )
      })
      
      
      # --------------------------------------------------------
      # Return
      # --------------------------------------------------------
      
      return(
        list(
          
          data = filtered_data,
          
          measure = reactive(
            input$measure
          ),
          
          filters = current_filters
        )
      )
    }
  )
}

