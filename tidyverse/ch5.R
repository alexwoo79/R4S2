### ch5 探索性数据分析

## 5.1 缺失值
# replace_with_na(df, replace = list(x = 9999))
mean(c(1,2,NA,4))
mean(c(1,2,NA,4), na.rm = TRUE)

## 探索缺失值
library(naniar)                   # 探索与可视化缺失
mcar_test(airquality)             # 自带的空气质量数据集

vis_miss(airquality)
n_miss(airquality)                # 缺失样本的个数
n_complete(airquality)            # 完整样本的个数
prop_miss_case(airquality)        # 缺失样本占比
prop_miss_var(airquality)         # 缺失变量占比

miss_case_summary(airquality)     # 每行缺失情况排序
miss_case_table(airquality)       # 行缺失汇总表
miss_var_summary(airquality)      # 每个变量缺失情况排序
miss_var_table(airquality)        # 变量缺失汇总表

gg_miss_var(airquality)

aq_shadow = bind_shadow(airquality)
aq_shadow

aq_shadow %>%
  group_by(Ozone_NA) %>%
  summarise_at(.vars = "Solar.R",
               .funs = c("mean", "sd", "var", "min", "max"), na.rm = TRUE)

aq_shadow %>%
  ggplot(aes(Temp, color = Ozone_NA)) +
  geom_density()

## 删除缺失值
na.omit(df)
# drop_na(df, <tidy-select>)

# 删除缺失超过60%的行
df %>%
  filter(pmap_lgl(., ~ mean(is.na(c(...))) < 0.6))
# 删除缺失超过60%的列
df %>%
  select(where(~ mean(is.na(.x)) < 0.6))

## 单重插补
airquality %>%
  group_by(Month) %>%
  mutate(Ozone = naniar::impute_mean(Ozone))
impute_median(airquality, Ozone ~ Month)

# df %>%
#  select(<tidy-select>) %>%        # 选择要插补的分类变量列
#  map_dfc(~ replace_na(.x, rstatix::get_mode(.x)[1]))

impute_lm(airquality, Ozone ~ Solar.R + Wind + Temp,
          add_residual = "normal")  # 添加随机误差

library(simputation)    
airquality %>%
  bind_shadow() %>% as.data.frame() %>%
  impute_cart(Ozone ~ Solar.R + Wind + Temp) %>%
  add_label_shadow() %>%
  ggplot(aes(Solar.R, Ozone, color = any_missing)) +
  geom_point() +
  theme(legend.position = "top")

## 多重插补
library(mice) 
aq_imp = mice(airquality, m = 5, maxit = 10, method = "pmm",
              seed = 1, print = FALSE)   # 设置种子,不输出过程

aq_dat = mice::complete(aq_imp)

## 时间序列插补
library(imputeTS) 
imp = na_interpolation(tsAirgap, option = "spline")
ggplot_na_imputations(tsAirgap, imp, tsAirgapComplete)

## 5.1.2 异常值
univ_outliers = function(x, method = "boxplot", k = NULL,
                         coef = NULL, lp = NULL, up = NULL) {
  switch(method,
         "sd" = {
           if(is.null(k)) k = 3
           mu = mean(x, na.rm = TRUE)
           sd = sd(x, na.rm = TRUE)
           LL = mu - k * sd
           UL = mu + k * sd},
         "boxplot" = {
           if(is.null(coef)) coef = 1.5
           Q1 = quantile(x, 0.25, na.rm = TRUE)
           Q3 = quantile(x, 0.75, na.rm = TRUE)
           iqr = Q3 - Q1
           LL = Q1 - coef * iqr
           UL = Q3 + coef * iqr},
         "percentiles" = {
           if(is.null(lp)) lp = 0.025
           if(is.null(up)) up = 0.975
           LL = quantile(x, lp)
           UL = quantile(x, up)
         })
  idx = which(x < LL | x > UL)
  n = length(idx)
  list(outliers = x[idx], outlier_idx = idx, outlier_num = n)
}

x = mpg$hwy
univ_outliers(x)                           # 箱线图法
univ_outliers(x, method = "sd")            # 标准差法
univ_outliers(x, method = "percentiles")   # 百分位数法

library(DMwR2)
lofs = lofactor(iris[,1:4], k = 10)        # k 为邻居数
# 选择LOF 值最大的5 个索引, 认为是异常样本
order(lofs, decreasing = TRUE)[1:5]

