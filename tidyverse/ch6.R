### ch6 文档沟通

## 6.1 Rmarkdown
# Rmd插入图片
# knitr::include_graphics("xxx.png")

## 表格输出
knitr::kable(mtcars[1:3,1:7], align = "lccrr", digits = 2,
             col.names = str_c("x", 1:7),
             caption = "部分iris 数据")

library(flextable) # word, ppt
iris[1:5,] %>%
  flextable() %>%
  set_caption("定制表格示例") %>%
  add_header_row(colwidths = c(2, 2, 1), values = c("Sepal", "Petal", "")) %>%
  align(align = "center", part = "all") %>%
  color(color = "red", part = "header") %>%
  bold(bold = TRUE, part = "header") %>%
  merge_v(j = 3:4) %>%
  highlight(i = ~ Sepal.Length < 5, j = 1, color = "yellow") %>%
  save_as_docx(path = "output/threelinetable.docx")

df = read_csv("data/Guerry.csv")
models = list(
  "OLS" = lm(Donations ~ Literacy + Clergy, data = df),
  "Poisson" = glm(Donations ~ Literacy + Commerce, family = poisson, data = df))
cm = c("(Intercept)" = "Constant", "Literacy" = "Literacy (%)",
       "Clergy" = "Priests/capita")
cap = "Regression Tables with moelsummary"

library(modelsummary)
library(huxtable) # pdf
modelsummary(models, output = "huxtable", coef_map = cm,
             stars = TRUE, fmt = "%.2f",
             title = cap, gof_omit = 'IC|Log|Adj') %>% # 转到huxtable
  set_text_color(row = 4, col = 1:ncol(.), value = "red") %>%
  set_background_color(row = 6, col = 1:ncol(.), value = "lightblue") %>%
  quick_pdf(file = "output/tablepdf.pdf")

library(kableExtra) # latex
modelsummary(models, output = "latex", coef_map = cm,
             stars = TRUE, fmt = "%.2f",
             title = cap, gof_omit = 'IC|Log|Adj') %>% # 转到kableExtra
  add_header_above(c(" " = 1, "Donations" = 2)) %>%
  row_spec(3, color = "red") %>%
  row_spec(5, background = "lightblue") %>%
  save_kable("output/modeltable.tex")

## 批量文档

# Rmd内容：
# title: "数据概览：`r name`"
# author: "张敬信"
# date: "`r Sys.Date()`"
# params:
#   name: "input your data name"
# output: html_document
# ---
# ## 输出数据概要
# ```{r}
# df = get(params$name)
# summary(df)
# ```

library(rmarkdown)
names = c("iris", "mtcars", "CO2")
purrr::walk(names,
            ~ render("Reproducible.Rmd", params = list(name = .x),
                     output_file = paste0(.x, "分析报告.html")))


## 6.2 R与Latex交互
library(tinytex)
tinytex:::install_prebuilt(pkg = "D:/TinyTeX.zip")
# tinytex::uninstall_tinytex()     # 卸载TinyTex

tinytex_root()                     # 查看安装路径
tl_pkgs()                          # 查看已安装宏包

# 修改清华大学镜像源
tlmgr_repo(url = "http://mirrors.tuna.tsinghua.edu.cn/CTAN/")

parse_packages("test.log")
tlmgr_install("ctex")
xelatex("test.tex")

## 6.3 R与git版本控制
## 配置git信息
library(usethis)
use_git_config(user.name = "zhjx19", user.email = "zhjx_19@163.com")

## 6.4 R Shiny

## Shiny app的结构

# library(shiny)
# # 定义UI
# ui = fluidPage(
#   ...
# )
# # 定义server 逻辑
# server = function(input, output) {
#   ...
# }
# # 运行app
# shinyApp(ui = ui, server = server)

## 展示常用控件的Shiny app
library(shiny)
# 定义UI
ui = fluidPage(
  titlePanel("常用控件"),
  fluidRow(
    column(3, h3("按钮"), #
           actionButton("action", "点击"),
           br(), br(),
           submitButton("提交")),
    column(3, h3("单选框"),
           checkboxInput("checkbox", "选项A", value = TRUE)),
    column(3,
           checkboxGroupInput("checkGroup", h3("多选框"),
                              choices = list("选项1" = 1, "选项2" = 2, "选项3" = 3),
                              selected = 1)),
    column(3, dateInput("date", h3("输入日期"), value = "2021-01-01"))),
  fluidRow(
    column(3, dateRangeInput("dates", h3("日期范围"))),
    column(3, fileInput("file", h3("文件输入"))),
    column(3, h3("帮助文本"),
           helpText("注: 帮助文本不是真正的部件, 但提供了一种",
                    "易于实现的方式为其他部件添加文本.")),
    column(3, numericInput("num", h3("输入数值"), value = 1))),
  fluidRow(
    column(3, radioButtons("radio", h3("单选按钮"),
                           choices = list("选项1" = 1, "选项2" = 2,
                                          "选项3" = 3), selected = 1)),
    column(3, selectInput("select", h3("下拉选择"),
                          choices = list("选项1" = 1, "选项2" = 2,
                                         "选项3" = 3), selected = 1)),
    column(3, sliderInput("slider1", h3("滑动条"),
                          min = 0, max = 100, value = 50),
           sliderInput("slider2", "",
                       min = 0, max = 100, value = c(25, 75))),
    column(3, textInput("text", h3("文本输入"), value = "输入文本...")))
)
# 定义server 逻辑: 空白逻辑是app 对控件的输入什么都不做, 不产生任何输出
server = function(input, output) {}
# 运行app
shinyApp(ui = ui, server = server)

