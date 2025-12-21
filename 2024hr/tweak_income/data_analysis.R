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


# library(DBI)
# library(RSQLite)

# # 连接到SQLite数据库
# con <- dbConnect(RSQLite::SQLite(), "output/income_database.db")

# # 执行查询获取数据
# query <- "SELECT * FROM income"
# df_raw <- dbGetQuery(con, query)

# # 关闭数据库连接
# dbDisconnect(con)

## ---- Configuration ----
# Set these before running the script
# file_path <- file.path('output', 'income_cleaned.xlsx') # relative to this script or an absolute path
file_path <- file.path('output', 'income_cleaned_csv.csv')
# sheet_name <- '收入类台账' # sheet to read
# skip_rows <- 0 # rows to skip before the header row

# ## ---- Safety check ----
if (!file.exists(file_path)) {
  stop('source file not found: ', file_path)
}

## ---- Read and basic cleanup ----
# readxl reads merged cells as NA under the merged area; we'll remove all-empty
# rows/cols then keep rows after the very top header row if necessary.
# df_raw <- readxl::read_excel(
#   file_path,
#   sheet = sheet_name,
#   skip = skip_rows,
#   col_names = TRUE,
#   .name_repair = 'unique'
# ) |>
#   remove_empty(which = c('rows'))

df_raw <- read_csv(
  file_path,
  col_names = TRUE
) |>
  remove_empty(which = c('rows'))
#————————————————————————————————————————————————————————————
# 查看列名称编号
#————————————————————————————————————————————————————————————

# 创建包含列序号的新行
new_row <- as.data.frame(t(as.character(1:ncol(df_raw))))
colnames(new_row) <- colnames(df_raw)
# 将新行添加到数据框顶部
result <- rbind(new_row, df_raw)[1:2, ]
# 查看结果
result
#——————————————————#
# 部门合同列 [14:27] #
# 部门收入列 [53:66] #
# 部门回款列 [67:80] #
#——————————————————#

#————————————————————————————————————————————————————————————
# 计算度量值
#————————————————————————————————————————————————————————————
df_clean <- df_raw |>
  mutate(
    across(where(is.numeric), ~ ifelse(is.na(.x), 0, .x))
  )

colnames(df_raw)
options(digits = 2)


contract_total <- round(sum(df_clean$合同总金额, na.rm = T), 2)
contract_depart <- round(sum(df_clean[14:27], na.rm = T), 2)
income_total <- round(sum(df_clean$收入金额, na.rm = T), 2)
income_depart <- round(sum(df_clean[53:66], na.rm = T), 2)
cash_total <- round(sum(df_clean$回款金额, na.rm = T), 2)
cash_depart <- round(sum(df_clean[67:80], na.rm = T), 2)

print(paste(
  '合同总额=',
  contract_total / 10000,
  '万元',
  'VS',
  '部门合计=',
  contract_depart / 10000,
  '万元'
))
print(paste(
  '收入总额=',
  income_total / 10000,
  '万元',
  'VS',
  '部门合计=',
  income_depart / 10000,
  '万元'
))
print(paste(
  '回款总额=',
  cash_total / 10000,
  '万元',
  'VS',
  '部门合计=',
  cash_depart / 10000,
  '万元'
))

#————————————————————————————————————————————————————————————
# df_clean$c_year <- year(df_clean$签订日期)

# 构造所有日期的年度列，便于汇总分析

contact_by_year <- df_clean |>
  group_by(year(签订日期)) |>
  summarise(total_contact = sum(合同总金额, na.rm = T))
print(contact_by_year)

income_by_year <- df_clean |>
  group_by(year(收入日期)) |>
  summarise(total_income = sum(收入金额, na.rm = T))
print(income_by_year)

cash_by_year <- df_clean |>
  group_by(year(回款时间)) |>
  summarise(total_cash = sum(回款金额, na.rm = T))
print(cash_by_year)
#————————————————————————————————————————————————————————————
income_by_location <- df_clean |>
  group_by(区域) |>
  summarise(total_income = sum(收入金额, na.rm = T)) |>
  arrange(desc(total_income))
