### ch1 基础语法

## 1.1 常用操作
install.packages("openxlsx")

# 需要能打开GitHub
# devtools::install_github("tidyverse/dplyr")  # 或者
# remotes::install_github("tidyverse/dplyr")

# 需要当前路径下有dplyr-master
# install.packages("dplyr-master", repos=NULL, type="source")

# BiocManager::install("openxlsx")

library(openxlsx)

update.packages("openxlsx")
update.packages()                # 更新所有包
remove.packages("openxlsx")

getwd()
setwd("D:/R-4.2.2/tests")


x <- 1:10
x + 2

0L == 0
identical(0L, 0)
sqrt(2)^2 == 2
identical(sqrt(2)^2, 2)
all.equal(sqrt(2)^2, 2)
dplyr::near(sqrt(2)^2, 2)

# 需要当前路径下有data文件夹
save(x, file = "data/dat.Rda")
load("data/dat.Rda")

rm(x)                       # 清除变量x
rm(list = ls(all = TRUE))   # 清除所有当前变量

?plot

RSiteSearch("network")

## 1.2 向量,矩阵,多维数组
## 向量
x = 1.5
x

numeric(10)

c(1, 2, 3, 4, 5)
c(1, 2, c(3, 4, 5))     # 将多个数值向量合并成一个数值向量

1:5                     # 同seq(5)或seq(1,5)
seq(1, 10, 2)           # 从1开始, 到10结束, 步长为2
seq(3, length.out=10)

x = 1:3
rep(x, 2)
rep(x, each = 2)
rep(x, c(2, 1, 2))              # 按照规则重复序列中的各元素
rep(x, each = 2, length.out = 4)
rep(x, times = 3, each = 2)

2:3 + 1:5

c(1, 2) > c(2, 1)         # 等价于c(1 > 2, 2 > 1)
c(2, 3) > c(1, 2, -1, 3)  # 等价于c(2 > 1, 3 > 2, 2 > -1, 3 > 3)
c(1, 4) %in% c(1, 2, 3)   # 左边向量每一个元素是否属于右边集合

"hello, world!"
c("Hello", "World")
c("Hello", "World") == "Hello, World"

'Is "You" a Chinese name?'
writeLines("Is \"You\" a Chinese name?")

v1 = c(1, 2, 3, 4)
v1[2]                # 第2个元素
v1[2:4]              # 第2-4个元素
v1[-3]               # 除了第3个之外的元素

v1[c(1,3)]
# v1[c(1, 2, -3)]     # 报错
v1[3:6]

v1[c(TRUE, FALSE, TRUE, FALSE)]
v1[v1 <= 2]       # 同v1[which(v1 <= 2)]或subset(v1, v1<=2)
v1[v1 ^ 2 - v1 >= 2]
which.max(v1)     # 返回向量v1中最大值所在的位置
which.min(v1)     # 返回向量v1中最小值所在的位置

v1[2] = 0
v1[2:4] = c(0, 1, 3)
v1[c(TRUE, FALSE, TRUE, FALSE)] = c(3, 2)
v1[v1 <= 2] = 0
v1[10] = 8
v1

x = c(a = 1, b = 2, c = 3)
x
x[c("a", "c")]
x[c("a", "a", "c")]    # 重复访问也是可以的
x["d"]                 # 访问不存在的名字
names(x)      
names(x) = c("x", "y", "z")
x["z"]
names(x) = NULL
x

x = c(a = 1, b = 2, c = 3)
x["a"]          # 取出标签为"a"的糖果盒
x[["a"]]        # 取出标签为"a"的糖果盒里的糖果

# x[[c(1, 2)]]  # 报错
# x[[-1]]       # 报错
# x[["d"]]      # 报错

x = c(1,5,8,2,9,7,4)
sort(x)
order(x)     # 默认升序，排名第2的元素在原向量的在4个位置
x[order(x)]  # 同sort(x)
rank(x)      # 默认升序，第2个元素排名第4位

