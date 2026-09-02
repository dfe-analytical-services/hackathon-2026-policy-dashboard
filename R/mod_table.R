# ============================================================
# Table module
# Filtered results + CSV download
# ============================================================

mod_table_ui <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    
    div(
      class = "table-header",
      
      h3("Filtered results"),
      
      downloadButton(
        ns("download"),
        "Download CSV"
      )
    ),
    
    DT::DTOutput(
      ns("results_table")
    )
  )
}


mod_table_server <- function(
    id,
    filtered_data
) {
  
  moduleServer(
    id,
    function(input, output, session) {
      
      output$results_table <- DT::renderDT({
        
        req(filtered_data())
        
        DT::datatable(
          filtered_data(),
          rownames = FALSE,
          filter = "top",
          options = list(
            pageLength = 10,
            scrollX = TRUE,
            autoWidth = TRUE
          )
        )
      })
      
      
      output$download <- downloadHandler(
        
        filename = function() {
          
          paste0(
            "policy-data-explorer-",
            Sys.Date(),
            ".csv"
          )
        },
        
        content = function(file) {
          
          readr::write_csv(
            filtered_data(),
            file,
            na = ""
          )
        }
      )
    }
  )
}