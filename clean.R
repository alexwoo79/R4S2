library(readxl)
library(janitor)
library(dplyr)
library(here)
library(tibble)

roster_raw <- read_excel(here("./clean_data/dirty_data.xlsx")) # available at https://github.com/sfirke/janitor
glimpse(roster_raw)


roster_raw2 <- roster_raw |>
  row_to_names(row_number = 1) |>
  clean_names()


# 提取原始 header（第一行）并转换为字符向量
orig_names <- roster_raw |>
  slice_head(n = 1) |>
  unlist(use.names = FALSE) |>
  as.character()

# 清理后列名
clean_names_vec <- colnames(roster_raw2)

# 如果长度不匹配，先对齐或填 NA
n <- max(length(orig_names), length(clean_names_vec))
orig_names <- c(orig_names, rep(NA_character_, n - length(orig_names)))
clean_names_vec <- c(
  clean_names_vec,
  rep(NA_character_, n - length(clean_names_vec))
)

# 建表对比
compare_names <- tibble(
  position = seq_len(n),
  original = orig_names,
  cleaned = clean_names_vec,
  cleaned_by_make_clean_names = janitor::make_clean_names(original),
  changed = !is.na(original) & (janitor::make_clean_names(original) != cleaned)
)

# 显示差异行（changed == TRUE）
compare_names
compare_names |> filter(changed)


# 查看列名,使用names()函数
names(compare_names)
names(roster_raw)
names(roster_raw2)

str(compare_names)
glimpse(compare_names)
colnames(compare_names)

ct <- tibble(
  a = head(roster_raw, 1) |> unlist() |> as.character(),
  a1 = row_to_names(roster_raw, row_number = 1) |> clean_names() |> names(),
  b = names(roster_raw2)
)
ct
