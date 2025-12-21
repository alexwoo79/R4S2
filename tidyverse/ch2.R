### ch2 数据操作

## 2.1 管道
library(tidyverse)
mtcars %>%
  group_by(cyl) %>%
  summarise(mpg_avg = mean(mpg))

month.abb %>%                    # 内置月份名缩写字符向量
  sample(6) %>% 
  tolower() %>% 
  str_c(collapse = "|")

str_c(tolower(sample(month.abb, 6)), collapse="|")

c(1, 3, 4, 5, NA) %>% 
  mean(., na.rm = TRUE)     # "."可以省略
c(1, 3, 4, 5, NA) %>% 
  mean(na.rm = TRUE)        # 推荐写法    

# 数据传递给plot第一个参数作为绘图数据(.省略), 
# 同时用于拼接成字符串给main参数用于图形标题
c(1, 3, 4, 5) %>% 
  plot(main = str_c(., collapse=","))

# 数据传递给第二个参数data
mtcars %>% plot(mpg ~ disp, data = .) 

# 选择列
iris %>% .$Species                   # 选择Species列内容
iris %>% pull(Species)               # 同上
iris %>% .[1:3]                      # 选择1-3列子集

mtcars %>%
  group_split(cyl) %>%                 
  map(~ lm(mpg ~ wt, data = .x))     

## 2.2 数据读写
library(readtext)
document = readtext("data/十年一觉.txt")
document

df = read_csv("data/六1班学生成绩.csv")
df

files = fs::dir_ls("data/read_datas", recurse = TRUE, glob = "*.xlsx")
files

library(readxl)
df = map_dfr(files, read_xlsx)  
head(df)

# 增加一列表明数据来自哪个文件
df = map_dfr(set_names(files), read_xlsx, .id = "来源")  
head(df)

map_dfr(set_names(files), read_xlsx, sheet = 1, .id = "来源")   # 或者
map_dfr(set_names(files), ~ read_xlsx(.x, sheet = 1), .id = "来源")

path = "data/学生成绩.xlsx"               # Excel文件路径 
df = map_dfr(set_names(excel_sheets(path)), 
             ~ read_xlsx(path, sheet = .x), .id = "sheet")  
head(df)

files = fs::dir_ls("data/read_datas", recurse = TRUE, glob = "*.csv")
df = read_csv(files)

library(writexl)
write_xlsx(df, "data/output_file.xlsx")

dfs = iris %>% 
  group_split(Species)        # 鸢尾花按组分割, 得到数据框列表
files = str_c("data/", levels(iris$Species), ".xlsx")  # 准备文件名
walk2(dfs, files, write_xlsx)

iris %>% group_nest(Species) %>% 
  mutate(Species = str_c("data/", Species, ".xlsx")) %>% 
  pwalk(~ write_xlsx(..2, ..1))

dfs = dfs %>% 
  set_names(levels(iris$Species))
write_xlsx(dfs, "data/iris.xlsx")

write_rds(iris, "my_iris.rds")
dat = read_rds("my_iris.rds")          # 导入.rds数据

## 连接数据库
library(RMariaDB)
con = dbConnect(MariaDB(), user = "root", password = "123456", 
                dbname = "mydb", host = "localhost")
dbListTables(con)     # 查看con连接下的数据表

datas = read_xlsx("data/ExamDatas.xlsx")
dbWriteTable(con, name = "exam", value = datas, overwrite = TRUE)
dbListTables(con)

df = tbl(con, "exam")
df

df %>% 
  group_by(sex) %>% 
  summarise(avg = mean(math, na.rm = TRUE))

df %>% 
  group_by(sex) %>% 
  summarise(avg = mean(math, na.rm = TRUE)) %>% 
  show_query()