print(income_by_location)

#————————————————————————————————————————————————————————————
data_by_location <- df_clean |>
  group_by(区域) |>
  summarise(
    total_contact = sum(合同总金额, na.rm = T),
    total_income = sum(收入金额, na.rm = T),
    total_cash = sum(回款金额, na.rm = T)
  ) |>
  arrange(desc(total_income))
print(data_by_location)
#————————————————————————————————————————————————————————————
data_by_year <- df_clean |>
  group_by(year_签订日期) |>
  summarise(
    total_contact = sum(合同总金额, na.rm = T),
    total_income = sum(收入金额, na.rm = T),
    total_cash = sum(回款金额, na.rm = T)
  ) |>
  arrange(desc(year_签订日期))
print(data_by_year)
#————————————————————————————————————————————————————————————
data_by_project <- df_clean |>
  group_by(项目名称) |>
  summarise(
    total_contact = sum(合同总金额, na.rm = T),
    total_income = sum(收入金额, na.rm = T),
    total_cash = sum(回款金额, na.rm = T)
  ) |>
  arrange(desc(total_income))
print(data_by_project)

#————————————————————————————————————————————————————————————

contract_by_depart <- df_clean |>
  select(c(1:27)) |>
  pivot_longer(
    cols = c(14:27),
    values_to = 'contract_value',
    names_to = 'department'
  )
contract_by_depart <- contract_by_depart |>
  filter(contract_value > 0) |>
  mutate(
    department = stringr::str_remove(as.character(department), "\\d+$") |>
      stringr::str_trim()
  )

contract_j <- contract_by_depart |>
  group_by(department) |>
  summarise(contract = sum(contract_value, na.rm = T))
#————————————————————————————————————————————————————————————

income_by_depart <- df_clean |>
  select(c(1:13, 53:66)) |>
  pivot_longer(
    cols = c(14:27),
    values_to = 'income_value',
    names_to = 'department'
  )
income_by_depart <- income_by_depart |>
  filter(income_value > 0) |>
  mutate(
    department = stringr::str_remove(as.character(department), "\\d+$") |>
      stringr::str_trim()
  )

income_j <- income_by_depart |>
  group_by(department) |>
  summarise(income = sum(income_value, na.rm = T))
#————————————————————————————————————————————————————————————
cash_by_depart <- df_clean |>
  select(c(1:13, 67:80)) |>
  pivot_longer(
    cols = c(14:27),
    values_to = 'cash_value',
    names_to = 'department'
  )
cash_by_depart <- cash_by_depart |>
  filter(cash_value > 0) |>
  mutate(
    department = stringr::str_remove(as.character(department), "\\d+$") |>
      stringr::str_trim()
  )

cash_j <- cash_by_depart |>
  group_by(department) |>
  summarise(cash = sum(cash_value, na.rm = T))
#————————————————————————————————————————————————————————————

# 部门数据合并，合同+收入+回款
merge <- contract_j |> left_join(income_j) |> left_join(cash_j)
# merge$department <- as.factor(merge$department)

print(merge)
# 部门数据对比
library(ggplot2)
merge |>
  filter(department != '项目管理') |>
  pivot_longer(cols = c(2, 3, 4), values_to = 'value', names_to = 'type') |>
  ggplot(aes(x = reorder(department, desc(value)), y = value, fill = type)) +
  geom_col(position = 'dodge', show.legend = F) +
  facet_wrap(~type, ncol = 1) +
  scale_y_continuous(labels = function(x) {
    format(x / 10000, scientific = FALSE)
  }) +
  ylab('金额（万元）') +
  xlab('部门') +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
#————————————————————————————————————————————————————————————
#应收账款

df_clean |>
  group_by(区域) |>
  summarise(total = sum(应收账款, na.rm = T)) |>
  arrange(desc(total))
glimpse(df_clean)
colnames(df_clean)

部门合同列 <- names(df_clean)[14:27]
部门收入列 <- names(df_clean)[53:66]
部门回款列 <- names(df_clean)[67:80]

