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
file <- here::here('2024hr/data', 'income.xlsx')


#读取excel
data <- readxl::read_excel(file, col_names = T, sheet = 1, skip = 2)
# glimpse(data)
clean_data <- data[2:nrow(data), 1:82]
# names(clean_data)
part1 <- clean_data |>
  select(c(1:27)) |>
  fill(c(1:13), .direction = 'down') |>
  rename_with(~ str_remove_all(., "[...[:digit:]]")) |>
  mutate(across(c(14:27), as.numeric)) |>
  pivot_longer(cols = c(14:27), names_to = 'Department', values_to = 'Value') |>
  drop_na()

names(part1)
names(clean_data)

part2 <- clean_data |>
  select(c(1:13, 53:66)) |>
  fill(c(1:13), .direction = 'down') |>
  rename_with(~ str_remove_all(., "[...[:digit:]]")) |>
  mutate(across(c(14:27), as.numeric)) |>
  pivot_longer(
    cols = c(14:27),
    names_to = 'Department',
    values_to = 'income'
  ) |>
  drop_na()
names(part2)

part3 <- clean_data |>
  select(c(1:13, 67:80)) |>
  fill(c(1:13), .direction = 'down') |>
  rename_with(~ str_remove_all(., "[...[:digit:]]")) |>
  mutate(across(c(14:27), as.numeric)) |>
  pivot_longer(cols = c(14:27), names_to = 'Department', values_to = 'cash') |>
  drop_na()
names(part3)

# sum(part1$合同总金额)
sum(part1$Value)
sum(part2$income)
sum(part3$cash)

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