dbGetQuery(con, "SELECT `sex`, AVG(`math`) AS `avg`
                 FROM `exam`
                 GROUP BY `sex`")

dbDisconnect(con)

## 编码与乱码
Sys.getlocale("LC_CTYPE")       # 查看系统默认字符集类型

# GBK文件，设置参数读取
read.csv("data/bp-gbk.csv", fileEncoding = "GBK")         
# UTF-8和BOM UTF-8, 直接读取
read.csv("data/bp-utf8nobom.csv")     
read.csv("data/bp-utf8bom.csv")
# GBK文件, 设置参数读取
readLines("data/bp-gbk.csv", encoding = "GBK")           
# UTF-8和BOM UTF-8, 直接读取 
readLines("data/bp-utf8nobom.csv")
readLines("data/bp-utf8bom.csv")

read_csv("data/bp-utf8nobom.csv")         # UTF-8, 直接读取
read_csv("data/bp-utf8bom.csv")           # BOM UTF-8, 直接读取
read_csv("data/bp-gbk.csv",           
         locale = locale(encoding="GBK"))  # GBK, 设置参数读取

# 写出为GBK文件
write.csv(df, "file-GBK.csv", fileEncoding = "GBK")           
# 写出为UTF-8文件
write.csv(df, "file-UTF8.csv")             
write_csv(df, "file-UTF8.csv")
# 写出为Excel打开不乱码的BOM UTF-8文件             
write_excel_csv(df, "file-BOM-UTF8.csv")  

## 2.3 数据连接
load("data/planes.rda")
planes %>%
  count(tailnum) %>%
  filter(n > 1)

load("data/weather.rda")
weather %>%
  count(year, month, day, hour, origin) %>%
  filter(n > 1)

bind_rows(
  sample_n(iris, 2),   # 随机抽取2个样本(行)
  sample_n(iris, 2),
  sample_n(iris, 2))

one = mtcars[1:4, 1:3]
two = mtcars[1:4, 4:5]
bind_cols(one, two)

band = band_members
band
instrument = band_instruments
instrument

band %>% 
  left_join(instrument, by = "name")

band %>% 
  right_join(instrument, by = "name")

band %>% 
  full_join(instrument, by = "name")

band %>% 
  inner_join(instrument, by = "name")

band %>% 
  semi_join(instrument, by = "name")

band %>% 
  anti_join(instrument, by = "name")

files = list.files("data/achieves/", pattern = "xlsx", full.names = TRUE)
map(files, read_xlsx) %>% 
  reduce(full_join, by = "人名")             # 读入并依次做全连接

path = "data/3-5月业绩.xlsx"
map(excel_sheets(path), 
    ~ read_xlsx(path, sheet = .x)) %>% 
  reduce(full_join, by = "人名")             # 读入并依次做全连接

# intersect(x, y)     # 返回x和y共同包含的观测
# union(x, y)         # 返回x和y 中所有的(唯一)观测
# setdiff(x, y)       # 返回在x中但不在y中的观测
# setequal(x, y)      # 判断集合x和y是否相等

## 2.4 数据重塑
dt = tribble(
  ~observation, ~A_count, ~B_count, ~A_dbh, ~B_dbh,
  "Richmond(Sam)",   7,       2,      100,    110,
  "Windsor(Ash)",   10,       5,      80,      87,
  "Bilpin(Jules)",   5,       8,      95,      90)
dt

tidy_dt = dt %>% 
  pivot_longer(-observation, 
               names_to = c("speices", ".value"),
               names_sep = "_") %>%  
  separate(observation, into = c("site", "surveyor"))
tidy_dt

## 宽变长
df = read_csv("data/年度GDP.csv")
df
df %>% 
  pivot_longer(-地区, names_to = "年份", values_to = "GDP")

load("data/family.rda")
family
family %>% 
  pivot_longer(-family, 
               names_to = c(".value", "child"), 
               names_sep = "_", 
               values_drop_na = TRUE)

df = read_csv("data/参赛队信息.csv")
df
df %>% 
  pivot_longer(everything(), 
               names_to = c("队员", ".value"), 
               names_pattern = "(.*\\d)(.*)")

## 长变宽
load("data/animals.rda") 
animals
animals %>%
  pivot_wider(names_from = Type, values_from = Heads, values_fill = 0)

us_rent_income
us_rent_income %>% 
  pivot_wider(names_from = variable, values_from = c(estimate, moe))

df = tibble(
  x = 1:6,
  y = c("A","A","B","B","C","C"),
  z = c(2.13,3.65,1.88,2.30,6.55,4.21))
df
df %>% 
  pivot_wider(names_from = y, values_from = z)

df = df[-1] 
df %>% 
  pivot_wider(names_from = y, values_from = z)

df = df %>% 
  group_by(y) %>% 
  mutate(n = row_number()) 
df
df %>% 
  pivot_wider(names_from = y, values_from = z)

contacts = tribble(  ~field, ~value,
                     "姓名", "张三",
                     "公司", "百度", 
                     "姓名", "李四", 
                     "公司", "腾讯", 
                     "Email", "Lisi@163.com",
                     "姓名", "王五") 
contacts = contacts %>% 
  mutate(ID = cumsum(field == "姓名"))
contacts
contacts %>% 
  pivot_wider(names_from = field, values_from = value)

## 分列与合并列
table3
table3 %>% 
  separate(rate, into = c("cases", "population"), sep = "/", 
           convert = TRUE)        # 同时转化为数值型

df = tibble(Class = c("1班", "2班"), 
            Name = c("张三，李四，王五", "赵六，钱七"))
df
df1 = df %>% 
  separate_rows(Name, sep = "，")
df1

df1 %>%                
  group_by(Class) %>% 
  summarise(Name = str_c(Name, collapse = "，"))

dt
dt %>%
  extract(observation, into = c("site", "surveyor"),
          regex = "(.*)\\((.*)\\)")

table5
table5 %>% 
  unite(new, century, year, sep = "")

world_bank_pop
pop2 = world_bank_pop %>% 
  pivot_longer(`2000`:`2017`, names_to = "year", values_to = "value")
pop2
pop2 %>% 
  count(indicator)

pop3 = pop2 %>% 
  separate(indicator, c(NA, "area", "variable"), sep = "\\.")
pop3

pop3 %>% 
  pivot_wider(names_from = variable, values_from = value)

## 方形化
library(repurrrsive)    # 使用got_chars数据集
chars = tibble(char = got_chars)
chars
chars1 = chars %>% 
  unnest_wider(char)
chars1

chars1 %>%
  select(name, title = titles) %>%
  unnest_longer(title)
chars %>% 
  hoist(char, name = "name", title = "titles") %>% 
  unnest_longer(title)

## 2.5 数据操作I
## 选择列
df = read_xlsx("data/ExamDatas_NAs.xlsx") 
df

df %>%
  select(name, sex, math)   # 或者select(2, 3, 5)

df %>%
  select(starts_with("m"))
df %>%
  select(ends_with("e"))
df %>%
  select(contains("a"))
df %>%
  select(matches("m.*a"))
df %>%
  select(where(is.numeric))
df[, 4:8] %>%
  select(where(~ sum(.x, na.rm = TRUE) > 3000))
df %>%
  select(where(~ n_distinct(.x) < 10))

df %>%
  select(-c(name, chinese, science))  # 或者select(-ends_with("e"))
df %>%   
  select(math, everything(), -ends_with("e"))

df %>%
  select(ends_with("e"), math, name, class, sex)
df %>%
  select(math, everything())

# 调整列序
df %>% 
  relocate(where(is.numeric), .after = name)

# 重命名列
df %>%
  set_names("班级", "姓名", "性别", "语文", 
            "数学", "英语", "品德", "科学") 
df %>%
  rename(数学 = math, 科学 = science)

df %>% 
  rename_with(~ paste0("new_", .x), matches("m"))

## 修改列
df %>%
  mutate(new_col = 5)
df %>%
  mutate(new_col = 1:n())

df %>%
  mutate(total = chinese + math + english + moral + science)

df %>%
  mutate(med = median(math, na.rm = TRUE),
         label = math > med,
         label = as.numeric(label)) 

df %>% 
  mutate(across(everything(), as.character)) 

rescale = function(x) {
  rng = range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
df %>% 
  mutate(across(where(is.numeric), rescale))

as_tibble(iris) %>%  
  mutate(across(contains("Length") | contains("Width"), ~ .x * 10)) 

## 简单插补缺失
starwars %>%
  replace_na(list(hair_color = "UNKNOWN", 
                  height = round(mean(.$height, na.rm = TRUE))))
starwars %>% 
  mutate(across(where(is.double), ~ replace_na(.x, mean(.x, na.rm = TRUE))))

load("data/gap_data.rda")
gap_data

gap_data %>% 
  fill(site, species)

## 重新编码
df %>%
  mutate(sex = if_else(sex == "男", "M", "F"))

df %>%
  mutate(math = case_when(math >= 75 ~ "High",
                          math >= 60 ~ "Middle",
                          TRUE       ~ "Low"))

library(sjmisc)
df %>% 
  rec(math, rec = "min:59=不及格; 60:74=中; 75:85=良; 85:max=优", 
      append = FALSE) %>% 
  frq()                       # 频率表

## 筛选行
set.seed(123)
df_dup = df %>%
  slice_sample(n = 60, replace = TRUE)

df_dup %>%   
  filter(sex == "男", math > 80) 
df_dup %>%
  filter(sex == "女", (is.na(english) | math > 80))
df_dup %>%
  filter(between(math, 70, 80))      # 闭区间

df %>%
  filter(if_all(4:6, ~ .x > 75))
df_dup %>% 
  filter(if_all(everything(), ~ !is.na(.x)))

starwars %>% 
  filter(if_any(everything(), ~ str_detect(.x, "bl")))
df %>%
  filter(if_any(where(is.numeric), ~ .x > 90))

df_dup %>% 
  filter(if_any(where(is.character), is.na))

df %>% 
  filter(pmap_lgl(.[4:6], ~ sum(c(...) < 60) == 2))

# 行切片
df %>% 
  slice_max(math, n = 5)

# 行去重
df_dup %>%
  distinct()
df_dup %>%
  distinct(sex, math, .keep_all = TRUE)  # 只根据sex和math判定重复

# 删除缺失
df_dup %>%
  drop_na()
df_dup %>%
  drop_na(sex:math)

df_dup %>%
  filter(!if_all(where(is.numeric), is.na))

## 排序行
df_dup %>%
  arrange(math, sex)
df_dup %>%
  arrange(-math)              # 同desc(math), 递减排序

## 分组操作
df_grp = df %>%
  group_by(sex)
df_grp

group_keys(df_grp)         # 分组键值(唯一识别分组)
group_indices(df_grp)      # 查看每一行属于哪一分组
group_rows(df_grp)         # 查看每一组包含哪些行
ungroup(df_grp)            # 解除分组

iris %>% 
  group_nest(Species)

iris %>% 
  group_by(Species) %>% 
  group_map(~ head(.x, 2))     # 提取每组的前两个观测

# 分组修改
load("data/stocks.rda")
stocks
stocks %>% 
  group_by(Stock) %>% 
  mutate(delta = Close - lag(Close))

# 分组筛选
stocks %>% 
  group_by(Stock) %>% 
  filter((Close - lag(Close)) / lag(Close) > 0.04)

stocks %>% 
  group_by(Stock) %>% 
  mutate(Gains = (Close - lag(Close)) / lag(Close)) %>% 
  filter(Gains > 0.04)

stocks %>% 
  group_by(Stock) %>% 
  slice_max(Close, n = 2)

# 分组汇总
df %>%
  group_by(sex) %>%
  summarise(n = n(),
            math_avg = mean(math, na.rm = TRUE),
            math_med = median(math))
df %>%
  group_by(class, sex) %>%
  summarise(across(contains("h"), mean, na.rm = TRUE))
df %>%
  select(-name) %>% 
  group_by(class, sex) %>%
  summarise(across(everything(), mean, na.rm = TRUE))
df_grp = df %>%
  group_by(class) %>%
  summarise(across(where(is.numeric), 
                   list(sum=sum, mean=mean, min=min), na.rm = TRUE))
df_grp
df_grp %>% 
  pivot_longer(-class, names_to = c("Vars", ".value"), names_sep = "_") 

qs = c(0.25, 0.5, 0.75)
df_q = df %>% 
  group_by(sex) %>%
  summarise(math_qs = quantile(math, qs, na.rm = TRUE), q = qs) 
df_q

df_q %>% 
  pivot_wider(names_from = q, values_from = math_qs, names_prefix = "q_")

# 分组计数
df %>%
  count(class, sex, sort = TRUE)

df %>%
  group_by(math_level = cut(math, breaks = c(0, 60, 75, 80, 100), 
                            right = FALSE)) %>%
  tally()

df %>%
  add_count(class, sex)

## 2.6 其他操作
## 行化
rf = df %>% 
  rowwise()
rf
rf %>% 
  mutate(total = sum(chinese, math, english))

rf %>% 
  mutate(total = sum(c_across(where(is.numeric))))

df %>% 
  mutate(total = rowSums(across(where(is.numeric))))

df %>% 
  rowwise(name) %>% 
  summarise(total = sum(c_across(where(is.numeric))))

# 逐行迭代四种写法
iris[1:4] %>%                         # apply
  mutate(avg = apply(., 1, mean))    
iris[1:4] %>%                         # rowwise (慢)
  rowwise() %>% 
  mutate(avg = mean(c_across())) 
iris[1:4] %>%                         # pmap
  mutate(avg = pmap_dbl(., ~ mean(c(...))))
iris[1:4] %>%                         # asplit(逐行分割) + map 
  mutate(avg = map_dbl(asplit(., 1), mean))

## 窗口函数
df %>% 
  mutate(ranks = min_rank(-math)) %>% 
  arrange(ranks)

library(lubridate)
dt = tibble(
  day = as_date("2019-08-30") + c(0,4:6),
  wday = weekdays(day),
  sales = c(2,6,2,3),
  balance = c(30, 25, -40, 30))
dt
dt %>% 
  mutate(sales_lag = lag(sales), sales_delta = sales - lag(sales))

x = c(1, 3, 5, 2, 2)
cumany(x >= 5)        # 从第一个出现x>=5选择后面所有值
cumany(!x < 5)        # 同上, 从第一个出现不满足x<5开始选择后面所有值
cumall(x < 5)         # 依次选择值直到第一个x<5不成立
cumall(!x >= 5)       # 同上, 依次选择值直到第一个出现x>=5

dt %>% 
  filter(cumany(balance < 0))      # 选择第一次透支之后的所有行 
dt %>% 
  filter(cumall(!(balance < 0)))   # 选择所有行直到第一次透支

## 滑窗迭代
library(slider)
dt %>%
  mutate(avg_3 = slide_dbl(sales, mean, .before = 1, .after = 1)) 

slide(dt$sales, ~ .x, .before = 1, .after = 1)
slide(dt$day, ~ .x, .before = 1, .after = 1)
slide_index(dt$day, dt$day, ~ .x, .before = 1, .after = 1)

dt %>%
  mutate(avg_3 = slide_index_dbl(sales, day, mean, 
                                 .before = 1, .after = 1))

## 整洁计算
var_summary = function(data, var) {
  data %>%
    summarise(n = n(), mean = mean({{var}}))
}
mtcars %>% 
  group_by(cyl) %>% 
  var_summary(mpg)

group_count = function(data, var) {
  data %>% 
    group_by(across({{var}})) %>%
    summarise(n = n())
}
group_count(mtcars, c(cyl, am))

var_summary = function(data, var) {
  data %>%
    summarise(n = n(), mean = mean(.data[[var]]))
}
mtcars %>% 
  group_by(cyl) %>% 
  var_summary("mpg")

mtcars[,9:10] %>% 
  names() %>% 
  map(~ count(mtcars, .data[[.x]]))

summarise_mean = function(data, vars) {
  data %>% 
    summarise(n = n(), across({{vars}}, mean))
}

mtcars %>% 
  group_by(cyl) %>% 
  summarise_mean(where(is.numeric))

vars = c("mpg", "vs")
mtcars %>% select(all_of(vars))
mtcars %>% select(!all_of(vars))

my_summarise = function(data, mean_var, sd_var) {
  data %>% 
    summarise("mean_{{mean_var}}" := mean({{mean_var}}), 
              "sd_{{sd_var}}" := mean({{sd_var}}))
}

mtcars %>% 
  group_by(cyl) %>% 
  my_summarise(mpg, disp)

my_summarise = function(data, group_var, summarise_var) {
  data %>%
    group_by(across({{group_var}})) %>% 
    summarise(across({{summarise_var}}, mean, .names = "mean_{.col}"))
}

mtcars %>% 
  my_summarise(c(am, cyl), where(is.numeric))

var_summary = function(data, var) {
  data %>%
    summarise(n = n(), 
              !!enquo(var) := mean(.data[[var]]))
}

mtcars %>%
  group_by(cyl) %>%
  var_summary("mpg")

var_summary = function(data, var) {
  data %>%
    summarise(n = n(), 
              !!str_c("mean_", var) := mean(.data[[var]]))
}

mtcars %>%
  group_by(cyl) %>%
  var_summary("mpg")

grouped_mean = function(data, summary_var, group_var) {
  summary_var = enquo(summary_var)
  group_var = enquo(group_var)
  data %>%
    group_by(!!group_var) %>%
    summarise(mean = mean(!!summary_var))
}
grouped_mean(mtcars, mpg, cyl)

grouped_mean = function(data, summary_var, group_var) {
  summary_var = enquo(summary_var)
  group_var = enquo(group_var)
  summary_nm = str_c("mean_", as_label(summary_var))
  group_nm = str_c("group_", as_label(group_var))
  data %>%
    group_by(!!group_nm := !!group_var) %>%
    summarise(!!summary_nm := mean(!!summary_var))
}
grouped_mean(mtcars, mpg, cyl)

grouped_mean = function(.data, .summary_var, ...) {
  summary_var = enquo(.summary_var)
  .data %>%
    group_by(...) %>%  
    summarise(mean = mean(!!summary_var))
}
grouped_mean(mtcars, disp, cyl, am)

grouped_mean = function(.data, .summary_var, ...) {
  summary_var = enquo(.summary_var)
  group_vars = enquos(..., .named = TRUE)
  summary_nm = str_c("avg_", as_label(summary_var))
  names(group_vars) = str_c("groups_", names(group_vars))
  .data %>%
    group_by(!!!group_vars) %>%  
    summarise(!!summary_nm := mean(!!summary_var))
}
grouped_mean(mtcars, disp, cyl, am)

filter_fun = function(df, ...) {
  filter(df, ...) 
}
mtcars %>% 
  filter_fun(mpg > 25 & disp > 90)

scatter_plot = function(df, x_var,y_var) {
  x_var = enquo(x_var)
  y_var = enquo(y_var)
  ggplot(data = df, aes(x = !!x_var, y = !!y_var)) +
    geom_point() + 
    theme_bw() +
    theme(plot.title = element_text(lineheight = 1, face = "bold", 
                                    hjust = 0.5)) +
    geom_smooth() +
    ggtitle(str_c(as_label(y_var), " vs. ", as_label(x_var)))
}
scatter_plot(mtcars, disp, hp)

## 2.7 data.table
library(data.table)
dt = data.table(
  x = 1:2,
  y = c("A", "B"))
dt

setkey(dt, v1, v3)         # 设置键
setindex(dt, v1, v3)       # 设置索引

## 数据读写
fread("DT.csv")
fread("DT.txt", sep = "\t")
# 选择部分行列读取
fread("DT.csv", select = c("V1", "V4"))   
fread("DT.csv", drop = "V4", nrows = 100)
# 读取压缩文件
fread(cmd = "unzip -cq myfile.zip")       
fread("myfile.gz")
# 批量读取
c("DT.csv", "DT.csv") %>% 
  lapply(fread) %>% 
  rbindlist()              # 多个数据框/列表按行合并

fwrite(DT, "DT.csv")
fwrite(DT, "DT.csv", append = TRUE)            # 追加内容
fwrite(DT, "DT.txt", sep = "\t")
fwrite(setDT(list(0, list(1:5))), "DT2.csv")   # 支持写出列表列
fwrite(DT, "myfile.csv.gz", compress = "gzip") # 写出到压缩文件

## 数据连接
# 左连接
y[x, on = "v1"]                      # 注意是以x为左表
y[x]                                 # 若v1是键
merge(x, y, all.x = TRUE, by = "v1")

merge(x, y, all.y = TRUE, by = "v1")  # 右连接
merge(x, y, by = "v1")                # 内连接
merge(x, y, all = TRUE, by = "v1")    # 全连接
x[y$v1, on = "v1", nomatch = 0]       # 半连接
x[!y, on = "v1"]                      # 反连接

# 集合运算
fintersect(x, y)
fsetdiff(x, y)
funion(x, y)
fsetequal(x, y)

## 数据重塑
# 宽变长
DT = fread("data/分省年度GDP.csv", encoding = "UTF-8")
DT %>%
  melt(measure = 2:4, variable = "年份", value = "GDP")

DT %>%
  pivot_longer(-地区, names_to = "年份", values_to = "GDP")

# 长变宽
load("data/family.rda")
DT = as.data.table(family)         # family数据
DT %>%                      
  melt(measure = patterns("^dob", "^gender"), 
       value = c("dob", "gender"), na.rm = TRUE)

load("data/animals.rda")           
DT = as.data.table(animals)        # 农场动物数据
DT %>%                        
  dcast(Year ~ Type, value = "Heads", fill = 0)

DT %>% 
  pivot_wider(names_from = Type, values_from = Heads, values_fill = 0)

us_rent_income %>% 
  as.data.table() %>% 
  dcast(GEOID + NAME ~ variable, value = c("estimate", "moe"))

# 拆分列
DT = as.data.table(table3)
# 将case列拆分为两列, 并删除原列
DT[, c("cases", "population") := tstrsplit(DT$rate, split = "/")][, 
                                                    rate := NULL]
# 合并列
DT = as.data.table(table5)
# 将century和year列合并为新列new, 并删除原列
DT[, new := paste0(century, year)][, c("century", "year") := NULL]

## 数据操作
# 筛选行
dt[3:4,]                     # 或dt[3:4]
dt[!3:7,]                    # 反选, 或dt[-(3:7)]
dt[v2 > 5]
dt[v4 %chin% c("A","C")]     # 比 %in% 更快
dt[v1==1 & v4=="A"]
unique(dt)
unique(dt, by = c("v1","v4"))               # 返回所有列
na.omit(dt, cols = 1:4)
dt[sample(.N, 3)]                            # 随机抽取3行         
dt[sample(.N, .N * 0.5)]                     # 随机抽取50% 的行
dt[frankv(-v1, ties.method = "dense") < 2]   # v1值最大的行
dt[v4 %like% "^B"]                           # v4值以B开头
dt[v2 %between% c(3,5)]                      # 闭区间
dt[between(v2, 3, 5, incbounds = FALSE)]     # 开区间
dt[v2 %inrange% list(-1:1, 1:3)]             # v2值属于多个区间的某个
dt[inrange(v2, -1:1, 1:3, incbounds = TRUE)] # 同上
# 行排序
dt[order(v1)]                               # 默认按v1从小到大
dt[order(-v1)]                              # 按v1从大到小
dt[order(v1, -v2)]                          # 按v1从小到大, v2从大到小 
setorder(DT, V1, -V2)

# 操作列
# 根据索引
dt[[3]]                              # 或dt[["v3"]], dt$v3, 返回向量
dt[, 3]                              # 或dt[, "v3"], 返回data.table
# 根据列名
dt[, .(v3)]                          # 或dt[, list(v3)] 
dt[, .(v2,v3,v4)] 
dt[, v2:v4]
dt[, !c("v2","v3")]                  # 反选列
cols = c("v2", "v3")
dt[, ..cols]
dt[, !..cols]
cols = paste0("v", 1:3)              # v1, v2, ...
cols = union("v4", names(dt))        # v4列提到第1列
cols = grep("v", names(dt))          # 列名中包含"v"
cols = grep("^(a)", names(dt))       # 列名以"a"开头
cols = grep("b$", names(dt))         # 列名以"b"结尾
cols = grep(".2", names(dt))         # 正则匹配".2"的列
cols = grep("v1|X", names(dt))       # v1或x
dt[, ..cols]

# 调整列序
cols = rev(names(DT))               # 或其他列序
setcolorder(DT, cols)
# 修改列名
setnames(DT, old, new)
DT[, setattr(sex, "levels", c("M", "F"))]
dt[, v1 := v1 ^ 2][]                    # 修改列, 加[]输出结果
dt[, v2 := log(v1)]                     # 增加新列
dt[, .(v2 = log(v1), v3 = v2 + 1)]      # 只保留新列
dt[, c("v2", "v3") := .(temp <- log(v1), v3 = temp + 1)]

# 增加多列
dt[, c("v6","v7") := .(sqrt(v1), "x")]  # 或者
dt[, ':='(v6 = sqrt(v1),
          v7 = "x")]                    # v7列的值全为x
# 同时修改多列
# 使用不带NA的考试成绩数据
DT = readxl::read_xlsx("data/ExamDatas.xlsx") %>% 
  as.data.table()
# 把函数应用到所有列
DT[, lapply(.SD, as.character)]
# 把函数应用到满足条件的列
DT[, lapply(.SD, rescale),      # rescale()为自定义的归一化函数
   .SDcols = is.numeric]  
# 把函数应用到指定列
DT =  as.data.table(iris)  
DT[, .SD * 10, .SDcols = patterns("(Length)|(Width)")]

# 删除列
dt[, v1 := NULL]
dt[, c("v2","v3") := NULL]
cols = c("v2","v3")
dt[, (cols) := NULL]    # 注意, 不是dt[, cols := NULL]

# 重新编码
# 一分支
dt[v1 < 4, v1 := 0] 
# 二分支
dt[, v1 := fifelse(v1 < 0, -v1, v1)]
# 多分支
dt[, v2 := fcase(v2 < 4, "low",
                 v2 < 7, "middle",
                 default = "high")]

# 前移/后移运算
shift(x, n = 1, fill = NA, type = "lag")     # 1,2,3 -> NA,1,2
shift(x, n = 1, fill = NA, type = "lead")    # 1,2,3 -> 2,3,NA

# 分组操作
# 使用带NA值的考试成绩数据
DT = readxl::read_xlsx("data/ExamDatas_NAs.xlsx") %>% 
  as.data.table()

# 分组修改
DT[, ':='(math.avg = mean(math,  na.rm = TRUE),
          math_med = median(math)), 
   by = sex]

# 分组汇总
DT[, .(math_avg = mean(math, na.rm = TRUE))]
DT[, .(n = .N, 
       math_avg = mean(math,  na.rm = TRUE),
       math_med = median(math)), 
   by = sex]

date = as.IDate("2021-01-01") + 1:50         
DT = data.table(date, a = 1:50)
DT[, mean(a), by = list(mon = month(date))]   # 按月平均

# 对某些列汇总
DT[, lapply(.SD, mean), .SDcols = patterns("h"), 
   by = .(class, sex)]             # 或用by = c("class", "sex")

# 对所有列做汇总
DT[, name := NULL][, lapply(.SD, mean, na.rm = TRUE), 
                   by = .(class, sex)]   

# 对满足条件的列做汇总
DT[, lapply(.SD, mean, na.rm = TRUE), by = class, 
   .SDcols = is.numeric]

# 分组计数
DT = na.omit(DT)
DT[, .N, by = .(class, cut(math, c(0, 60, 100)))] %>% 
  print(topn = 2)

DT[, Bin := cut(math, c(0, 60, 100))]
DT[CJ(class = class, Bin = Bin, unique = TRUE), 
   on = c("class","Bin"), .N, by = .EACHI]

DT[, first(.SD), by = class]
DT[, .SD[3], by = class]            # 每组第3个观测
DT[, tail(.SD, 2), by = class]      # 每组后2个观测
# 选择每个班男生数学最高分的观测
DT[sex == "男", .SD[math == max(math)], by = class] 
