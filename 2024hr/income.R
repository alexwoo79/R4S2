# ---
# title: "数据检查问题"
# format: html
# ---

# 项目管理中心台账数据检查

## 1. 数据导入

#| echo: false
#| warning: false
# Packages Load
# if (!require('pacman')) {
#   install.packages('pacman')
#   library(pacman)
# } else {
#   library(pacman)
# }
# pacman::p_load('tidyverse')
# pacman::p_load('here')
# pacman::p_load('dplyr')
# pacman::p_load('ggplot2')
library(tidyverse)

# excle文件位置
file2 <- here::here('2024hr/data', 'income.xlsx')

file <- here::here('2024hr/data', 'income.csv')
#读取excel
data2 <- readxl::read_excel(file2, col_names = T, sheet = 1, skip = 2)
data <- read.csv(file, na.strings = c('<empty>', 'NA'))
names <- colnames(data2)
colnames(data) <- names

#抽取2到最后,1:82列
clean_data <- data[4:nrow(data), 1:82]
str(clean_data)

clean_data <- clean_data %>%
  mutate(across(everything(), ~ ifelse(. == '', NA, .)))


## 2. 数据基本结构
# 导入后数据有 92列,抽取其中的82列。

### 问题 1:合并单元格造成数据关系极为混乱
# 因为excel文件多处单元格合并，经过数据导入后，很多数据在同一条记录内，多个列数据为空。造成数据对应关系极为混乱。很难对应同一个合同项目的数据归集。

### 问题 2:列太多，数据横向查询极为不便
# 表格列数量太多，核心数据查询非常苦难。合同，收入，回款，三个大块内容下罗列了所用部门，并横向展开为列。

### 问题 3:核心数据记录导入R后丢失
# 合同签订日期和合同总金额列在同一行时，有的行数据没有日期，或者没有合同总金额。信息检索存在严重错误。应该是同一日期有多个合同签订的情况，但是合并单元格造成了数据缺失。数据对其有一定的难度。

### 问题 4:待定

## 3.数据处理
### 3.1 数据对整
# 将签订日期和合同总金额作为核心数据，假定：有合同总金额的记录，必须有一条签订日期。如果没有，用上一个日期，向下填充。

### 3.2 part0 日期与金额数据列检查

part0 <- clean_data %>%
  filter(is.na(签订日期) & !is.na(合同总金额)) %>%
  select(c(1:13))

part0[c(3, 13)]

# 有48条记录存在有合同总金额但是没有签订日期。

### 3.3 对齐数据,整理出主合同台账
# part1数据包括所有合同主体信息和，部门合同，部门收入，部门回款列信息。下一步分离合同，收入，回款信息。

total_contact <- clean_data |>
  select(
    c(
      区域,
      签订日期,
      项目名称,
      合同编号,
      类型,
      contains('甲方单位\n名称'),
      合同总金额
    ),
  ) |>
  rename(甲方名称 = '甲方单位\n名称') |>
  filter(!is.na(合同总金额)) |>
  mutate(
    签订日期 = suppressWarnings(as.numeric(签订日期)),
    合同总金额 = as.numeric(合同总金额),
    签订日期 = as.Date(签订日期, origin = "1899-12-30"),
    Year = as.factor(year(签订日期))
  ) |>
  select(Year, everything()) |>
  fill(everything())

total_contact$key <- seq(1, length(total_contact$合同总金额))
total_contact
nrow(total_contact)
ncol(total_contact)
length(total_contact$签订日期)
length(total_contact$合同总金额)
summary(total_contact)
write_csv(total_contact, 'total_contact.csv')

pacman::p_load(psych)
describe(total_contact)

# 历年合同总金额bar图

library(ggplot2)
p1 <- total_contact |>
  group_by(Year) |>
  summarise(Total = sum(合同总金额, na.rm = TRUE)) |>
  ungroup() |>
  # convert to 万元 (10,000) units; change divisor to 1000 if you prefer thousands
  mutate(Total_wan = Total / 10000)

# plot using 万元 units and formatted y-axis (commas, one decimal)
p1 <- p1 |>
  mutate(
    label = scales::label_number(big.mark = ",", accuracy = 0.1)(Total_wan)
  )

p1 |>
  ggplot(aes(x = Year, y = Total_wan)) +
  geom_col(fill = 'skyblue') +
  geom_text(aes(label = label), vjust = -0.3, size = 3, color = "black") +
  labs(
    x = '',
    y = '合同额（万元）',
    title = '历年新签合同额'
  ) +
  scale_y_continuous(
    labels = scales::label_number(big.mark = ",", accuracy = 0.1),
    # expand = scales::expansion(mult = c(0, 0.08))
  ) +
  theme_bw()
