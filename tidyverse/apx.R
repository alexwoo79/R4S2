### 附录

## A R6类
library(R6)
BankAccount = R6Class(
  classname = "BankAccount",
  public = list(
    name = NULL,
    age = NA,
    initialize = function(name, age, balance) {
      self$name = name
      self$age = age
      private$balance = balance
    },
    printInfo = function() {
      cat("姓名：", self$name, "\n", sep = "")
      cat("年龄：", self$age, "岁\n", sep = "")
      cat("存款：", private$balance, "元\n", sep = "")
      invisible(self)
    },
    deposit = function(dep = 0) {
      private$balance = private$balance + dep
      invisible(self)
    },
    withdraw = function(draw) {
      private$balance = private$balance - draw
      invisible(self)
    }),
  private = list(balance = 0)
)

account = BankAccount$new("张三", age = 40, balance = 10000)
account$printInfo()
account$balance
account$age
account$
  deposit(5000)$
  withdraw(7000)$
  printInfo()

BanckAcountCharge = R6Class(
  classname = "BankAccount",
  inherit = BankAccount,
  public = list(
    withdraw = function(draw = 0) {
      if (private$balance - draw < 0) {
        draw = draw + 100
      }
      super$withdraw(draw = draw)
    }))

charge_account = BanckAcountCharge$new("李四", age = 35, balance = 1000)
charge_account$withdraw(2000)$
  printInfo()

## B 错误与调试
## 错误调试技术
# traceback()调试
f1 = function(x) x - f2(x)
f2 = function(y) y * f3(y)
f3 = function(z) {
  r = sqrt(z)
  if(r < 10) r ^ 2
  else r ^3
}
f1(-10)

traceback()

options(error = rlang::entrace)
f1(-10)
rlang::last_error()     # 或直接点击该语句
rlang::last_trace()     # 或直接点击该语句

# browser()调试
f1 = function(x) x - f2(x)
f2 = function(y) y * f3(y)
f3 = function(z) {
  r = sqrt(z)
  browser()             # 插入browser()
  if(r < 10) r ^ 2
  else r ^3
}
f1(-10)

# debug()调试
debug(f3)
f1(-10)

## 异常处理
div = function(m, n) {
  if (!is.numeric(m) | !is.numeric(n)) {
    stop("错误：分子或分母不是数值！")
  }
  else if (n == 0) {
    warning("警告：分母是0！")
    Inf
  }
  else {
    m / n
  }
}

div(3, 2)
div("3", 2)
div(3, 0)

tryCatch(div(3, 2),
         error = function(err) err,
         warning = function(warn) cat(paste0(warn, "小心结果是Inf！")))
tryCatch(div("3", 2),
         error = function(err) err,
         warning = function(warn) cat(paste0(warn, "小心结果是Inf！")))
tryCatch(div(3, 0),
         error = function(err) err,
         warning = function(warn) cat(paste0(warn, "小心结果是Inf！")))

sim_value = function() {
  val = rnorm(1)
  if (val <= 0){
    rlang::abort(message = "返回值不是正数！",
                 class = "模拟值错误",
                 val = val)
  } else {
    val
  }
}

sim_value_handler = function(err) {
  msg = "无法计算值！"
  if (inherits(err, "模拟值错误")) {
    msg = paste0(msg, "`sim_value()`函数生成的数值为", err$val)
  }
  rlang::abort(msg, "模拟值错误")
}

log_value = function(){
  x = tryCatch(sim_value(), error = sim_value_handler)
  log(x)
}

set.seed(123)
log_value()

# purrr调试循环迭代
safe_log = safely(log, otherwise = NA_real_)

list("a", 10, 100) %>%
  map(safe_log) %>%
  transpose() %>%
  simplify_all()

## C Excel交互
## LOOKUP查询
library(tidyverse)
library(readxl)
df = read_xlsx("data/VLOOKUP 综合.xlsx")

df %>%
  filter(销售员 == "王东") %>%        # 筛选行
  select(销售员, 销量)                # 选择列

df %>%
  right_join(df2, by = "销售员") %>%  # 右连接
  select(销售员, 销量) # 选择列

df %>%
  filter(销售员 == "王东", 地区 == "北京") %>% # 根据两个条件筛选行
  select(销售员, 地区, 销量)

df %>%
  filter(销售员 == "王东")

df %>% # 数据思维不用分左右
  filter(销量 == 66) %>%
  select(销量, 销售员)

df %>%
  filter(str_detect(销售员, "中")) %>% # 是否检测到"中"字, 支持正则表达式
  select(销售员, 销量)

df %>%
  mutate(销量等级 = case_when( # 修改列
    销量 < 60 ~ "不及格",
    销量 < 85 ~ "及格",
    销量 < 95 ~ "良好",
    销量 < 100 ~ "优秀",
    TRUE ~ "满分"))

# 若写出, 增加一行
# %>% writexl::write_xlsx("filename.xlsx")