## 矩阵
matrix(c(1, 2, 3, 
         4, 5, 6, 
         7, 8, 9), nrow = 3, byrow = FALSE)
matrix(c(1, 2, 3, 
         4, 5, 6, 
         7, 8, 9), nrow = 3, byrow = TRUE)


matrix(1:9, nrow = 3, byrow = TRUE, 
       dimnames = list(c("r1","r2","r3"), c("c1","c2","c3"))) 
m1 = matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), ncol = 3)
rownames(m1) = c("r1", "r2", "r3")
colnames(m1) = c("c1", "c2", "c3")
diag(1:4, nrow = 4)      # 对角矩阵

m1[1,2]              # 提取第1行，第2列的单个元素
m1[1:2, 2:4]         # 提取第1至2行，第2至4列的元素
m1[c("r1","r3"), c("c1","c3")]  # 提取行名为r1和r3，列名为c1和c3的元素
m1[1,]               # 提取第1行，所有列元素
m1[,2:4]             # 提取所有行，第2至4列的元素
m1[-1,]              # 提取除了第1行之外的所有元素
m1[,-c(2,4)]         # 提取除了第2和4列之外的所有元素
m1[3:7]
m1 > 3
m1[m1 > 3]           # 注意选出来的结果是向量

## 多维数组
a1 = array(1:24, dim = c(3, 4, 2))
a1
a1 = array(1:24, dim = c(3, 4, 2), 
           dimnames=list(c("r1","r2","r3"), 
                         c("c1","c2","c3","c4"), c("k1","k2")))
a1 = array(1:24, dim = c(3, 4, 2))
dimnames(a1) = list(c("r1","r2","r3"), 
                    c("c1","c2","c3","c4"), c("k1","k2"))

a1[2,4,2]           # 提取第2行,第4列,第2页的元素
a1["r2","c4","k2"]  # 提取第r2行,第c4列,第k2页的元素
a1[1,2:4,1:2]       # 提取第1行,第2至4列,第1至2页的元素
a1[,,2]             # 提取第2页的所有元素
dim(a1)             # 返回多维数组a1的各维度的维数

## 1.3 列表,数据框,因子
## 列表
l0 = list(1, c(TRUE, FALSE), c("a", "b", "c"))
l0

l1 = list(A = 1, B = c(TRUE, FALSE), C = c("a", "b", "c"))
l1
names(l1) = NULL      # 移除列表成分的名字
names(l1) = c("x","y","z")

l1$y
l1$m                 # 访问不存在的成分m, 将会返回NULL
l1[[2]]              # 同l1[["y"]]
p = "y"              # 想要提取其内容的成分名字
l1["x"]                    # 同l1[1]
l1[c("x", "z")]            # 同l1[c(1, 3)], l1[c(TRUE, FALSE, TRUE)]
l1$x = 0   # 将列表的成分x赋值为0
l1[c("x", "y")] = list(x = "new value for y", y = c(3, 1))
l1[c("z", "m")] = NULL

l2 = as.list(c(a = 1, b = 2))
l2
unlist(l2)

## 数据框
library(tidyverse)        # 或tibble
persons = tibble(
  Name = c("Ken", "Ashley", "Jennifer"),
  Gender = c("Male", "Female", "Female"),
  Age = c(24, 25, 23),
  Major = c("Finance", "Statistics", "Computer Science"))
persons

tribble(
  ~Name, ~Gender, ~Age, ~Major,
  "Ken", "Male", 24, "Finance",
  "Ashley", "Female", 25, "Statistics",
  "Jennifer", "Female", 23, "Computer Science")

a = list(A = c(1, 3, 4), B = letters[1:4])
a
# lengths()获取list中每个元的长度
map_dfc(a, `length<-`, max(lengths(a)))   # map循环参阅1.6.2节

df = tibble(id = 1:4, 
            level = c(0, 2, 1, -1), 
            score = c(0.5, 0.2, 0.1, 0.5))
names(df) = c("id", "x", "y")
df