sum(total_contact$合同总金额)

### 4 分离部门合同部分，逆透视
# 使用part1数据，抽取部门部门合同部分，并清理列名称得到部门合同相关数据。

names(clean_data)
department_contact <- clean_data |>
  select(
    c(
      区域,
      签订日期,
      项目名称,
      合同编号,
      类型,
      contains('甲方单位\n名称'),
      合同总金额
    ),
    c(14:27)
  ) |>
  mutate(
    across(c(7:21), as.numeric)
  ) |>
  rename_with(~ str_remove_all(., "[...[:digit:]]")) |>
  rename(甲方名称 = '甲方单位\n名称') |>
  mutate(across(c(8:21), ~ ifelse(. == 0, NA, .)))

# 8:21列任何一列不为空，则补充其他列数据，对其部门合同数据的颗粒度。
department_contact_T <- department_contact |>
  filter(if_any(1:21, ~ !is.na(.))) |>
  fill(1:7, .direction = "down") |>
  pivot_longer(cols = c(8:21), names_to = 'Department', values_to = 'Value') |>
  mutate(
    签订日期 = suppressWarnings(as.numeric(签订日期)),
    合同总金额 = as.numeric(合同总金额),
    签订日期 = as.Date(签订日期, origin = "1899-12-30"),
    Year = as.factor(year(签订日期))
  ) |>
  select(Year, everything()) |>
  filter(!is.na(Value))


sum(department_contact_T$Value, na.rm = T)

# 合同分部门汇总
department_table <- department_contact_T |>
  fill(Year) |>
  group_by(Year, Department) |>
  summarise(Total = sum(Value, na.rm = T) / 10000)
department_table

department_total_contact <- department_contact_T |>
  select(1:8) |>
  distinct()

# 合同总金额提取测试

sum(department_contact$合同总金额, na.rm = T)

library(ggplot2)
department_table |>
  ggplot(aes(x = Year, y = Total, fill = Department)) +
  geom_col(color = 'black', alpha = .6) +
  # geom_text(aes(label = Total), vjust = -0.3, size = 3, color = "black") +
  labs(
    x = '',
    y = '合同额（万元）',
    title = '各部门历年新签合同额（权益）'
  ) +
  scale_y_continuous(
    labels = scales::label_number(big.mark = ",", accuracy = 0.1),
    # expand = scales::expansion(mult = c(0, 0.08))
  ) +
  # coord_flip()+
  theme_bw()


# 收入数据提取

names(clean_data)
department_income <- clean_data |>
  select(
    c(
      区域,
      签订日期,
      项目名称,
      合同编号,
      类型,
      contains('甲方单位\n名称'),
      合同总金额
    ),
    c(53:66)
  ) |>
  mutate(
    across(c(7:21), as.numeric)
  ) |>
  rename_with(~ str_remove_all(., "[...[:digit:]]")) |>
  rename(甲方名称 = '甲方单位\n名称') |>
  mutate(across(c(8:21), ~ ifelse(. == 0, NA, .))) |>
  filter(if_any(1:21, ~ !is.na(.))) |>
  fill(c(1:7)) |>
  pivot_longer(cols = c(8:21), names_to = 'Department', values_to = 'Income') |>
  filter(!is.na(Income))

sum(department_income$Income, na.rm = TRUE)

D_income <- department_income |>
  group_by(Department) |>
  summarise(Total = sum(Income))

D_income

# 回款数据提取

names(clean_data)
department_got <- clean_data |>
  select(
    c(
      区域,
      签订日期,
      项目名称,
      合同编号,
      类型,
      contains('甲方单位\n名称'),
      合同总金额
    ),
    c(67:80)
  ) |>
  mutate(
    across(c(7:21), as.numeric)
  ) |>
  rename_with(~ str_remove_all(., "[...[:digit:]]")) |>
  rename(甲方名称 = '甲方单位\n名称') |>
  mutate(across(c(8:21), ~ ifelse(. == 0, NA, .))) |>
  filter(if_any(1:21, ~ !is.na(.))) |>
  fill(c(1:7)) |>
  pivot_longer(cols = c(8:21), names_to = 'Department', values_to = 'Got') |>
  filter(!is.na(Got))


sum(department_got$Got, na.rm = TRUE)

D_Got <- department_got |>
  group_by(Department) |>
  summarise(Total = sum(Got))

D_Got
