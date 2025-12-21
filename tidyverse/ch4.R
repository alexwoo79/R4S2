### ch4 应用统计

library(tidyverse)
tibble(
  x = seq(-4,4,length.out = 100),
  `μ=0, σ=0.5` = dnorm(x, 0, 0.5),
  `μ=0, σ=1` = dnorm(x, 0, 1),
  `μ=0, σ=2` = dnorm(x, 0, 2),
  `μ=-2, σ=1` = dnorm(x, -2, 1)
) %>%
  pivot_longer(-x, names_to = "参数", values_to = "p(x)") %>%
  ggplot(aes(x, `p(x)`, color = 参数)) +
  geom_line()

## 4.1 描述性统计
library(rstatix)
iris %>%
  group_by(Species) %>%
  get_summary_stats(type = "full")

df = starwars %>%
  mutate(skin_color = fct_lump(skin_color, n = 5)) %>%
  count(skin_color, sort = TRUE) %>%
  mutate(p = n / sum(n))
df

# 复杂条形图
ggplot(df, aes(fct_reorder(skin_color, p), p)) +
  geom_col(fill = "steelblue") + # 同geom_bar(stat = "identity")
  scale_y_continuous(labels = scales::percent) +
  labs(x = "皮肤颜色", y = "占比") +
  geom_text(aes(y = p + 0.04, label = str_c(round(p*100,1), "%")),
            size = 5, color = "red") +
  coord_flip()

# 克利夫兰点图
economics %>%
  group_by(year = lubridate::year(date)) %>%
  summarise(uempmed = mean(uempmed)) %>%
  filter(year >= 2000) %>%
  ggplot(aes(reorder(year, uempmed), uempmed)) +
  geom_point(size = 4, shape = 21,
             fill = "steelblue", color = "black") +
  geom_segment(aes(xend = ..x.., yend = 5)) +
  xlab("year") +
  coord_flip()

# 直方图
set.seed(123)
df = tibble(heights = rnorm(10000, 170, 2.5))

ggplot(df, aes(x = heights)) +
  geom_histogram(fill = "steelblue", color = "black", binwidth = 0.5) +
  stat_function(fun = ~ dnorm(.x, mean = 170, sd = 2.5) * 0.5 * 10000,
                color = "red")

# 箱线图
ggplot(mpg, aes(x = drv, y = hwy)) +
  geom_boxplot()

# 均指线与误差棒图
my_summary = function(data, .summary_var, ...) {
  summary_var = enquo(.summary_var)
  data %>%
    group_by(...) %>%
    summarise(mean = mean(!!summary_var, na.rm = TRUE),
              sd = sd(!!summary_var, na.rm = TRUE)) %>%
    mutate(se = sd / sqrt(n()))
}
df = my_summary(ToothGrowth, len, supp, dose)
df

pd = position_dodge(0.1)
ggplot(df, aes(dose, mean, color = supp, group = supp)) +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se),
                color = "black", width = 0.1, position = pd) +
  geom_line(position = pd) +
  geom_point(position = pd, size = 3, shape = 21, fill = "white") +
  xlab("剂量 (mg)") + ylab("牙齿生长") +
  scale_color_hue(name = "喂养类型", breaks = c("OJ", "VC"),
                  labels = c("橘子汁", "维生素C"), l = 40) +
  scale_y_continuous(breaks = 0:20 * 5)

## 列联表
library(janitor)
mpg %>%
  tabyl(drv) %>%
  adorn_totals("row") %>%   # 添加合计行
  adorn_pct_formatting()    # 设置百分比格式

mpg %>%
  tabyl(drv, cyl) %>%
  adorn_percentages("col") %>%          # 添加列占比
  adorn_pct_formatting(digits = 2) %>%  # 设置百分比格式
  adorn_ns()                            # 添加频数

## 4.2 参数估计
## 点估计与区间估计
df = tibble(
  height = c(167,155,166,161,168,163,179,164,178,156,
             161,163,168,163,163,169,162,174,172,172))
mu = mean(df$height)                    # 点估计: 样本均值
mu
se = sd(df$height) / sqrt(nrow(df))     # 标准误
mu + c(-1,1) * qnorm(1-0.05/2) * se     # 基于标准误的置信区间

