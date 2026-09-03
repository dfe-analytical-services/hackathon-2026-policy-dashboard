mod_filters_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    
    selectInput(
      ns("measure"),
      "Measure",
      choices = NULL # updated to be based on the file uploaded
    ),
    
    selectizeInput(
      ns("academic_year"),
      "Academic year",
      choices = NULL,
      multiple = TRUE
    ),
    
    selectizeInput(
      ns("age_group"),
      "Age group",
      choices = NULL,
      multiple = TRUE
    ),
    
    selectizeInput(
      ns("provision_type"),
      "Provision type",
      choices = NULL,
      multiple = TRUE
    ),
    
    selectizeInput(
      ns("subject"),
      "Subject area",
      choices = NULL,
      multiple = TRUE
    ),
    
    selectizeInput(
      ns("region"),
      "Region",
      choices = NULL,
      multiple = TRUE
    ),
    
    actionButton(
      ns("reset"),
      "Reset filters"
    )
  )
}


mod_filters_server <- function(id,
                               data,
                               metadata # allow metadata to be used
                               ) {
  
  moduleServer(
    id,
    function(input, output, session) {
      
      # ------------------------------------------------------
      # Update filter choices from the loaded dataset
      # ------------------------------------------------------
      # find available filters
      available_filters <- reactive({
        
        req(data())
        
        metadata() |>
          dplyr::filter(
            role %in% c("filter", "dimension"),
            variable %in% names(data())
          ) |>
          dplyr::group_by(variable) |>
          dplyr::slice(1) |>
          dplyr::ungroup() |>
          dplyr::select(
            variable,
            label
          )
        
      })
      
      
      # tempt test - check the filters shiny thinks are available
      observe({
        
        req(available_filters())
        
        message("Available filters:")
        
        print(
          available_filters()
        )
        
      })
      
      # temp test 2  - check metadata roles
      observe({
        
        req(metadata())
        
        message("Metadata roles:")
        
        print(
          metadata() |>
            dplyr::count(role)
        )
        
      })
      
      observe({
        
        req(data())
        
        # temp test
        message("Columns in uploaded dataset: ")
        print(names(data()))
        
        available_measures <- variables_master |>
          dplyr::filter(
            role == "measure",
            variable %in% names(data())
            ) |>
          dplyr::arrange(display_order)

        updateSelectInput(
          session,
          "measure",
          choices = stats::setNames(
            available_measures$variable,
            available_measures$label
          ),
          selected = available_measures$variable[[1]]
        )
        
        updateSelectizeInput(
          session,
          "academic_year",
          choices = sort(unique(data()$academic_year)),
          server = TRUE
        )
        
        updateSelectizeInput(
          session,
          "age_group",
          choices = sort(unique(data()$age_group)),
          server = TRUE
        )
        
        updateSelectizeInput(
          session,
          "provision_type",
          choices = sort(unique(data()$provision_type)),
          server = TRUE
        )
        
        updateSelectizeInput(
          session,
          "subject",
          choices = sort(unique(data()$sector_subject_area)),
          server = TRUE
        )
        
        updateSelectizeInput(
          session,
          "region",
          choices = sort(unique(data()$region_name)),
          server = TRUE
        )
      })
      
      
      # ------------------------------------------------------
      # Reset filters
      # ------------------------------------------------------
      
      observeEvent(
        input$reset,
        {
          
          updateSelectizeInput(
            session,
            "academic_year",
            selected = character(0)
          )
          
          updateSelectizeInput(
            session,
            "age_group",
            selected = character(0)
          )
          
          updateSelectizeInput(
            session,
            "provision_type",
            selected = character(0)
          )
          
          updateSelectizeInput(
            session,
            "subject",
            selected = character(0)
          )
          
          updateSelectizeInput(
            session,
            "region",
            selected = character(0)
          )
        }
      )
      
      
      # ------------------------------------------------------
      # Apply selected filters to the data
      # ------------------------------------------------------
      
      filtered_data <- reactive({
        
        filtered <- data()
        
        
        if (length(input$academic_year) > 0) {
          
          filtered <- filtered |>
            dplyr::filter(
              academic_year %in% input$academic_year
            )
        }
        
        
        if (length(input$age_group) > 0) {
          
          filtered <- filtered |>
            dplyr::filter(
              age_group %in% input$age_group
            )
        }
        
        
        if (length(input$provision_type) > 0) {
          
          filtered <- filtered |>
            dplyr::filter(
              provision_type %in% input$provision_type
            )
        }
        
        
        if (length(input$subject) > 0) {
          
          filtered <- filtered |>
            dplyr::filter(
              sector_subject_area %in% input$subject
            )
        }
        
        
        if (length(input$region) > 0) {
          
          filtered <- filtered |>
            dplyr::filter(
              region_name %in% input$region
            )
        }
        
        
        filtered
      })
      
      
      # ------------------------------------------------------
      # Current selected filters
      # ------------------------------------------------------
      
      current_filters <- reactive({
        
        list(
          academic_year = input$academic_year,
          age_group = input$age_group,
          provision_type = input$provision_type,
          subject = input$subject,
          region = input$region
        )
      })
      
      
      # ------------------------------------------------------
      # Return everything needed by the other modules
      # ------------------------------------------------------
      
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