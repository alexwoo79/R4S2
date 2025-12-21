###
#clean_excel_template.R

#Template: read a possibly messy Excel sheet (merged cells, mixed formats),
#clean and coerce columns (dates and amounts), write cleaned output,
#and return a tibble for downstream analysis.

#Usage:
# - Edit the `file_path`, `sheet_name` and `skip_rows` variables below.
#- Source this file in an R session: `source('clean_excel_template.R')`
#- The final object returned is `df_clean` (a tibble).

#Notes:
# - Excel serial dates on Windows commonly use origin = '1899-12-30'.
#- Amount parsing uses `readr::parse_number()` so thousands separators
# and currency symbols are handled automatically.
###

## ---- Libraries ----
library(here)
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(lubridate)
library(openxlsx)
library(janitor)


# 记录处理时间
start <- now()
## ---- Configuration ----
# Set these before running the script
file_path <- file.path('origin_xlsx', 'income.xlsx') # relative to this script or an absolute path
sheet_name <- '收入类台账' # sheet to read
skip_rows <- 2 # rows to skip before the header row
out_path <- file.path('output', 'income_cleaned.xlsx')

## ---- Safety check ----
if (!file.exists(file_path)) {
  stop('source file not found: ', file_path)
}

## ---- Read and basic cleanup ----
# readxl reads merged cells as NA under the merged area; we'll remove all-empty
# rows/cols then keep rows after the very top header row if necessary.
df_raw <- readxl::read_excel(
  file_path,
  sheet = sheet_name,
  skip = skip_rows,
  col_names = TRUE,
  .name_repair = 'unique'
) |>
  remove_empty(which = c('rows', 'cols'))

# (optional) If the first row after removal is a second header, drop it; adjust as needed
if (nrow(df_raw) > 0 && any(stringr::str_detect(names(df_raw), '^...'))) {
  df_raw <- slice(df_raw, 2:n())
}
## ---- 检查列号的辅助代码 ----
# 创建包含列序号的新行
new_row <- as.data.frame(t(as.character(1:ncol(df_raw))))
colnames(new_row) <- colnames(df_raw)
# 将新行添加到数据框顶部
result <- rbind(new_row, df_raw)[1:2, ]
# 查看结果
result

## ---- Column selection helpers ----
# Identify amount and date-like columns by name pattern. Customize patterns if needed.
names(df_raw)[6] <- '合同名称'
names(df_raw) <- stringr::str_remove_all(names(df_raw), '[\r|\n|.]')

# Clean text columns using the clean_text function
clean_text <- function(x) {
  v <- as.character(x)
  # remove carriage return, newline, spaces, dots, quotes, etc.
  v <- str_replace_all(v, '[\r\n]', '') # remove CR/LF
  v <- str_replace_all(v, '["]', '') # remove quotes
  # v <- str_replace_all(v, '[.]', '') # remove dots
  v <- str_trim(v) # trim leading/trailing whitespace
  v
}
df_raw <- df_raw |>
  mutate(
    项目名称 = clean_text(项目名称),
    合同名称 = clean_text(合同名称),
    甲方单位名称 = clean_text(甲方单位名称),
    单价描述 = clean_text(单价描述),
    总建面 = clean_text(总建面)
  )

# 按照列中的数据类型，将数据列和日期列的编号汇总，后续如果插入列则需要对应修改其中的序号。根据列好辅助结果result来检查对应情况。
#——————————————————#
# 部门合同列 [14:27] #
# 部门收入列 [53:66] #
# 部门回款列 [67:80] #
#——————————————————#
amount_cols <- names(df_raw)[c(13:27, 32, 33, 36, 38, 40, 42, 47:80)]
date_cols <- names(df_raw)[c(3, 35, 37, 39, 41, 46)]

## ---- Helper functions ----
# Clean text columns: remove whitespace, CR/LF, quotes, and punctuation

# Parse amounts robustly (keeps decimal point, handles grouping separators and currency symbols)
parse_amount <- function(x) {
  v <- as.character(x)
  # remove anything except digits and decimal point
  v2 <- str_replace_all(v, "[^0-9.]", '')
  # empty strings become NA
  v2[v2 == ""] <- NA_character_
  as.numeric(v2)
}

