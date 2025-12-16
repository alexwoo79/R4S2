# Core processing function for one sheet
#' process_sheet
#' @param path path to the uploaded xlsx file
#' @param sheet sheet name or index
#' @return tibble with rank_score for that sheet
process_sheet <- function(path, sheet) {
  # read sheet (sheet can be name or index)
  data <- readxl::read_excel(path, col_names = FALSE, sheet = sheet)

  # basic validation
  if (nrow(data) < 13 || ncol(data) < 8) {
    stop(sprintf("Sheet %s: data too small to extract expected ranges", sheet))
  }

  department <- as.character(dplyr::pull(data[2, 3]))
  Number <- as.character(dplyr::pull(data[2, 8]))

  data_raw <- data[10:(nrow(data) - 3), c(2:7)]
  names(data_raw) <- c('Name', 'Leader', 'p1', 'p2', 'p3', 'p4')

  data_raw <- data_raw %>%
    tidyr::fill(Name, .direction = "down") %>%
    dplyr::mutate(
      dplyr::across(dplyr::starts_with('p'), as.numeric),
      dplyr::across(dplyr::where(is.character), as.factor),
      department = department
    )

  rank_score <- data_raw %>%
    dplyr::group_by(Name) %>%
    dplyr::mutate(total = sum(p1, p2, p3, p4, na.rm = TRUE) / 2) %>%
    dplyr::select(Name, total, department) %>%
    dplyr::distinct(Name, total, department) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      rank_score = rank(-total, ties.method = "min"),
      grade = dplyr::case_when(
        rank_score <= dplyr::n() * 0.23 ~ "A",
        rank_score <= dplyr::n() * 0.90 ~ "B",
        TRUE ~ "C"
      )
    ) %>%
    dplyr::arrange(grade) %>%
    dplyr::mutate(
      sheet = as.character(sheet),
      original_n = Number
    ) %>%
    dplyr::select(sheet, dplyr::everything())

  rank_score
}
