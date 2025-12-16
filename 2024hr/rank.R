# Packages Load
if (!require('pacman')) {
  install.packages('pacman')
  library(pacman)
} else {
  library(pacman)
}
pacman::p_load('tidyverse')
pacman::p_load('here')


# excle文件位置
file <- here::here('2024hr/data', 'employee_score.xlsx')


#读取excel
data <- readxl::read_excel(file, col_names = F, sheet = 1)

#取出核心数据
#部门位置
department <- pull(data[2, 3])
#人数位置
Number <- pull(data[2, 8])
#前9行和倒数3行，保留2:7列
data_raw <- data[10:(nrow(data) - 3), c(2:7)]
#更改列名
names(data_raw) <- c('Name', 'Leader', 'p1', 'p2', 'p3', 'p4')

library(tidyr)
data_raw <- data_raw |>
  fill(Name, .direction = "down") |>
  mutate(
    across(starts_with('p'), as.numeric),
    across(where(is.character), as.factor),
    department = department
  )
# data_raw

rank_score <- data_raw |>
  group_by(Name) |>
  mutate(total = sum(p1, p2, p3, p4) / 2) |>
  select(Name, total, department) |>
  distinct(Name, total, department) |>
  ungroup() |>
  mutate(
    rank_score = rank(-total),
    grade = case_when(
      rank_score <= n() * 0.23 ~ "A",
      rank_score <= n() * 0.90 ~ "B",
      TRUE ~ "C"
    )
  ) |>
  arrange(grade)

print(rank_score)
