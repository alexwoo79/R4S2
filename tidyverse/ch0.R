### ch0 如何学习R编程

## 0.1 计算并绘制ROC曲线
library(tidyverse)

df = tibble(
  ID = 1:10, 
  真实类别 = c("Pos","Pos","Pos","Neg","Pos","Neg","Neg","Neg","Pos","Neg"),
  预测概率 = c(0.95,0.86,0.69,0.65,0.59,0.52,0.39,0.28,0.15,0.06))
df

c = 0.85
df1 = df %>% 
  mutate(
    预测类别 = ifelse(预测概率 >= c, "Pos", "Neg"), 
    预测类别 = factor(预测类别, levels = c("Pos", "Neg")),
    真实类别 = factor(真实类别, levels = c("Pos", "Neg")))
df1

cm = table(df1$预测类别, df1$真实类别)
cm

cm["Pos",] / colSums(cm)

cal_ROC = function(df, c) {
  df = df %>% 
    mutate(
      预测类别 = ifelse(预测概率 >= c, "Pos", "Neg"), 
      预测类别 = factor(预测类别, levels = c("Pos", "Neg")),
      真实类别 = factor(真实类别, levels = c("Pos", "Neg")))
  cm = table(df$预测类别, df$真实类别)
  t = cm["Pos",] / colSums(cm)
  list(TPR = t[[1]], FPR = t[[2]])
}

cal_ROC(df, 0.85)

c = seq(1, 0, -0.02)
rocs = map_dfr(c, cal_ROC, df = df)
head(rocs)      # 查看前6个结果

rocs %>% 
  ggplot(aes(FPR, TPR)) +
  geom_line(size = 2, color = "steelblue") +
  geom_point(shape = "diamond", size = 4, color = "red") +
  theme_bw()


## 面向对象
a = 1L
class(a)

b = 1:10
class(b)

## 面向函数
f = function(x) x + 1
class(f)

?lm

head(mtcars)
model = lm(mpg ~ disp, data = mtcars)
summary(model)      # 查看回归汇总结果

AreaCircle = function(r) {
  S = pi * r * r
  return(S)
}

AreaCircle(5)

rs = c(2,4,7)
purrr::map_dbl(rs, AreaCircle)  

## 向量化编程
y = c(rep("是", 8), rep("否", 9))
y

table(y)                   # 计算各分类的频数, 得到向量
p = table(y) / length(y)   # 向量除以标量
p

log(p)                     # 向量取对数
p * log(p)                 # 向量乘以向量, 对应元素做乘法
- sum(p * log(p))          # 向量求和

