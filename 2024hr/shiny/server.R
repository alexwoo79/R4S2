library(shiny)
library(readxl)
library(dplyr)
library(purrr)
library(DT)

source(file.path("R", "process_sheet.R"))

server <- function(input, output, session) {
  sheets_available <- reactiveVal(NULL)
  results_list <- reactiveVal(list())
  logs <- reactiveVal(character())

  observeEvent(input$file, {
    req(input$file)
    path <- input$file$datapath
    ss <- tryCatch(readxl::excel_sheets(path), error = function(e) NULL)
    sheets_available(ss)
    # update sheet selector
    output$sheet_ui <- renderUI({
      if (is.null(ss)) {
        return(NULL)
      }
      checkboxGroupInput(
        "sheets",
        "Choose sheets to process:",
        choices = ss,
        selected = ss
      )
    })
  })

  observeEvent(input$run, {
    req(input$file)
    path <- input$file$datapath
    ss <- sheets_available()
    selected <- input$sheets
    if (is.null(selected) || length(selected) == 0) {
      selected <- ss
    }

    showNotification("Processing sheets...", type = "message")
    safe_proc <- purrr::safely(function(sh) process_sheet(path, sh))
    res <- purrr::map(selected, safe_proc)

    # gather results and errors
    ok <- purrr::map(res, "result")
    err <- purrr::map(res, "error")

    names(ok) <- selected
    names(err) <- selected

    # store
    results_list(ok)

    # build logs
    log_lines <- purrr::imap(
      err,
      ~ if (!is.null(.x)) paste0(.y, ": ", .x$message) else NULL
    ) %>%
      compact()
    if (length(log_lines) == 0) {
      log_lines <- "All sheets processed successfully."
    }
    logs(log_lines)

    # optional: write per-sheet csvs
    if (isTRUE(input$write_csv)) {
      outdir <- tempdir()
      purrr::imap(ok, function(dat, nm) {
        if (!is.null(dat)) {
          out <- file.path(
            outdir,
            paste0("rank_score_", make.names(nm), ".csv")
          )
          readr::write_csv(dat, out)
        }
      })
      showNotification(
        paste0("Per-sheet CSVs written to: ", outdir),
        type = "message",
        duration = 5
      )
    }
  })

  output$results <- DT::renderDataTable({
    res <- results_list()
    if (length(res) == 0) {
      return(NULL)
    }
    combined <- purrr::compact(res) %>% purrr::map_dfr(identity)
    DT::datatable(combined, options = list(pageLength = 25))
  })

  output$per_sheet_tabs <- renderUI({
    res <- results_list()
    if (length(res) == 0) {
      return(tags$p("No results yet."))
    }
    tabs <- purrr::imap(res, function(dat, nm) {
      if (is.null(dat)) {
        tabPanel(nm, tags$p("Error or no data for this sheet."))
      } else {
        tabPanel(
          nm,
          DT::dataTableOutput(outputId = paste0("tbl_", make.names(nm)))
        )
      }
    })
    do.call(tabsetPanel, unname(tabs))
  })

  observe({
    res <- results_list()
    if (length(res) == 0) {
      return()
    }
    purrr::imap(res, function(dat, nm) {
      out_id <- paste0("tbl_", make.names(nm))
      output[[out_id]] <- DT::renderDataTable({
        req(dat)
        DT::datatable(dat, options = list(pageLength = 10))
      })
    })
  })

  output$logs <- renderText({
    paste(logs(), collapse = "\n")
  })

  output$download_all <- downloadHandler(
    filename = function() "rank_score_all_sheets.csv",
    content = function(file) {
      res <- results_list()
      if (length(res) == 0) {
        write.csv(data.frame(), file, row.names = FALSE)
      } else {
        combined <- purrr::compact(res) %>% purrr::map_dfr(identity)
        readr::write_csv(combined, file)
      }
    }
  )
}
