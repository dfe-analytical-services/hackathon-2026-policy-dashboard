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


mod_filters_server <- function(id, data) {
  
  moduleServer(
    id,
    function(input, output, session) {
      
      observe({
        
        req(data())
        
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
      
      
      return(
        list(
          
          measure = reactive(
            input$measure
          ),
          
          academic_year = reactive(
            input$academic_year
          ),
          
          age_group = reactive(
            input$age_group
          ),
          
          provision_type = reactive(
            input$provision_type
          ),
          
          subject = reactive(
            input$subject
          ),
          
          region = reactive(
            input$region
          )
        )
      )
    }
  )
}