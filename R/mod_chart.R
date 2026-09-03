# ============================================================
# Policy Data Explorer
# Dynamic chart module
# ============================================================


# ------------------------------------------------------------
# UI
# ------------------------------------------------------------

mod_chart_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    
    div(
      class = "panel-card",
      
      h3("Break down by"),
      
      selectInput(
        ns("breakdown"),
        label = NULL,
        choices = NULL
      ),
      
      plotly::plotlyOutput(
        ns("chart"),
        height = "420px"
      )
    )
  )
}


# ------------------------------------------------------------
# Server
# ------------------------------------------------------------

mod_chart_server <- function(
    id,
    filtered_data,
    measure
) {
  
  moduleServer(
    id,
    function(input, output, session) {
      
      
      # --------------------------------------------------------
      # Possible breakdown variables
      #
      # First matching column present in the uploaded dataset
      # will be used for each logical category.
      # --------------------------------------------------------
      
      breakdown_definitions <- list(
        
        "Academic year" = c(
          "academic_year",
          "time_period",
          "year"
        ),
        
        "Age group" = c(
          "age_group",
          "age_band",
          "age_summary"
        ),
        
        "Provision type" = c(
          "provision_type",
          "provider_type",
          "provision"
        ),
        
        "Subject area" = c(
          "sector_subject_area",
          "sector_subject_area_t1",
          "sector_subject_area_tier_1",
          "ssa_tier_1",
          "subject_area",
          "subject"
        ),
        
        "Region" = c(
          "region_name",
          "region"
        ),
        
        "Local authority" = c(
          "local_authority_name",
          "local_authority",
          "la_name"
        ),
        
        "Provider" = c(
          "provider_name",
          "provider"
        ),
        
        "Level of qualification" = c(
          "level_of_qualification",
          "qualification_level",
          "level"
        ),
        
        "Qualification type" = c(
          "qualification_type"
        ),
        
        "Regulated qualifications" = c(
          "regulated_qualifications"
        )
      )
      
      
      # --------------------------------------------------------
      # Find breakdown columns available in current dataset
      # --------------------------------------------------------
      
      available_breakdowns <- reactive({
        
        req(filtered_data())
        
        data_columns <- names(
          filtered_data()
        )
        
        
        matched <- lapply(
          breakdown_definitions,
          function(possible_columns) {
            
            matches <- possible_columns[
              possible_columns %in%
                data_columns
            ]
            
            if (
              length(matches) == 0
            ) {
              
              return(NULL)
            }
            
            matches[[1]]
          }
        )
        
        
        keep <- !vapply(
          matched,
          is.null,
          logical(1)
        )
        
        
        matched <- matched[
          keep
        ]
        
        
        if (
          length(matched) == 0
        ) {
          
          return(
            character(0)
          )
        }
        
        
        stats::setNames(
          unlist(
            matched,
            use.names = FALSE
          ),
          names(matched)
        )
      })
      
      
      # --------------------------------------------------------
      # Update breakdown dropdown
      # --------------------------------------------------------
      
      observe({
        
        choices <- available_breakdowns()
        
        req(
          length(choices) > 0
        )
        
        
        current_breakdown <- isolate(
          input$breakdown
        )
        
        
        if (
          !is.null(current_breakdown) &&
          current_breakdown %in%
          unname(choices)
        ) {
          
          selected_breakdown <-
            current_breakdown
          
        } else if (
          "Subject area" %in%
          names(choices)
        ) {
          
          # Prefer Subject area for the demo
          selected_breakdown <-
            unname(
              choices[
                "Subject area"
              ]
            )
          
        } else {
          
          selected_breakdown <-
            unname(
              choices[[1]]
            )
        }
        
        
        updateSelectInput(
          session = session,
          inputId = "breakdown",
          choices = choices,
          selected = selected_breakdown
        )
      })
      
      
      # --------------------------------------------------------
      # Build chart data
      # --------------------------------------------------------
      
      chart_data <- reactive({
        
        req(filtered_data())
        req(measure())
        req(input$breakdown)
        
        
        df <- filtered_data()
        
        measure_var <-
          measure()
        
        breakdown_var <-
          input$breakdown
        
        
        validate(
          need(
            measure_var %in%
              names(df),
            "Selected measure is not available in this dataset."
          ),
          
          need(
            breakdown_var %in%
              names(df),
            "Selected breakdown is not available in this dataset."
          )
        )
        
        
        # ------------------------------------------------------
        # Convert measure safely to numeric
        # ------------------------------------------------------
        
        measure_values <-
          suppressWarnings(
            readr::parse_number(
              as.character(
                df[[
                  measure_var
                ]]
              )
            )
          )
        
        
        chart_df <-
          tibble::tibble(
            
            breakdown =
              as.character(
                df[[
                  breakdown_var
                ]]
              ),
            
            value =
              measure_values
          )
        
        
        # Remove missing/blank breakdowns
        chart_df <-
          chart_df |>
          dplyr::filter(
            !is.na(breakdown),
            trimws(breakdown) != "",
            !is.na(value)
          )
        
        
        # Aggregate selected measure by breakdown
        chart_df <-
          chart_df |>
          dplyr::group_by(
            breakdown
          ) |>
          dplyr::summarise(
            value = sum(
              value,
              na.rm = TRUE
            ),
            .groups = "drop"
          ) |>
          dplyr::arrange(
            dplyr::desc(value)
          )
        
        
        # ------------------------------------------------------
        # Keep chart readable
        # Show top 15 categories
        # ------------------------------------------------------
        
        chart_df |>
          dplyr::slice_head(
            n = 15
          )
      })
      
      
      # --------------------------------------------------------
      # Render chart
      # --------------------------------------------------------
      
      output$chart <- plotly::renderPlotly({
        
        df <- chart_data()
        
        
        validate(
          need(
            nrow(df) > 0,
            "No data available for this breakdown."
          )
        )
        
        
        # Reverse ordering so largest item appears at top
        df <- df |>
          dplyr::arrange(
            value
          )
        
        
        df$breakdown <-
          factor(
            df$breakdown,
            levels =
              df$breakdown
          )
        
        
        plotly::plot_ly(
          
          data = df,
          
          x = ~value,
          
          y = ~breakdown,
          
          type = "bar",
          
          orientation = "h",
          
          hovertemplate =
            paste0(
              "%{y}<br>",
              "%{x:,}",
              "<extra></extra>"
            )
        ) |>
          
          plotly::layout(
            
            xaxis = list(
              title = NULL,
              separatethousands = TRUE
            ),
            
            yaxis = list(
              title = NULL,
              automargin = TRUE
            ),
            
            margin = list(
              l = 180,
              r = 30,
              t = 20,
              b = 50
            ),
            
            showlegend = FALSE
          )
      })
      
      
      # --------------------------------------------------------
      # Diagnostics
      # --------------------------------------------------------
      
      observe({
        
        req(filtered_data())
        
        message(
          "Available chart breakdowns:"
        )
        
        print(
          available_breakdowns()
        )
      })
    }
  )
}