## 透视表
df = read_xlsx("data/数据透视表.xlsx")
library(lubridate)
pt = df %>%
  group_by(年份 = year(订购日期), 地区) %>%
  summarise(销售额 = sum(销售额))
pt

pt = pt %>%
  pivot_wider(names_from = 地区, values_from = 销售额)
pt

library(janitor)
pt %>%
  adorn_totals(where = c("row", "col")) # 也可以只用一个

library(tidyquant)
df %>%
  pivot_table(.rows = ~ YEAR(订购日期), 
              .columns = 地区, .values = ~ SUM(销售额)) %>%
  adorn_totals(where = c("row", "col")) 

library(pivottabler)
df %>%
  mutate(年份 = year(订购日期)) %>%
  qpvt(rows = "年份", columns = "地区", calculations = "sum(销售额)") 

## D 非等连接
library(data.table )
Houses = fread("data/Houses.csv")
Renters = fread("data/Renters.csv")
Deals = fread("data/Deals.csv")

Houses      # 房源信息
Renters     # 租客信息
Deals       # 已租赁信息

Renters[Renters, on = .(preferred, id < id)][,
  .(name, preferred, i.name)
] %>%
  na.omit()

Houses[! id %in% Deals$house_id][
  Renters, on = .(district == preferred, rent >= min_rent,
                  rent <= max_rent, bedrooms >= min_bedrooms)
][, -(5:6)] %>%
  na.omit()

## 滚动连接
website = fread("data/website.csv")
paypal = fread("data/paypal.csv")
# 为了便于观察, 增加分组id列
website[, session_id := .GRP, by = .(name, session_time)]
paypal[, payment_id := .GRP, by = .(name, purchase_time)]

website       # 网页会话数据
paypal        # 支付数据

# 创建用于连接的单独时间列
website[, join_time:=session_time]
paypal[, join_time:=purchase_time]
# 设置key
setkey(website, name, join_time)
setkey(paypal, name, join_time)

# 前滚连接
website[paypal, roll = TRUE] %>%
  na.omit()

# 后滚连接
paypal[website, roll = -Inf] %>%
  na.omit()

# 滚动窗口连接
twelve_hours = 60*60*20 # 转化为秒
paypal[website, roll = -twelve_hours] %>%
  na.omit()

## E 网络爬虫
## 静态网页
library(tidyverse)
suffix = str_c("?start=", seq(25,225, by = 25))
urls = str_c("https://book.douban.com/top250", c("", suffix))

library(rvest)
read_url = function(url){
  Sys.sleep(sample(5,1)) # 休眠随机1~5 秒
  read_html(url)
}
htmls = map(urls, read_url)

book = html_nodes(html, ".pl2 a") %>%
  html_text2()

get_html = function(html) {
  tibble(
    book = html_nodes(html, ".pl2 a") %>%
      html_text2(),
    info = html_nodes(html, "p.pl") %>%
      html_text2(),
    score = html_nodes(html, ".rating_nums") %>%
      html_text2() %>%
      parse_number(),
    comments = html_nodes(html, ".star .pl") %>%
      html_text2() %>%
      parse_number(),
    description = html_elements(html, "td") %>%
      html_text2() %>%
      stringi::stri_remove_empty() %>%
      str_extract("(?<=\\)\n\n).*"))
}

books_douban = map_dfr(htmls, get_html)

books_douban = books_douban %>%
  mutate(author = str_extract(info, ".*(?=/.*/ \\d{4})"),
         press = str_extract(info, "(?<=/ )[^/]*(?=/ \\d{4})"),
         Date = str_extract(info, "(?<=/ )[\\d-].*(?= /)"),
         price = str_extract(info, "(?<=/)[^/]*$") %>%
           parse_number()) %>%
  select(-info)
write_csv(books_douban, file = "豆瓣读书TOP250.csv")

## 动态网页
library(httr)
# 构造请求头
myCookie = '您的最新Cookie'
myUserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML,
like Gecko) Chrome/92.0.4515.159 Safari/537.36'
headers = c('accept' = 'application/json',
            'edu-script-token' = '38830026a471405eb9327d14d51eeda4',
            'User-Agent' = myUserAgent,
            'cookie' = myCookie)
# 二次实际请求到的url
url = "https://study.163.com/p/search/studycourse.json"
# 构造请求Payload
payload = list('pageIndex' = 1, 'pageSize' = 50, 'relativeOffset' = 0,
               'frontCategoryId' = "480000003131009")

# POST 方法执行单次请求
result = POST(url, add_headers(.headers = headers), 
              body = payload, encode = "json")

lensons = content(result)$result$list   # 50 个课程信息列表的列表

df = tibble(ID = map_chr(lensons, "courseId"),
            title = map_chr(lensons, "productName"),
            provider = map_chr(lensons, "provider"),
            score = map_dbl(lensons, "score"),
            learnerCount = map_dbl(lensons, "learnerCount"),
            lessonCount = map_dbl(lensons, "lessonCount"),
            lector = map_chr(lensons, "lectorName", .null = NA))