## 简单问候Shiny app
library(shiny)
ui = fluidPage(
  textInput("name", "请输入您的姓名："),
  textOutput("greeting")
)
server = function(input, output, session) {
  output$greeting = renderText({
    paste0("您好 ", input$name, "！")
  })
}
shinyApp(ui = ui, server = server)

## 中心极限定理Shiny app
ui = fluidPage(
  titlePanel("演示中心极限定理"),
  sidebarLayout(position = "right", # 放到右侧
                sidebarPanel(
                  selectInput("distr", "分布：",
                              c("均匀", "二项", "泊松", "指数")),
                  sliderInput("samples", "随机变量数：", 1, 100, 10, step = 1),
                  sliderInput("nsim", "模拟样本量：", 1000, 10000, 1000, step = 100),
                  sliderInput("bins", "条形数", min = 10, max = 100, value = 50),
                  helpText("说明：从下拉选项选择分布, 并用滑动条选择
随机变量数和模拟样本量.")),
  mainPanel(plotOutput("plot")))
)

server = function(input, output) {
  Xbar = reactive({
    n = input$samples # 随机变量个数
    m = input$nsim # 模拟样本量
    xs = switch(input$distr,
                "均匀" = runif(m * n, 0, 1),
                "二项" = rbinom(m * n, 10, 0.3),
                "泊松" = rpois(m * n, 5),
                "指数" = rexp(m * n), 1)
    data.frame(x = rowMeans(matrix(xs, ncol = n)))
  })
  output$plot = renderPlot({
    ggplot(Xbar(), aes(x)) +
      geom_histogram(alpha = 0.2, bins = input$bins,
                     fill = "steelblue", color = "black")
  })
}

## 探索性数据展板Shiny app
# 载入数据
load("data/ecostats.rda")
countries = unique(ecostats$Region)
# 用户界面
ui = fluidPage(
  titlePanel("交互探索ecostats 数据"),
  sidebarLayout( # 侧边栏带下拉选项选择地区
    sidebarPanel(
      selectInput("name", "选择地区：", choices = countries,
                  selected = "黑龙江")),
    mainPanel( # 主面板带图形和数据表的切换标签
      tabsetPanel(
        tabPanel("人均GDP 图", plotly::plotlyOutput("eco_plot")),
        tabPanel("数据表", DT::dataTableOutput("eco_data"))))
  )
)

# 定义服务器逻辑: 绘制折线图、创建数据表
server = function(input, output) {
  selected = reactive({
    ecostats %>%
      filter(Region == input$name)
  })
  # 绘制折线图
  output$eco_plot = plotly::renderPlotly({
    p = ggplot(selected(), aes(Year, gdpPercap)) +
      geom_line(color = "red", size = 1.2) +
      labs(title = paste0(input$name, "人均GDP 变化趋势"),
           x = "年份", y = "人均GDP")
    plotly::ggplotly(p) # 渲染plotly 对象
  })
  # 创建数据表
  output$eco_data = DT::renderDataTable({
    DT::datatable(selected(), extensions = "Buttons",
                  caption = paste0(input$name, "数据"),
                  options = list(dom = "Bfrtip",
                                 buttons = c("copy", "csv", "excel", "pdf", "print")))
  })
}
# 运行App
shinyApp(ui = ui, server = server)

## 6.5 开发R包
# 检查Rtools是否成功安装
devtools::has_devel()     # 或者 Sys.which("make")

## 创建R包
library(devtools)
create_package(getwd())     # 从当前路径创建R 包

## 填加函数
use_r("AHP")

AHP <- function(A) {
  rlt <- eigen(A)
  Lmax <- Re(rlt$values[1]) # Maximum eigenvalue
  图6.39 R 包的源码文件
  266 6 文档沟通
  # Weight vector
  W <- Re(rlt$vectors[,1]) / sum(Re(rlt$vectors[,1]))
  # Consistency index
  n <- nrow(A)
  CI <- (Lmax - n) / (n - 1)
  # Consistency ratio
  # Saaty's random Consistency indexes
  RI <- c(0,0,0.58,0.90,1.12,1.24,1.32,1.41,1.45,1.49,1.51)
  CR <- CI / RI[n]
  list(W = W, CR = CR, Lmax = Lmax, CI = CI)
}

## 编写函数注释信息, 不要运行！

#' @title AHP: Analytic Hierarchy Process
#' @description AHP is a multi-criteria decision analysis method developed
#' by Saaty, which can also be used to
#' determine indicator weights.
#' @param A a numeric matrix, i.e. pairwise comparison matrix
#' @return a list object that contains: W (Weight vector), CR (Consistency ratio),
#' Lmax (Maximum eigenvalue), CI (Consistency index)
#' @export
#' @examples
#' A = matrix(c(1, 1/2, 4, 3, 3,
#' 2, 1, 7, 5, 5,
#' 1/4, 1/7, 1, 1/2, 1/3,
#' 1/3, 1/5, 2, 1, 1,
#' 1/3, 1/5, 3, 1, 1), byrow = TRUE, nrow = 5)
#' AHP(A)

## 编写DESCRIPTION，不要运行！

# Package: mathmodels
# Title: Implement Common Mathematical Modeling Algorithms with R
# Version: 0.0.1
# Authors@R: # 多个作者用c()合并
#   person(given = "Jingxin",
#          family = "Zhang",
#          role = c("aut", "cre", "cph"), # 作者,维护者,版权人,还有"ctb"贡献者
#          email = "zhjx_19@hrbcu.edu.cn")
# Description: Mathematical modeling algorithms are classified as evaluation,
# optimization, prediction, dynamics, graph theory, statistics,
# intelligence, etc. This package is dedicated to implementing various
# common mathematical modeling algorithms with R.
# License: AGPL (>= 3)
# URL: https://github.com/zhjx19/mathmodels
# BugReports: https://github.com/zhjx19/mathmodels/issues
# Encoding: UTF-8
# LazyData: true
# Roxygen: list(markdown = TRUE)
# RoxygenNote: 7.1.1
# Imports:
#   deSolve

if (requireNamespace("pkg", quietly = TRUE)) {
  pkg::f()
}
use_package("deSolve")    # 还有参数min_version 指定最低版本
use_package("deSolve", "Suggests")
use_agpl3_license()

## 使用数据集
use_data(penguins)   # 参数compress 可设置压缩格式
use_r("penguins")

## 编写数据集的注释信息，不要运行！

#' @title Size measurements for adult foraging penguins near Palmer Station, Antarctica
#' @description Includes measurements for penguin species, island in Palmer Archipelago,
#' size (flipper length, body mass, bill dimensions), and sex.
#' @docType data
#' @usage data(penguins)
#' @format A tibble with 344 rows and 8 variables:
#' \describe{
#' \item{species}{a factor denoting penguin species}
#' \item{island}{a factor denoting island in Palmer Archipelago, Antarctica}
#' \item{bill_length_mm}{a number denoting bill length (millimeters)}
#' \item{bill_depth_mm}{a number denoting bill depth (millimeters)}
#' \item{flipper_length_mm}{an integer denoting flipper length (millimeters)}
#' \item{body_mass_g}{an integer denoting body mass (grams)}
#' \item{sex}{a factor denoting penguin sex (female, male)}
#' \item{year}{an integer denoting the study year (2007, 2008, or 2009)}
#' }
#' @references This dataset referenced from the palmerpenguins package.
#' @keywords datasets
#' @examples
#' data(penguins)
#' head(penguins)
#"penguins"

# 文档化
document()

# 内部数据
use_data(penguins, internal = TRUE)

# 原始数据
system.file("extdata", "mtcars.csv", package = "readr", mustWork = TRUE)

## 单元测试
use_testthat()
use_test("AHP")

test_that("AHP weights and type", {
  A = matrix(c(1, 1/2,
               2, 1), byrow = TRUE, nrow = 2)
  rlt = AHP(A)
  expect_equal(rlt$W, c(0.3333, 0.6667), tolerance = 0.001)
  expect_type(rlt, "list")
})

test()

## R CMD check检测
check()

## 安装使用
install()                   # 安装包
library(mathmodels)
# some code

## CRAN检测
library(rhub)
validate_email("zhjx_19@hrbcu.edu.cn")
results = check_for_cran()
results$cran_summary()
use_cran_comments()         # usethis 包

## 编写README, NEWS
use_readme_rmd()
use_news_md()

## 捆绑包
build()

## 推广包
# 编写Vignettes
use_vignette("Evaluation-Algorithm")   # 或_, 不能用空格
# 创建网站
pkgdown::build_site()

iris %>% 
  group_by(Species) %>% 
  slice_max(Sepal.Length)

