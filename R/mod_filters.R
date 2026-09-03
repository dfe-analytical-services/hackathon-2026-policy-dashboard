mod_filters_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    
    selectInput(
      ns("measure"),
      "Measure",
      choices = NULL # updated to be based on the file uploaded
    ),
    
    # allow filters to be dynamic, rather than static
    uiOutput(
      ns("dynamic_filters")
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
      
      # add dynamic UI filter
      output$dynamic_filters <- renderUI({
        
        req(data())
        req(available_filters())
        
        filter_list <- lapply(
          seq_len(nrow(available_filters())),
          function(i) {
            
            filter_var <- available_filters()$variable[i]
            filter_label <- available_filters()$label[i]
            
            selectizeInput(
              inputId = session$ns(filter_var),
              label = filter_label,
              choices = sort(
                unique(data()[[filter_var]])
              ),
              multiple = TRUE
            )
            
          }
        )
        
        do.call(
          tagList,
          filter_list
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
        
        # make academic year filter conditional on academic year existing in the data
        if ("academic_year" %in% names(data())) {
          
          updateSelectizeInput(
            session,
            "academic_year",
            choices = sort(unique(data()$academic_year)),
            server = TRUE
          )
          
        }
        
        # make age_group filter conditional on age_group existing in data
        if ("age_group" %in% names(data())) {
          updateSelectizeInput(
            session,
            "age_group",
            choices = sort(unique(data()$age_group)),
            server = TRUE
          )
        }
        
        if ("provision_type" %in% names(data())) {
          updateSelectizeInput(
            session,
            "provision_type",
            choices = sort(unique(data()$provision_type)),
            server = TRUE
          )
        }
        
        if ("subject" %in% names(data())) {
          updateSelectizeInput(
            session,
            "subject",
            choices = sort(unique(data()$sector_subject_area)),
            server = TRUE
          )
        }
        
        if ("region" %in% names(data())) {
          updateSelectizeInput(
            session,
            "region",
            choices = sort(unique(data()$region_name)),
            server = TRUE
          )
        }
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
        
        # ensure academic year can only be filtered if it exists in the uploaded data
        if (
          "academic_year" %in% names(filtered) &&
          length(input$academic_year) > 0
        ) {
          
          filtered <- filtered |>
            dplyr::filter(
              academic_year %in% input$academic_year
            )
        }
        
        
        if (
          "age_group" %in% names(filtered) &&
          length(input$age_group) > 0
        ) {
          
          filtered <- filtered |>
            dplyr::filter(
              age_group %in% input$age_group
            )
        }
        
        
        if (
          "provision_type" %in% names(filtered) &&
          length(input$provision_type) > 0
        ) {
          
          filtered <- filtered |>
            dplyr::filter(
              provision_type %in% input$provision_type
            )
        }
        
        
        if (
          "sector_subject_area" %in% names(filtered) &&
          length(input$sector_subject_area) > 0
        ) {
          
          filtered <- filtered |>
            dplyr::filter(
              sector_subject_area %in% input$subject
            )
        }
        
        
        if (
          "region_name" %in% names(filtered) &&
          length(input$region_name) > 0
        ) {
          
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