## Bootstrap区间估计
library(infer)
boot_means = df %>%
  specify(response = height) %>%
  generate(reps = 1000, type = "bootstrap") %>% # 1000 次bootstrap
  calculate(stat = "mean")              # 计算统计量: 样本均值
boot_means

boot_ci = boot_means %>%
  get_ci(level = 0.95, type = "percentile") # bootstrap 置信区间
boot_ci

visualize(boot_means) +
  shade_ci(endpoints = boot_ci)          # 可视化

## 最小二乘估计
sales = tibble(
  cost = c(30,40,40,50,60,70,70,70,80,90),
  sale = c(143.5,192.2,204.7,266,318.2,457,333.8,312.1,386.4,503.9))
ggplot(sales, aes(cost, sale)) +
  geom_point()

m = lm(sale ~ cost, sales)
sales1 = sales[c(6,9),] %>% 
  mutate(p = predict(m, .))
ggplot(sales, aes(cost, sale)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  geom_segment(aes(x = cost, y = sale, 
                   xend = cost, yend = p),
               data = sales1, linetype = 2, color = "red")

df = readxl::read_xlsx("data/历年累计票房.xlsx") %>%
  mutate(年份 = 年份 - 2002)
p = ggplot(df, aes(年份, 累计票房)) +
  geom_point(color = "red", size = 1.5) +
  labs(x = "年份（第几年）", y = "累计票房（亿元）")
p

lm.fit = lm(car::logit(累计票房 / 800) ~ 年份, df)
coef(lm.fit)

log.fit = nls(累计票房 ~ phi1 / (1 + exp(-(phi2 + phi3 * 年份))),
              data = df,
              start = list(phi1 = 800, phi2 = -5.14, phi3 = 0.39))
coefs = coef(log.fit)
coefs

LogFit = function(x) coefs[1] / (1 + exp(-(coefs[2] + coefs[3] * x)))
p + geom_function(fun = LogFit, color = "steelblue", size = 1.2)

## 最大似然估计
loglik = function(p) 3 * log(p) + 7 * log(1-p)

library(maxLik)
m = maxLik(loglik, start = 0.5)
coef(m)                    # 最优参数估计值
stdEr(m)                   # 估计的标准误

loglik = function(theta) {
  mu = theta[1]
  sigma = theta[2]
  n = nrow(mtcars)
  - n*log(sigma) - 1 / (2*sigma^2) * sum((mtcars$mpg - mu)^2)
}
m = maxLik(loglik, start=c(mu=30, sigma=10))
coef(m)                    # 最优参数估计值
stdEr(m)                   # 估计的标准误

ggplot(mtcars, aes(mpg)) +
  geom_histogram(binwidth = 1, fill = "steelblue") +
  stat_function(fun = ~ dnorm(.x, mean = 20.09, sd = 5.93) * 32,
                color = "red", size = 1.2)

## 4.3 假设检验
## 估算样本量
library(pwr)
# 每组样本量50, Cohen 效应量取值0.5, 显著水平取值0.05, 计算功效
pwr.t.test(n = 50, d = 0.5, sig.level = 0.05, alternative = "greater")
# Cohen 效应量取值0.5, 显著水平取值0.05, 功效取值0.8, 计算每组样本量
pwr.t.test(power = 0.8, d = 0.5, sig.level = 0.05, alternative = "greater")

## 4.3.1 基于理论的假设检验
## 方差分析
library(rstatix)
df = ToothGrowth %>%
  mutate(dose = factor(dose))
head(df, 3)

# 正态性检验(H0:正态)
shapiro_test(df, len)
# 检验方差齐性(H0:方差齐)
levene_test(df, len ~ supp * dose)

# 两因素混合模型方差分析
anova_test(df, len ~ supp * dose)
# Tukey’HSD多重比较
tukey_hsd(df, len ~ supp * dose)

# 重复测量方差分析
df %>%
  mutate(ID = rep(1:10, 6)) %>%
  anova_test(len ~ supp * dose + Error(ID / (supp * dose)))

## 卡方检验
titanic = read_rds("data/titanic.rds")
tbl = titanic %>%
  janitor::tabyl(Survived, Pclass)
tbl

rstatix::chisq_test(titanic$Survived, titanic$Pclass)
pairwise_prop_test(as.matrix(tbl[,-1]))

## 4.3.2 基于重排的假设检验
load("data/movies_sample.rda")
movies_sample

## t检验
movies_sample %>%
  group_by(genre) %>%
  summarise(n = n(), avg_rat = mean(rating), sd_rat = sd(rating))

library(infer)
null_distribution = movies_sample %>%
  specify(formula = rating ~ genre) %>%   # 响应变量~解释变量
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "diff in means", order = c("Romance", "Action"))
null_distribution