get_html = function(p) {
  Sys.sleep(sample(5, 1))
  payload = list('pageIndex' = p, 'pageSize' = 50, 'relativeOffset' = 50*(p-1),
                 'frontCategoryId' = "480000003131009")
  # POST 方法执行单次请求
  result = POST(url, add_headers(.headers = headers),
                body = payload, encode = "json")
  lensons = content(result)$result$list
  tibble(
    ID = map_chr(lensons, "courseId"),
    title = map_chr(lensons, "productName"),
    provider = map_chr(lensons, "provider"),
    score = map_dbl(lensons, "score"),
    learnerCount = map_dbl(lensons, "learnerCount"),
    lessonCount = map_dbl(lensons, "lessonCount"),
    lector = map_chr(lensons, "lectorName", .null = NA))
}

wy_lessons = map_dfr(1:11, get_html) %>%
  arrange(-learnerCount)
write.csv(wy_lessons, file = "网易云课堂编程开发类课程.csv")

## F 高性能计算
## 并行计算
library(future)
availableCores()     # 查看电脑可用的线程数

plan(multisession)   # 启用多线程, 参数workers可设置线程数
f <- future({
  ... # 要并行加速的代码
})
value(f)
plan(sequential)    # 回到单线程

library(furrr)
library(purrr)
# map_dbl(iris[1:4], mean)
plan(multisession, workers = 6)
future_map_dbl(iris[1:4], mean)

## 运行C++代码
library(Rcpp)
cppFunction('int add(int x, int y) {
  int sum = x + y;
  return sum;
}')
add(1, 2)

# 编写标准的C++文件, 保存为test.cpp
# #include <Rcpp.h>
# using namespace Rcpp;
# // [[Rcpp::export]]
# double meanC(NumericVector x) {
#   int n = x.size();
#   double total = 0;
#   for(int i = 0; i < n; ++i) {
#     total += x[i];
#   }
#   return total / n;
# }
# /*** R
# x <- runif(1e5)
# bench::mark( # 测速对比
#   mean(x),
#   meanC(x)
# )
# */

sourceCpp("test.cpp")    # R 中运行cpp 文件

## 超出内存的大数据
library(disk.frame)
# 启用多线程, 参数workers 可设置线程数
setup_disk.frame()
# 允许大数据集在session 之间传输
options(future.globals.maxSize = Inf)
## 从csv 文件创建disk.frame
# flights = csv_to_disk.frame(
#   infile = "data/flights.csv",
#   outdir = "temp/tmp_flights.df",
#   nchunks = 6,                     # 分为6 个数据块
#   overwrite = TRUE)
flights = as.disk.frame(nycflights13::flights)

flights %>%
  filter(month == 5, day == 17, carrier %in% c('UA', 'WN', 'AA', 'DL')) %>%
  select(carrier, dep_delay, air_time, distance) %>%
  mutate(air_time_hours = air_time / 60) %>%
  collect() %>%
  arrange(carrier) %>%    # arrange应该在collect之后
  head()

## 大型矩阵运算
library(bigstatsr)
X = FBM(10000, 1000, init = rnorm(10000 * 1000), backingfile = "temp/test")
object.size(X)
file.size(X$backingfile)
typeof(X)

sums = big_apply(X, a.FUN = function(X, ind) {
  colSums(X[,ind])
}, a.combine = "c", block.size = 500, ncores = 2)
sums[1:5]

## G 机器学习
## mlr3verse
library(mlr3verse)
# 创建分类任务
task = as_task_classif(iris, target = "Species")
# 选择学习器, 并设置两个超参数: 最大深度, 最小分支节点数
learner = lrn("classif.rpart", maxdepth = 3, minsplit = 10)
# 划分训练集/测试集
set.seed(123)
split = partition(task, ratio = 0.7)
# 训练模型
learner$train(task, row_ids = split$train)
# 模型预测
predictions = learner$predict(task, row_ids = split$test)
# 模型评估
predictions$confusion                    # 混淆矩阵
predictions$score(msr("classif.acc"))    # 准确率

## tidymodels
library(tidymodels)
# 划分训练集/测试集
set.seed(123)
split = initial_split(iris, prop = 0.7, strata = Species)
train = training(split)
test = testing(split)
# 训练模型
model = decision_tree(mode = "classification",
                      tree_depth = 3, min_n = 10) %>%
  set_engine("rpart") %>%           # 来自哪个包或方法
  fit(Species ~ ., data = train)
# 模型预测
pred = predict(model, test) %>%
  bind_cols(select(test, Species))
# 模型评估
pred %>%
  conf_mat(truth = Species, .pred_class)    # 混淆矩阵
pred %>%
  accuracy(truth = Species, .pred_class)    # 准确率


