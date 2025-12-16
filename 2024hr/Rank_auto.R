library(tidyverse)
library(readxl)

# 输入文件（与你脚本中的 file 变量相同）
file <- here::here('2024hr/data', 'employee_score.xlsx')

# 单 sheet 处理函数
process_sheet <- function(sheet, file) {
  data <- readxl::read_excel(file, col_names = FALSE, sheet = sheet)

  # 基本检查
  if (nrow(data) < 13 || ncol(data) < 8) {
    stop(glue::glue("Sheet {sheet}: 数据尺寸太小，无法按预期提取"))
  }

  department <- as.character(pull(data[2, 3]))
  Number <- as.character(pull(data[2, 8]))

  data_raw <- data[10:(nrow(data) - 3), c(2:7)]
  names(data_raw) <- c('Name', 'Leader', 'p1', 'p2', 'p3', 'p4')

  data_raw <- data_raw %>%
    tidyr::fill(Name, .direction = "down") %>%
    mutate(
      across(starts_with('p'), as.numeric),
      across(where(is.character), as.factor),
      department = department
    )

  rank_score <- data_raw %>%
    group_by(Name) %>%
    mutate(total = sum(p1, p2, p3, p4, na.rm = TRUE) / 2) %>%
    select(Name, total, department) %>%
    distinct(Name, total, department) %>%
    ungroup() %>%
    mutate(
      rank_score = rank(-total, ties.method = "min"),
      grade = case_when(
        rank_score <= n() * 0.23 ~ "A",
        rank_score <= n() * 0.90 ~ "B",
        TRUE ~ "C"
      )
    ) %>%
    arrange(grade) %>%
    mutate(
      sheet = as.character(sheet),
      original_n = Number
    ) %>%
    select(sheet, everything())

  rank_score
}

# 选择要处理的 sheets（这里取前三个；也可以用具体名字）
all_sheets <- readxl::excel_sheets(file)
target_sheets <- all_sheets[1:4] # or e.g. c("Sheet1", "Sheet2", "Sheet3")

# 用 safely 防止单个 sheet 错误中断
safe_process <- purrr::safely(process_sheet)

res_list <- purrr::map(target_sheets, ~ safe_process(.x, file = file))

# 抽取成功结果，记录失败信息
results <- purrr::map_dfr(res_list, "result", .id = "sheet_index")
errors <- purrr::imap(
  res_list,
  ~ if (!is.null(.x$error)) {
    tibble(sheet = target_sheets[as.integer(.y)], error = .x$error$message)
  } else {
    NULL
  }
) %>%
  compact() %>%
  bind_rows()

# 结果查看
results
if (nrow(errors) > 0) {
  message("Some sheets failed:")
  print(errors)
}

# 可选：把每个 sheet 的结果单独保存为 csv
purrr::walk2(target_sheets, res_list, function(s, r) {
  if (!is.null(r$result)) {
    out_name <- paste0("rank_score_", make.names(s), ".csv")
    readr::write_csv(r$result, out_name)
  }
})

# 合并所有 sheet 的汇总（例如保存）
readr::write_csv(results, "rank_score_all_sheets.csv")