# Parse dates which may be Excel serials or common date strings.
# Use origin = '1899-12-30' for Excel (Windows); adjust if your files differ.
parse_excel_date <- function(x) {
  v <- as.character(x)
  cleaned <- str_replace_all(v, "[^0-9.]", "")
  out <- rep(as.Date(NA), length(v))

  for (i in seq_along(v)) {
    c <- cleaned[i]
    orig <- v[i]
    if (is.na(c) || c == "") {
      parsed <- parse_date_time(
        orig,
        orders = c(
          'Ymd',
          'Y-m-d',
          'Y/m/d',
          'd/m/Y',
          'm/d/Y',
          'Ymd HMS',
          'Y-m-d H:M:S'
        ),
        quiet = TRUE
      )
      out[i] <- as_date(parsed)
      next
    }

    # if contains a dot, cleaned is numeric-like with fraction -> possible Excel float
    if (str_detect(c, "\\.")) {
      num <- suppressWarnings(as.numeric(c))
      # only treat as Excel serial if within a plausible day-range
      if (!is.na(num) && num > -10000 && num < 100000) {
        out[i] <- as.Date(num, origin = '1899-12-30')
      } else {
        # otherwise fallback to parsing original string
        parsed <- parse_date_time(
          orig,
          orders = c('Ymd', 'Y-m-d', 'Y/m/d', 'd/m/Y', 'm/d/Y'),
          quiet = TRUE
        )
        out[i] <- as_date(parsed)
      }
      next
    }

    # only digits remain
    if (nchar(c) >= 8) {
      # likely YYYYMMDD
      parsed <- suppressWarnings(ymd(c))
      if (!is.na(parsed)) {
        out[i] <- as_date(parsed)
      } else {
        num <- suppressWarnings(as.numeric(c))
        if (!is.na(num) && num > -10000 && num < 100000) {
          out[i] <- as.Date(num, origin = '1899-12-30')
        } else {
          # very large numeric values can cause integer coercion warnings; avoid as.Date
          parsed2 <- parse_date_time(
            orig,
            orders = c('Ymd', 'Y-m-d', 'Y/m/d', 'd/m/Y', 'm/d/Y'),
            quiet = TRUE
          )
          out[i] <- as_date(parsed2)
        }
      }
    } else {
      num <- suppressWarnings(as.numeric(c))
      if (!is.na(num) && num > -10000 && num < 100000) {
        out[i] <- as.Date(num, origin = '1899-12-30')
      } else {
        parsed <- parse_date_time(
          orig,
          orders = c('Ymd', 'Y-m-d', 'Y/m/d', 'd/m/Y', 'm/d/Y'),
          quiet = TRUE
        )
        out[i] <- as_date(parsed)
      }
    }
  }
  out
}

## ---- Cleaning pipeline ----
# 1) Fill down columns that were originally merged in Excel. Choose which columns
#    need fill-down; by default we fill the first 12 columns (usually identifiers).
fill_target_cols <- seq_len(min(12, ncol(df_raw)))

# 2) Parse amounts and dates, trim text, coerce numeric columns where appropriate.
df_clean <- df_raw |>
  tidyr::fill(all_of(fill_target_cols), .direction = 'down') |>
  mutate(across(all_of(amount_cols), ~ parse_amount(.x))) |>
  mutate(across(all_of(date_cols), ~ parse_excel_date(.x))) |>
  # Trim whitespace on character columns
  mutate(across(where(is.character), ~ str_trim(.x))) |>
  # Clean column names to a consistent format
  # janitor::clean_names()
  select(c(1:80))

## ---- Optional: further typing and derived columns ----
# Example: coerce some columns to factors or numeric explicitly, create helper cols
# df_clean <- df_clean |> mutate(status = as.factor(status))
df_out <- df_clean |>
  mutate(
    across(all_of(date_cols), ~ year(.), .names = "year_{.col}")
  )

## ---- Write cleaned workbook ----
wb <- createWorkbook()
addWorksheet(wb, sheetName = sheet_name)
writeData(wb, sheet = sheet_name, x = df_out, startRow = 1, colNames = TRUE)
## ---- Add Excel data validation ----
# Apply data validation to amount and date columns so users cannot enter invalid formats
n_rows <- nrow(df_out)
max_excel_row <- 1048576L
if (n_rows > 0) {
  amt_idx <- which(names(df_out) %in% amount_cols)
  date_idx <- which(names(df_out) %in% date_cols)

  # Amounts: numeric with optional decimal point, allow a wide numeric range
  if (length(amt_idx) > 0) {
    for (col in amt_idx) {
      # Apply validation to entire column (Excel max rows) so appended rows inherit it
      dataValidation(
        wb,
        sheet = sheet_name,
        cols = col,
        rows = 2:max_excel_row,
        type = 'decimal',
        operator = 'between',
        value = c(-1e12, 1e12),
        allowBlank = TRUE,
        showInputMsg = TRUE,
        showError = TRUE
      )
    }
  }

  # Dates: must be valid dates between a plausible range
  if (length(date_idx) > 0) {
    for (col in date_idx) {
      # Apply validation to entire column (Excel max rows)
      dataValidation(
        wb,
        sheet = sheet_name,
        cols = col,
        rows = 2:max_excel_row,
        type = 'date',
        operator = 'between',
        value = as.Date(c('1900-01-01', '9999-12-31')),
        allowBlank = TRUE,
        showInputMsg = TRUE,
        showError = TRUE
      )
    }
  }
}

## ---- Record run time and write metadata ----
end <- now()
elapsed_sec <- as.numeric(difftime(end, start, units = 'secs'))
run_info <- data.frame(
  run_started = start,
  run_finished = end,
  elapsed_seconds = elapsed_sec,
  rows = nrow(df_out),
  cols = ncol(df_out),
  stringsAsFactors = FALSE
)

# write run metadata to a separate sheet
addWorksheet(wb, sheetName = 'run_info')
writeData(wb, sheet = 'run_info', x = run_info, startRow = 1, colNames = TRUE)

saveWorkbook(wb, out_path, overwrite = TRUE)

## ---- Return result for interactive sessions ----
list(df_out = df_out, run_info = run_info)