df$x                  # 同df[["x"]], df[[2]]
df[1]                 # 提取第1列, 同df["id"]
df[1:2]               # 同df[c("id","x")], df[c(TRUE,TRUE,FALSE)]
df[, "x"]
df[, c("x","y")]   # 同df[,2:3]
df[c(1,3),]
df[1:3, c("id","y")]
df[df$y >= 0.5, c("id","y")]
ind = names(df) %in% c("x","y","w")
df[1:2, ind]

df$y = c(0.6,0.3,0.2,0.4)   # 同df[["y"]] = c(0.6,0.3,0.2,0.4)
df$z = df$x + df$y 
df
df$z = as.character(df$z)   # 转换列的类型
df
df["y"] = c(0.8,0.5,0.2,0.4)
df[c("x", "y")] = list(c(1,2,1,0), c(0.1,0.2,0.3,0.4))
df[1:3,"y"] = c(-1,0,1)
df[1:2,c("x","y")] = list(c(0,0), c(0.9,1.0))

str(persons)
summary(persons)

rbind(persons, 
      tibble(Name = "John", Gender = "Male", 
             Age = 25, Major = "Statistics"))
cbind(persons, Registered = c(TRUE, TRUE, FALSE), 
      Projects = c(3, 2, 3))
expand.grid(type = c("A","B"), class = c("M","L","XL"))

## 因子
x = c("优", "中", "良", "优", "良", "良")     # 字符向量
x
sort(x)                                       # 排序是按字母顺序
x1 = factor(x, levels = c("中", "良", "优"))  # 转化因子型
x1
as.numeric(x1)                                # x的存储形式: 整数向量

sort(x1)
table(x1)
ggplot(tibble(x1), aes(x1)) +
  geom_bar()

levels(x1) = c("Fair", "Good", "Excellent")    # 修改因子水平
x1

x2 = factor(x, levels = c("中", "良", "优"), ordered = TRUE)
x2

table(x)

Age = c(23,15,36,47,65,53)
cut(Age, breaks = c(0,18,45,100), 
    labels = c("Young","Middle","Old"))

tibble(
  Sex = gl(2, 3, length = 12, labels = c("男","女")),
  Class = gl(3, 2, length = 12, labels = c("甲","乙","丙")),
  Score = gl(4, 3, length = 12, labels = c("优","良","中", "及格")))

count(mpg, class)
mpg1 = mpg %>% 
  mutate(class = fct_lump(class, n = 5)) 
count(mpg1, class)

p1 = ggplot(mpg, aes(class)) +
  geom_bar() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
p2 = ggplot(mpg, aes(fct_infreq(class))) +
  geom_bar() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))

library(patchwork)
p1 | p2

## 1.4 字符串,日期时间
## 字符串
library(stringr)

str_length(c("a", "R for data science", NA))
str_pad(c("a", "ab", "abc"), 3)       # 填充到长度为3
str_trunc("R for data science", 10)   # 截断到长度为10
str_trim(c("a  ", "b  ", "a b"))      # 移除空格

str_c("x", 1:3, sep = "")  # 同paste0("x", 1:3), paste("x", 1:3, sep="")   
str_c("x", 1:3, collapse = "_")
str_c("x", str_c(sprintf("%03d", 1:3)))

str_dup(c("A","B"), 3)
str_dup(c("A","B"), c(3,2))

x = "10,8,7"
str_split(x, ",")
str_split_fixed(x, ",", n = 2)

str_glue("Pi = {pi}")
name = " 李明"
tele = "13912345678"
str_glue("姓名: {name}", "电话号码: {tele}", .sep="；")
df = mtcars[1:3,]
str_glue_data(df, "{rownames(df)} 总功率为 {hp} kW.")

x = c("banana", "apple", "pear")
str_sort(x)     
str_order(x)
str_sort(c("香蕉", "苹果", "梨"), locale = "ch")

x
str_detect(x, "p")
str_which(x, "p")
str_count(x, "p")
str_locate(x, "a.")   # 正则表达式, .匹配任一字符