# 对多个列的结果在行方向多数据相加。求跨列汇总数据，
# 使用rowwise（） + c_across（）
df_clean_with_dept_sums <- df_clean |>
  rowwise() |>
  mutate(
    部门合同 = sum(c_across(all_of(部门合同列)), na.rm = TRUE),
    部门收入 = sum(c_across(all_of(部门收入列)), na.rm = TRUE),
    部门回款 = sum(c_across(all_of(部门回款列)), na.rm = TRUE)
  ) |>
  ungroup()

# 查看结果
head(df_clean_with_dept_sums)

# 2025年数据统计
df_summary <- df_clean_with_dept_sums |>
  # filter(year(签订日期) == 2025) |>
  group_by(year(签订日期)) |>
  summarise(
    contract = sum(合同总金额, na.rm = T),
    部门合同合计 = sum(部门合同, na.rm = T),
    income = sum(收入金额, na.rm = T),
    部门收入合计 = sum(部门收入, na.rm = T),
    cash = sum(回款金额, na.rm = T),
    部门回款合计 = sum(部门回款, na.rm = T)
  )

print(df_summary)

df_summary2 <- df_clean_with_dept_sums |>
  # filter(year(签订日期) == 2025) |>
  group_by(year(收入日期)) |>
  summarise(
    contract = sum(合同总金额, na.rm = T),
    部门合同合计 = sum(部门合同, na.rm = T),
    income = sum(收入金额, na.rm = T),
    部门收入合计 = sum(部门收入, na.rm = T),
    cash = sum(回款金额, na.rm = T),
    部门回款合计 = sum(部门回款, na.rm = T)
  )

print(df_summary2)

df_summary3 <- df_clean_with_dept_sums |>
  # filter(year(签订日期) == 2025) |>
  group_by(year(回款时间)) |>
  summarise(
    contract = sum(合同总金额, na.rm = T),
    部门合同合计 = sum(部门合同, na.rm = T),
    income = sum(收入金额, na.rm = T),
    部门收入合计 = sum(部门收入, na.rm = T),
    cash = sum(回款金额, na.rm = T),
    部门回款合计 = sum(部门回款, na.rm = T)
  )

print(df_summary3)

counts1 <- df_clean_with_dept_sums |>
  filter(!is.na(收入日期), is.na(收入金额)) |>
  select(收入日期, 收入金额) |>
  count()

counts2 <- df_clean_with_dept_sums |>
  filter(is.na(收入日期), !is.na(收入金额)) |>
  select(收入日期, 收入金额) |>
  count()

counts3 <- df_clean_with_dept_sums |>
  filter(!is.na(收入日期), is.na(部门收入)) |>
  select(收入日期, 部门收入) |>
  count()

counts4 <- df_clean_with_dept_sums |>
  filter(is.na(收入日期), !is.na(部门收入)) |>
  select(收入日期, 部门收入) |>
  count()


print(paste('收入日期为空，收入金额有数据的条目个数为', counts1))
print(paste('收入日期有数据，收入金额为空的条目个数为', counts2))
print(paste('收入日期为空，部门收入金额有数据的条目个数为', counts3))
print(paste('收入日期有数据，部门收入金额为空的条目个数为', counts4))

df <- df_clean_with_dept_sums |>
  mutate(
    合同总金额 = replace_na(合同总金额, 0), # 等价于ifelse，更简洁
    部门合同 = replace_na(部门合同, 0),
    部门收入 = replace_na(部门收入, 0),
    部门回款 = replace_na(部门回款, 0)
  ) |>
  filter(
    合同总金额 != 0 | 部门合同 != 0 | 部门收入 != 0 | 部门回款 != 0
  )


sum(df$合同总金额, na.rm = T)
sum(df$部门合同, na.rm = T)
sum(df$部门收入, na.rm = T)
sum(df$部门回款, na.rm = T)

# 西南公司历年咨询确认收入为多少元

df |>
  filter(区域 == '西南') |>
  group_by(year_收入日期) |>
  summarise(total = sum(咨询60, na.rm = T))

tc <- sum(merge$contract)
ti <- sum(merge$income, na.rm = T)
ts <- sum(merge$cash, na.rm = T)

print(c(tc, ti, ts))
