# ============================================================
# Policy Data Explorer - Summary module
# KPI cards + selected query + generated summary
# ============================================================


mod_summary_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    
    # --------------------------------------------------------
    # KPI cards
    # --------------------------------------------------------
    
    fluidRow(
      
      column(
        width = 4,
        
        div(
          class = "kpi-card",
          
          div(
            class = "kpi-label",
            textOutput(
              ns("measure_label")
            )
          ),
          
          div(
            class = "kpi-value",
            textOutput(
              ns("headline")
            )
          )
        )
      ),
      
      
      column(
        width = 4,
        
        div(
          class = "kpi-card",
          
          div(
            class = "kpi-label",
            "Rows returned"
          ),
          
          div(
            class = "kpi-value",
            textOutput(
              ns("rows_returned")
            )
          )
        )
      ),
      
      
      column(
        width = 4,
        
        div(
          class = "kpi-card",
          
          div(
            class = "kpi-label",
            "Active filters"
          ),
          
          div(
            class = "kpi-value",
            textOutput(
              ns("active_filters")
            )
          )
        )
      )
    ),
    
    
    # --------------------------------------------------------
    # Selected query
    # --------------------------------------------------------
    
    div(
      class = "panel-card",
      
      h4("Your selected query"),
      
      div(
        class = "query-box",
        
        textOutput(
          ns("question")
        )
      )
    ),
    
    
    # --------------------------------------------------------
    # Generated summary
    # --------------------------------------------------------
    
    div(
      class = "panel-card",
      
      h4("Generated summary"),
      
      p(
        "A summary based on the filters selected."
      ),
      
      div(
        class = "query-box",
        
        textOutput(
          ns("generated_summary")
        )
      )
    )
  )
}


mod_summary_server <- function(
    id,
    filtered_data,
    measure,
    filters
) {
  
  moduleServer(
    id,
    function(input, output, session) {
      
      # ------------------------------------------------------
      # Measure label
      # ------------------------------------------------------
      
      output$measure_label <- renderText({
        
        req(measure())
        
        if (measure() == "enrolments") {
          return("Enrolments")
        }
        
        if (measure() == "achievements") {
          return("Achievements")
        }
        
        measure()
      })
      
      
      # ------------------------------------------------------
      # Headline total
      # ------------------------------------------------------
      
      output$headline <- renderText({
        
        req(
          filtered_data(),
          measure()
        )
        
        values <- suppressWarnings(
          as.numeric(
            filtered_data()[[
              measure()
            ]]
          )
        )
        
        scales::comma(
          sum(
            values,
            na.rm = TRUE
          )
        )
      })
      
      
      # ------------------------------------------------------
      # Rows returned
      # ------------------------------------------------------
      
      output$rows_returned <- renderText({
        
        req(filtered_data())
        
        scales::comma(
          nrow(
            filtered_data()
          )
        )
      })
      
      
      # ------------------------------------------------------
      # Active filter count
      # ------------------------------------------------------
      
      output$active_filters <- renderText({
        
        current_filters <- filters()
        
        sum(
          vapply(
            current_filters,
            function(x) {
              length(x) > 0
            },
            logical(1)
          )
        )
      })
      
      
      # ------------------------------------------------------
      # Selected query
      # ------------------------------------------------------
      
      output$question <- renderText({
        
        req(measure())
        
        current_filters <- filters()
        
        pieces <- character(0)
        
        
        if (length(current_filters$academic_year) > 0) {
          
          pieces <- c(
            pieces,
            paste(
              "Academic year:",
              paste(
                current_filters$academic_year,
                collapse = ", "
              )
            )
          )
        }
        
        
        if (length(current_filters$age_group) > 0) {
          
          pieces <- c(
            pieces,
            paste(
              "Age:",
              paste(
                current_filters$age_group,
                collapse = ", "
              )
            )
          )
        }
        
        
        if (length(current_filters$provision_type) > 0) {
          
          pieces <- c(
            pieces,
            paste(
              "Provision:",
              paste(
                current_filters$provision_type,
                collapse = ", "
              )
            )
          )
        }
        
        
        if (length(current_filters$subject) > 0) {
          
          pieces <- c(
            pieces,
            paste(
              "Subject:",
              paste(
                current_filters$subject,
                collapse = ", "
              )
            )
          )
        }
        
        
        if (length(current_filters$region) > 0) {
          
          pieces <- c(
            pieces,
            paste(
              "Region:",
              paste(
                current_filters$region,
                collapse = ", "
              )
            )
          )
        }
        
        
        measure_text <-
          ifelse(
            measure() == "enrolments",
            "enrolments",
            "achievements"
          )
        
        
        if (length(pieces) == 0) {
          
          paste(
            "Showing all available",
            measure_text
          )
          
        } else {
          
          paste0(
            "Showing ",
            measure_text,
            " for ",
            paste(
              pieces,
              collapse = " | "
            )
          )
        }
      })
      
      
      # ------------------------------------------------------
      # Generated plain-English summary
      # ------------------------------------------------------
      
      output$generated_summary <- renderText({
        
        req(
          filtered_data(),
          measure()
        )
        
        current_filters <- filters()
        
        values <- suppressWarnings(
          as.numeric(
            filtered_data()[[
              measure()
            ]]
          )
        )
        
        total <- sum(
          values,
          na.rm = TRUE
        )
        
        
        measure_text <-
          ifelse(
            measure() == "enrolments",
            "enrolments",
            "achievements"
          )
        
        
        details <- character(0)
        
        
        # Age
        if (length(current_filters$age_group) > 0) {
          
          details <- c(
            details,
            paste(
              paste(
                current_filters$age_group,
                collapse = ", "
              ),
              "learners"
            )
          )
        }
        
        
        # Provision type
        if (length(current_filters$provision_type) > 0) {
          
          details <- c(
            details,
            paste(
              "on",
              paste(
                current_filters$provision_type,
                collapse = ", "
              ),
              "provision"
            )
          )
        }
        
        
        # Subject
        if (length(current_filters$subject) > 0) {
          
          details <- c(
            details,
            paste(
              "in",
              paste(
                current_filters$subject,
                collapse = ", "
              )
            )
          )
        }
        
        
        # Region
        if (length(current_filters$region) > 0) {
          
          details <- c(
            details,
            paste(
              "in",
              paste(
                current_filters$region,
                collapse = ", "
              )
            )
          )
        }
        
        
        # Academic year
        if (length(current_filters$academic_year) > 0) {
          
          details <- c(
            details,
            paste(
              "during",
              paste(
                current_filters$academic_year,
                collapse = ", "
              )
            )
          )
        }
        
        
        if (length(details) == 0) {
          
          paste0(
            "There were ",
            scales::comma(total),
            " ",
            measure_text,
            " in the currently available data."
          )
          
        } else {
          
          paste0(
            "There were ",
            scales::comma(total),
            " ",
            measure_text,
            " for ",
            paste(
              details,
              collapse = " "
            ),
            "."
          )
        }
      })
    }
  )
}