str_sub(x, 1, 3)  
str_sub(x, 1, 5)     # 若长度不够, 则尽可能多地提取
str_sub(x, -3, -1)

str_subset(x, "p")

x = c("1978-2000", "2011-2020-2099")
pat = "\\d{4}"          # 正则表达式, 匹配4位数字
str_extract(x, pat)  
str_match(x, pat)

x
str_replace(x, "-", "/")
str_to_lower("I love r language.")
str_to_upper("I love r language.")
str_to_title("I love r language.")

## 日期时间
library(lubridate)

today()
now()
as_datetime(today())   # 日期型转日期时间型
as_date(now())         # 日期时间型转日期型
ymd("2020/03~01")
myd("03202001")
dmy("03012020")
ymd_hm("2020/03~011213")
make_date(2020, 8, 27)
make_datetime(2020, 8, 27, 21, 27, 15)

d = make_date(2020, 3, 5)
format(d, '%Y/%m/%d')

t = make_datetime(2020, 3, 5, 21, 7, 15)
fmt = stamp("Created on Sunday, Jan 1, 1999 3:34 pm")
fmt(t)

t = ymd_hms("2020/08/27 21:30:27")
t
year(t)
quarter(t)            # 第几季度
month(t)
day(t)
yday(t)               # 当年的第几天
hour(t)
minute(t)
second(t)
weekdays(t)
wday(t)               # 数值表示本周的第几天, 默认周日是第1天
wday(t,label = TRUE)  # 字符因子型表示本周第几天
week(t)               # 当年的第几周
tz(t)                 # 时区
with_tz(t, tz = "America/New_York")
force_tz(t, tz = "America/New_York")
round_date(t, unit="hour")      # 四舍五入取整到小时

begin = ymd_hm("2019-08-10 14:00")
end = ymd_hm("2020-03-05 18:15")
gap = interval(begin, end)  # 同begin %--% end
gap

time_length(gap, "day")     # 计算时间段的长度为多少天
time_length(gap, "minute")  # 计算时间段的长度为多少分钟
t %within% gap              # 判断t是否属于该时间段

duration(100, units = "day")
int = as.duration(gap)
int

dyears(1)
years(1)
t + int    
leap_year(2020)             # 判断是否闰年
ymd(20190305) + years(1)    # 加period的一年
ymd(20190305) + dyears(1)   # 加duration的一年, 365天
t + weeks(1:3)
gap / ddays(1)             # 除法运算, 同time_length(gap,'day')
gap %/% ddays(1)           # 整除
gap %% ddays(1)            #余数
as.period(gap %% ddays(1))
date = as_date("2019-01-01")
date %m+% months(0:11)

x = seq.Date(as_date("2019-08-02"), by = "year", length.out = 2)
pretty_dates(x, 12)

## 时间序列
ts(data = 1:10, start = 2010, end = 2019)     # 年度数据
ts(data = 1:10, start = 2010, frequency = 4)  # 季度数据

load("data/stocks.rda")
stocks

library(fpp3)
stocks = as_tsibble(stocks, key = Stock, index = Date)
stocks

stocks %>%
  group_by_key() %>% 
  index_by(weeks = ~ yearweek(.)) %>%    # 周度汇总
  summarise(max_week = mean(Close))

autoplot(stocks)                         # 可视化

## 1.5 正则表达式
x = c("CDK弱(+)10%+", "CDK(+)30%-", "CDK(-)0+", "CDK(++)60%*")
str_view(x, "\\d+%")
str_view(x, "\\d+%?")

x = c("175.10.237.40(湖南-长沙)", "114.243.12.168(北京-北京)", 
      "125.211.78.251(黑龙江-哈尔滨)")
# 提取省份
str_extract(x, "\\(.*-")           # 此处作为对比，不用零宽断言
str_extract(x, "(?<=\\().*(?=-)")  # 用零宽断言

# 提取IP
# str_extract(x, "\\d.*\\d")       # 直接匹配
str_extract(x, "^.*(?=\\()")       # 用零宽断言

x = c("18级能源动力工程2班", "19级统计学1班")
str_extract(x, "(?<=级).*?(?=[0-9])")
 