rlt = outliers.ranking(iris[,1:4])
# rlt$rank.outliers[1:5] # 异常值排名前五的样本
sort(rlt$prob.outliers, decreasing = TRUE)[1:5]

mod = lm(mpg ~ wt, mtcars)
car::outlierTest(mod)

library(outForest)
# 用iris 数据随机生成若干异常值
irisWithOut = generateOutliers(iris, p = 0.02, seed = 123)
# 检测除Sepal.Length 外数值变量异常值, 异常值数设为3
out = outForest(irisWithOut, . - Sepal.Length ~ .,
                max_n_outliers = 3, verbose = 0)
outliers(out)                # 查看异常值及相关信息
plot(out, what = "scores")   # 绘制各变量异常值得分图

## 5.2 特征工程
## 特征缩放
scale(x)                    # 标准化
scale(x, scale = FALSE)     # 中心化: 减去均值

# 归一化
rescale = function(x, type = "pos", a = 0, b = 1) {
  rng = range(x, na.rm = TRUE)
  switch (type,
          "pos" = (b - a) * (x - rng[1]) / (rng[2] - rng[1]) + a,
          "neg" = (b - a) * (rng[2] - x) / (rng[2] - rng[1]) + a)
}
as_tibble(iris) %>%      # 将所有数值列归一化到[0,100]
  mutate(across(where(is.numeric), rescale, b = 100))

# 行规范化
iris[1:3,-5] %>%
  pmap_dfr(~ c(...) / norm(c(...), "2"))

# 数据平滑
library(slider)
library(patchwork)
p1 = economics %>%
  ggplot(aes(date, uempmed)) +
  geom_line()
p2 = economics %>% # 做五点移动平均
  mutate(uempmed = slide_dbl(uempmed, mean, .before = 2, .after = 2)) %>%
  ggplot(aes(date, uempmed)) +
  geom_line()
p1 | p2

## 特征变换
# 多项式特征
library(tidymodels)
recipe(hwy ~ displ + cty, data = mpg) %>%
  step_poly(all_predictors(), degree = 2, options = list(raw = TRUE)) %>%
  prep() %>%
  bake(new_data = NULL)

# 正态性变换
df = mlr3data::kc_housing
p1 = ggplot(df, aes(price)) +
  geom_histogram()
p2 = ggplot(df, aes(log10(price))) +
  geom_histogram()
p1 | p2

# BOX-COX变换与Yeojohnson变换
library(bestNormalize)
x = rgamma(100, 1, 1)
yj_obj = yeojohnson(x)
yj_obj$lambda                                      # 最优lambda
p = predict(yj_obj)                                # 变换
x2 = predict(yj_obj, newdata = p, inverse = TRUE)  # 逆变换

library(rbin)
df = readxl::read_xlsx("data/hyper.xlsx")
bins = df %>%
  rbin_equal_length(hyper, age, bins = 3)
rbin_create(df, age, bins) %>% head(3)

## 特征降维
recipe(~ ., data = iris) %>%
  step_normalize(all_numeric()) %>%
  step_pca(all_numeric(), threshold = 0.85) %>%
  prep() %>%
  bake(new_data = NULL)

## 5.3 探索变量间的关系
## 两个分类变量
titanic = read_rds("data/titanic.rds")
titanic %>%
  ggplot(aes(Pclass, fill = Survived)) +
  geom_bar(position = "dodge")

library(rstatix)
tbl = table(titanic$Pclass, titanic$Survived)
cramer_v(tbl)               # Cramer'V 检验
prop_test(tbl)              # 比例检验
chisq_test(tbl)             # 卡方检验

## 分类变量与连续变量
mpg %>%
  ggplot(aes(displ, color = drv)) +
  geom_density()            # 概率密度曲线

mpg %>%
  group_by(drv) %>%
  get_summary_stats(displ, type = "five_number")  # 五数汇总

mpg %>%
  anova_test(displ ~ drv)    # 方差分析

## 两个连续变量
iris[-5] %>%
  cor_mat() %>%                  # 相关系数矩阵
  replace_triangle(by = NA) %>%  # 将下三角替换为NA
  cor_gather() %>%               # 宽变长
  arrange(- abs(cor))            # 按绝对值降序排列

library(GGally)
ggpairs(iris, columns = names(iris))
