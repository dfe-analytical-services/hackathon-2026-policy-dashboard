# ============================================================
# Policy Data Explorer - Chart module
# ============================================================

mod_chart_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    
    selectInput(
      ns("breakdown"),
      "Break down by",
      choices = c(
        "Subject area" = "sector_subject_area",
        "Region" = "region_name",
        "Age group" = "age_group",
        "Provision type" = "provision_type"
      )
    ),
    
    plotly::plotlyOutput(
      ns("chart"),
      height = "420px"
    )
  )
}


mod_chart_server <- function(
    id,
    filtered_data,
    measure
) {
  
  moduleServer(
    id,
    function(input, output, session) {
      
      chart_data <- reactive({
        
        req(
          filtered_data(),
          measure(),
          input$breakdown
        )
        
        req(
          input$breakdown %in% names(filtered_data()),
          measure() %in% names(filtered_data())
        )
        
        result <- filtered_data() |>
          dplyr::mutate(
            measure_value = suppressWarnings(
              as.numeric(
                .data[[measure()]]
              )
            )
          ) |>
          dplyr::group_by(
            .data[[input$breakdown]]
          ) |>
          dplyr::summarise(
            value = sum(
              measure_value,
              na.rm = TRUE
            ),
            .groups = "drop"
          ) |>
          dplyr::arrange(
            dplyr::desc(value)
          ) |>
          dplyr::slice_head(
            n = 15
          )
        
        names(result)[1] <- "category"
        
        result
      })
      
      
      output$chart <- plotly::renderPlotly({
        
        data <- chart_data()
        
        req(
          nrow(data) > 0
        )
        
        plotly::plot_ly(
          data = data,
          x = ~value,
          y = ~reorder(category, value),
          type = "bar",
          orientation = "h",
          hovertemplate = paste0(
            "%{y}<br>",
            "%{x:,}",
            "<extra></extra>"
          )
        ) |>
          plotly::layout(
            
            xaxis = list(
              title = ""
            ),
            
            yaxis = list(
              title = "",
              automargin = TRUE
            ),
            
            margin = list(
              l = 180,
              r = 30,
              t = 20,
              b = 50
            )
          )
      })
    }
  )
}