x = c("I am a teacher", "She is a beautiful girl")
str_extract(x, "(?<= )[^ ]+$")

x = "D:/paper/1.65_kc_ndvi/kc/forest_kc_historical_ACCESS-ESM1-5_west_1981_2014.tif"
str_extract(x, "(?<=kc/)([^_]+_){2}[^_]+")

str_extract("(1st) other (2nd)", "\\(.+\\)")
str_extract("(1st) other (2nd)", "\\(.+?\\)")

x = c("宝马X3 2016款", "大众 速腾2017款", "宝马3系2012款")
str_replace(x, "([a-zA-Z0-9])", " \\1")

x = c("194631", "174223")            # 数值型也可以
x = str_replace_all(x, "(\\d{2})", "\\1:")
x
hms(x)

x = c("独行月球2022_Chinese","蜘蛛侠USA_2021","人生大事2022_Chinese")
str_replace(x, "(\\d+)_(.+)","\\2_\\1")

## 1.6 控制结构
## 分支
if(x < 0) {
  y = -x
} else {
  y = x
}

ifelse(x < 0, -x, x)

x = "b"
v = switch(x, "a"="apple", "b"="banana", "c"="cherry")
v

if(score >= 90) {
  res = "优"
} else if(score >= 80) {
  res = "良" 
} else if(score >= 70) {
  res = "中"
} else if(score >= 60) {
  res = "及格"
} else {
  res = "不及格"
}

## 循环
library(tidyverse)

df = as_tibble(iris[,1:4])
mean(df[[1]])
mean(df[[2]])
mean(df[[3]])
mean(df[[4]])

output = vector("double", 4)             # 1.输出
for (i in 1:4) {                         # 2.迭代器
  output[i] = mean(df[[i]])              # 3.循环体
}
output

output = list()       # output = NULL也行
# output = vector("list", 3)
for(i in 1:3) {
  output[[i]] = c(i, i^2)
}

set.seed(123)    # 设置随机种子, 让结果可重现
while(TRUE) {
  x = rnorm(1)
  print(x)
  if(x > 1) break
}

s = 1.0
x = 1
k = 0

repeat{
  k = k + 1
  x = x / k
  s = s + x
  if(x < 1e-10) break
}

str_glue("迭代 {k} 次, 得到e = {s}")

x = matrix(1:6, ncol = 3)
x

apply(x, 1, mean)          # 按行求均值
apply(x, 2, mean)          # 按列求均值
apply(df, 2, mean)         # 对前文df计算各列的均值

height = c(165, 170, 168, 172, 159)
sex = factor(c("男", "女", "男", "男", "女"))
tapply(height, sex, mean)

lapply(df, mean)      # 对前文df计算各列的均值
sapply(df, mean)      # 对前文df计算各列的均值

## map循环迭代
map(df, mean)
map_dbl(df, mean)
map_dbl(df, mean, na.rm = TRUE)       # 数据不含NA, 故结果同上
map_dbl(df, ~mean(.x, na.rm = TRUE))  # purrr风格公式写法

height = c(1.58, 1.76, 1.64)
weight = c(52, 73, 68)

cal_BMI = function(h, w) w / h ^ 2     # 定义计算BMI的函数
map2_dbl(height, weight, cal_BMI)

df = tibble(
  n = c(1, 3, 5),
  mean = c(5, 10, -3),
  sd = c(1, 5, 10))
df
set.seed(123)
pmap(df, rnorm)

pmap(df, ~ rnorm(..1, ..2, ..3))    # 或者简写为
pmap(df, ~ rnorm(...))
pmap_dbl(df, ~ mean(c(...)))        # 按行求均值
pmap_chr(df, str_c, sep = "-")      # 将各行拼接在一起 

## 1.7 自定义函数
score = 76
if(score >= 90) {
  res = "优"
} else if(score >= 80) {
  res = "良" 
} else if(score >= 70) {
  res = "中"
} else if(score >= 60) {
  res = "及格"
} else {
  res = "不及格"
}
res