visualize(null_distribution, bins = 15) +
  shade_p_value(obs_stat = tibble(stat = 1.047), direction = "both")

null_distribution %>% # 获取P 值
  get_p_value(obs_stat = tibble(stat = 1.047), direction = "both")

## 4.4 回归分析
## 多元线性回归
penguins = read_csv("data/penguins.csv") %>%
  mutate(species = factor(species))
penguins

ggplot(penguins, aes(body_mass)) +
  geom_histogram(bins = 20, fill = "steelblue", color = "black")

## 共线性诊断
mdl0 = lm(body_mass ~ ., penguins)
car::vif(mdl0)

## 逐步回归
mdl1 = step(mdl0, direction = "backward",
            trace = 0) # 避免输出中间过程
summary(mdl1)

confint(mdl1)
library(modelr)
rmse(mdl1, penguins)

## 回归模型中的分类变量
table(penguins$species)
model_matrix(penguins, ~ species - 1)
model_matrix(penguins, ~ species)

# 修改参照水平
# penguins$species = relevel(penguins$species, ref = "Gentoo")

mdl2 = lm(body_mass ~ species + sex * island + bill_length + I(bill_length^2)
          + bill_depth + I(bill_depth^2) + flipper_length
          + I(flipper_length^2), penguins) %>%
  step(direction = "backward", trace = 0)
summary(mdl2)

# 模型比较
anova(mdl1, mdl2)

## 回归诊断
library(ggfortify)
autoplot(mdl2, which = c(1:3,6))   # 6 个图形可选
shapiro.test(mdl2$residuals)       # 残差正态性检验
library(lmtest)
dwtest(mdl2)                       # 残差独立性检验
bptest(mdl2)                       # 残差异方差检验

## 模型预测
newdat = slice_sample(penguins[,-6], n = 5)
predict(mdl2, newdat, interval = "confidence")

## 梯度下降法
gd = function(X, y, init, eta = 1e-3, err = 1e-3, maxit = 1000, adapt = FALSE) {
  ## X 为自变量数据矩阵, y 为因变量向量, init 为参数初始值, eta 为学习率
  ## err 为误差限, maxit 为最大迭代次数, adapt 是否自适应修改学习率
  ## 返回回归系数估计, 损失向量, 迭代次数, 拟合值, RMSE

  # 初始化
  X = cbind(Intercept = 1, X)
  beta = init
  names(beta) = colnames(X)
  loss = crossprod(X %*% beta - y)
  tol = 1
  iter = 1
  # 迭代
  while(tol > err && iter < maxit) {
    LP = X %*% beta
    grad = t(X) %*% (LP - y)
    betaC = beta - eta * grad
    tol = max(abs(betaC - beta))
    beta = betaC
    loss = append(loss, crossprod(LP - y))
    iter = iter + 1
    if(adapt)
      eta = ifelse(loss[iter] < loss[iter-1], eta * 1.2, eta * 0.8)
  }
  list(beta = beta, loss = loss, iter = iter, fitted = LP,
       RMSE = sqrt(crossprod(LP - y) / (nrow(X) - ncol(X))))
}

n = 1000
set.seed(123)
x1 = rnorm(n)
x2 = rnorm(n)
y = 1 + 0.6*x1 - 0.2*x2 + rnorm(n)
X = cbind(x1, x2)
gd_rlt = gd(X, y, rep(0,3), err = 1e-8, eta = 1e-4, adapt = TRUE)
rbind(gd = round(gd_rlt$beta[, 1], 5),
      lm = coef(lm(y ~ x1 + x2)))     # 与lm 结果对比

gd_rlt$iter # 迭代次数
plot(gd_rlt$loss, xlab = "迭代次数", ylab = "损失")
