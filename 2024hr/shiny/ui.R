library(shiny)
library(DT)

ui <- fluidPage(
  titlePanel("Rank Scores - Excel Sheets"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload Excel (.xlsx)", accept = c(".xlsx")),
      uiOutput("sheet_ui"),
      checkboxInput(
        "write_csv",
        "Save per-sheet CSVs (server-side)",
        value = FALSE
      ),
      actionButton("run", "Process sheets", class = "btn-primary"),
      br(),
      br(),
      downloadButton("download_all", "Download combined CSV")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Summary", DT::dataTableOutput("results")),
        tabPanel("Per-sheet", uiOutput("per_sheet_tabs")),
        tabPanel("Logs", verbatimTextOutput("logs"))
      )
    )
  )
)