Score_Conv = function(score) {
  if(score >= 90) {
    res = "优"
  } else if(score >= 80) {
    res = "良" 
  } else if(score >= 70) {
    res = "中"
  } else if(score >= 60) {
    res = "及格"
  } else {
    res = "不及格"
  }
  res
}

Score_Conv(76)

Score_Conv2 = function(score) {
  n = length(score)
  res = vector("character", n)
  for(i in 1:n) {
    if(score[i] >= 90) {
      res[i] = "优"
    } else if(score[i] >= 80) {
      res[i] = "良" 
    } else if(score[i] >= 70) {
      res[i] = "中"
    } else if(score[i] >= 60) {
      res[i] = "及格"
    } else {
      res[i] = "不及格"
    }
  }
  res
}

# 测试函数
scores = c(35, 67, 100)
Score_Conv2(scores)

scores = c(35, 67, 100)
map_chr(scores, Score_Conv)         

MeanStd = function(x) {
  mu = mean(x)
  std  = sqrt(sum((x-mu)^2) / (length(x)-1))
  list(mu=mu, std=std)
}
# 测试函数
x = c(2, 6, 4, 9, 12)
MeanStd(x)

MeanStd2 = function(x, type = 1) {
  mu = mean(x)
  n = length(x)
  if(type == 1) {
    std  = sqrt(sum((x - mu) ^ 2) / (n - 1))
  } else {
    std  = sqrt(sum((x - mu) ^ 2) / n)
  }  
  list(mu = mu, std = std)
}
# 测试函数
x = c(2, 6, 4, 9, 12)
# MeanStd2(x)                  # 同MeanStd(x)
MeanStd2(x, 2)

MeanStd3 = function(x, type = "sample") {
  mu = mean(x)
  n = length(x)
  switch(type,
         "sample" = {
           std = sqrt(sum((x - mu) ^ 2) / (n - 1))
         },
         "population" = {
           std = sqrt(sum((x - mu) ^ 2) / n)
         })
  list(mu = mu, std = std)
}
MeanStd3(x)
MeanStd3(x, "population")

my_sum = function(x, y) {
  sum(x, y)
}
my_sum(1, 2)

dots_sum = function(...) {
  sum(...)
}
dots_sum(1)
dots_sum(1, 2, 3, 4, 5)

## 自带函数
combn(4, 2)
combn(c("甲","乙","丙","丁"), 2)

dnorm(3, 0, 2)                   # 正态分布N(0, 4) 在3处的密度值
pnorm(1:3, 1, 2)                 # N(1,4)分布在1,2,3处的分布函数值

# 命中率为0.02, 独立射击400次, 至少击中两次的概率
1 - sum(dbinom(0:1, 400, 0.02)) 

pnorm(2, 1, 2) - pnorm(0, 1, 2)  # X~N(1, 4), 求P{0<X<=2}
qnorm(1-0.025,0,1)               # N(0,1)的上0.975分位数

set.seed(123)        # 设置随机种子, 以重现随机结果
rnorm(5, 0, 1)       # 生成5个服从N(0,1)分布的随机数

set.seed(2020)
sample(c("正","反"), 10, replace=TRUE)  # 模拟抛10次硬币
sample(1:10, 10, replace=FALSE)         # 随机生成1~10的某排列

rescale = function(x, type=1) {
  # type=1正向指标, type=2负向指标
  rng = range(x, na.rm = TRUE)
  if (type == 1) {
    (x - rng[1]) / (rng[2] - rng[1])
  } else {
    (rng[2] - x) / (rng[2] - rng[1])
  }
}

x = c(1, 2, 3, NA, 5)
rescale(x)
rescale(x, 2)

x = ts(1:8, frequency = 4, start = 2015)
x
stats::lag(x, 4)       # 避免被dplyr::lag()覆盖

x = c(1, 3, 6, 8, 10)
x
diff(x, differences = 1)
diff(x, differences = 2)
diff(x, lag = 2, differences = 1)

