library(shiny)

# Source UI and server
source("ui.R")
source("server.R")

if (interactive()) {
  shinyApp(ui = ui, server = server)
} else {
  # When run non-interactively (for example via `Rscript app.R`),
  # run the app on host 0.0.0.0 and port 8080 so it's reachable externally.
  shiny::runApp(list(ui = ui, server = server), host = "0.0.0.0", port = 8080)
}
