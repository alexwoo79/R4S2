### ch3 可视化与建模技术
library(tidyverse)

## 3.1 ggplot2基础语法
# 绘图模板
# ggplot(data = <DATA>,
#        mapping = aes(<MAPPINGS>)) +
#   <GEOM_FUNCTION>(
#     mapping = aes(<MAPPINGS>),
#     stat = <STAT>,
#     position = <POSITION>) +
#   <SCALE_FUNCTION> +
#   <COORDINATE_FUNCTION> +
#   <FACET_FUNCTION> +
#   <THEME_FUNCTION>

## 数据
head(mpg, 4)
ggplot(data = mpg)

## 映射
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv))

ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point()

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv))

## 几何对象
ggplot(mpg, aes(displ, hwy)) +
  geom_point(color = "blue")

ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  geom_smooth()

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth()

# 分组美学
load("data/ecostats.rda")
ecostats

ggplot(ecostats, aes(Year, gdpPercap)) +
  geom_line()

ggplot(ecostats, aes(Year, gdpPercap)) +
  geom_line(aes(group = Region), alpha = 0.2) +
  geom_smooth(se = FALSE, size = 1.2)

## 标度
# 坐标轴刻度与刻度标签
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  scale_y_continuous(breaks = seq(15, 40, by = 10),
                     labels = c("一五","二五","三五"))

ggplot(mpg, aes(x = drv)) +
  geom_bar() + # 条形图
  scale_x_discrete(labels = c("4" = "四驱", "f" = "前驱", "r" = "后驱"))

economics
ggplot(tail(economics, 45), aes(date, uempmed / 100)) +
  geom_line() +
  scale_x_date(date_breaks = "6 months", date_labels = "%b%Y") +
  scale_y_continuous(labels = scales::percent)

# 坐标轴标签,图例
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  labs(x = "引擎大小 (L)", y = "高速燃油率 (mpg)", color = "驱动类型") + # 或者
  # xlab("引擎大小 (L)") + ylab("高速燃油率 (mpg)")
  theme(legend.position = "top")

# 坐标轴范围
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  coord_cartesian(xlim = c(5, 7), ylim = c(10, 30)) # 或者
# xlim(5, 7) + ylim(10, 30)

# 变换坐标轴
load("data/gapminder.rda")
p = ggplot(gapminder, aes(gdpPercap, lifeExp)) +
  geom_point() +
  geom_smooth()
p + scale_x_continuous(labels = scales::dollar)
p + scale_x_log10(labels = scales::dollar)

# 图标题
p = ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth(se = FALSE) +
  labs(title = "燃油效率随引擎大小的变化图",
       subtitle = "两座车 (跑车) 因重量小而符合预期",
       caption = "数据来自fueleconomy.gov")
p

p + theme(plot.title = element_text(hjust = 0.5), # 标题居中
          plot.subtitle = element_text(hjust = 0.5))

# fill, color颜色
ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  scale_color_manual("驱动方式", # 修改图例名
                     values = c("red", "blue", "green"),
                     # breaks = c("4", "f", "r"),
                     labels = c("四驱", "前驱", "后驱"))

ggplot(mpg, aes(x = class, fill = class)) +
  geom_bar() +
  scale_fill_brewer(palette = "Dark2") # 使用Dark2 调色版

ggplot(mpg, aes(displ, hwy, color = hwy)) +
  geom_point() +
  scale_color_gradient(low = "green", high = "red")

ggplot(mpg, aes(displ, hwy, color = hwy)) +
  geom_point() +
  scale_color_distiller(palette = "Set1")

# 文字标注
library(ggrepel)
best_in_class = mpg %>% # 选取每种车型hwy 值最大的样本
  group_by(class) %>%
  slice_max(hwy, n = 1)
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = class)) +
  geom_label_repel(data = best_in_class, aes(label = model))

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  annotate(geom = "text", x = 6, y = 40,
           label = "引擎越大\n 燃油效率越高!", size = 4, color = "red")

## 统计变换
ggplot(mpg, aes(x = class, y = hwy)) +
  geom_violin(trim = FALSE, alpha = 0.5, color = "green") + # 小提琴图
  stat_summary(fun = mean,
               fun.min = function(x) {mean(x) - sd(x)},
               fun.max = function(x) {mean(x) + sd(x)},
               geom = "pointrange", color = "red")

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  stat_smooth(method = "lm",
              formula = y ~ splines::bs(x, 3),
              se = FALSE) # 不绘制置信区间

## 坐标系
ggplot(mpg, aes(class, hwy)) +
  geom_boxplot() + # 箱线图
  coord_flip() # 从竖直图变成水平图

ggplot(mpg, aes(class, fill = drv)) +
  geom_bar() +
  coord_polar()

## 位置调整
ggplot(mpg, aes(class, fill = drv)) +
  geom_bar(position = position_dodge(preserve = "single"))
# geom_bar(position = "dodge")

ggplot(mpg, aes(displ, hwy)) +
  geom_point(position = "jitter") # 避免有散点重叠

library(patchwork)
p1 = ggplot(mpg, aes(displ, hwy)) +
  geom_point()
p2 = ggplot(mpg, aes(drv, displ)) +
  geom_boxplot()
p3 = ggplot(mpg, aes(drv)) +
  geom_bar()
p1 | (p2 / p3)

## 分面
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_wrap(~ drv, scales = "free")

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_wrap(~ drv + cyl)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  facet_grid(drv ~ cyl)

## 主题
ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  theme_bw()

## 中文字体
library(showtext)
font_add("heiti", "simhei.ttf")
font_add("kaiti", "simkai.ttf")
showtext_auto()
ggplot(mpg, aes(displ, hwy, color = drv)) +
  geom_point() +
  theme(axis.title = element_text(family = "heiti"),
        plot.title = element_text(family = "kaiti")) +
  xlab("发动机排量(L)") +
  ylab("高速里程数(mpg)") +
  ggtitle("汽车发动机排量与高速里程数") +
  annotate("text", 5, 35, family = "kaiti", size = 8,
           label = "设置中文字体", color = "red")
ggsave("images/font_example.pdf", width = 7, height = 4)

## 3.2 ggplot2图形示例
## 热图
df = mpg %>%
  mutate(across(c(class, drv), as.factor)) %>%
  count(class, drv, .drop = FALSE)
df
df %>%
  ggplot(aes(class, drv)) +
  geom_tile(aes(fill = n)) +
  geom_text(aes(label = n)) +
  scale_fill_gradient(low = "white", high = "darkred")

## 网络图
load("data/phone_call.rda")
nodes
edges
library(visNetwork)
visNetwork(nodes, edges)

## 人口金字塔图
pops = read_csv("data/hljPops.csv") %>%
  mutate(Age = as_factor(Age)) %>%
  pivot_longer(-Age, names_to = "性别", values_to = "Pops") # 宽变长
pops
ggplot(pops, aes(x = Age, fill = 性别,
                 y = ifelse(性别 == "男", -Pops, Pops))) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = abs, limits = c(-200,200)) +
  xlab("年龄段") + ylab("人口数(万)") +
  coord_flip()

## 折线图与面积图
p1 = ggplot(economics, aes(date, uempmed)) +
  geom_line(color = "red")
p2 = ggplot(economics, aes(date, uempmed)) +
  geom_area(color = "red", fill = "steelblue")
p1 | p2

## 饼图
piedat = mpg %>% # 先准备绘制饼图的数据
  group_by(class) %>%
  summarize(n = n(), labels = str_c(round(100 * n / nrow(.), 2), "%"))
piedat
ggplot(piedat, aes(x = "", y = n, fill = class)) +
  geom_bar(width = 1, stat = "identity") +
  coord_polar("y", start = 0) +
  geom_text(aes(label = labels),
            position = position_stack(vjust = 0.5)) +
  theme_void()

## 地理空间图
gdp = read_csv("datas/2019分省GDP.csv") %>% 
  mutate(GDP = round(GDP / 10000, 2),
         GDPrank = cut(GDP, breaks = c(0,3,6,12), 
                       labels = c("低","中","高"))) %>% 
  as_tibble()
gdp

library(sf)
load("datas/China_map_all.rda")
sf_use_s2(FALSE)   # 最新版本sf, 有个Geometry数据无效
sheng = chinamap %>%
  group_by(Name_Province) %>%
  summarise(geometry = sf::st_union(geometry))
sheng = left_join(sheng, gdp, 
                  by = c("Name_Province" = "地区"))
sheng
ggplot(sheng) +   
  geom_sf(aes(fill = GDP)) +   
  coord_sf() +
  scale_fill_gradient(low = "green", high = "red") +
  geom_sf_label(aes(label = GDP), size = 2.5) +
  labs(x = NULL, y = NULL)

ggplot(na.omit(sheng)) +   
  geom_sf(aes(fill = GDPrank)) + 
  geom_sf(data = filter(sheng, str_detect(Name_Province, "南海"))) +
  coord_sf() +
  scale_fill_brewer(palette = "Dark2") +
  labs(x = NULL, y = NULL, fill = "GDP等级") 

## 动态交互图
library(plotly)
load("data/ecostats.rda")
ecostats = ecostats %>%
  mutate(Area = case_when(
    Region %in% c("黑龙江","吉林","辽宁") ~ "东北",
    Region %in% c("北京","天津","河北","山西","内蒙古") ~ "华北",
    Region %in% c("河南","湖北","湖南") ~ "华中",
    Region %in% c("广东","广西","海南") ~ "华南",
    Region %in% c("陕西","甘肃","宁夏","青海","新疆") ~ "西北",
    Region %in% c("四川","贵州","云南","重庆","西藏") ~ "西南",
    TRUE ~ "华东"))
p = ecostats %>%
  filter(Year == 2017) %>%
  ggplot(aes(Consumption, Investment, color = Area)) +
  geom_point() +
  theme_bw()
ggplotly(p)

library(gganimate)
ggplot(ecostats, aes(Consumption, Investment, size = Population)) +
  geom_point() +

geom_point(aes(color = Area)) +
  scale_x_log10() +
  labs(title = "年份: {frame_time}", x = "消费水平", y = "投资") +
  transition_time(Year)
anim_save("output/ecostats.gif") # 保存为gif 文件

## 3.3 统计建模技术
## 整洁模型结果
library(broom)
model = lm(mpg ~ wt, data = mtcars)
model %>%
  tidy()

model %>%
  glance()

model %>%
  augment()

model %>% augment() %>%
  ggplot(aes(x = wt, y = mpg)) +
  geom_point() +
  geom_line(aes(y = .fitted), color = "blue") +
  geom_segment(aes(xend = wt, yend = .fitted), color = "red")

model %>% augment() %>%
  ggplot(aes(x = wt, y = .resid)) +
  geom_point() +
  geom_hline(yintercept = 0, color = "blue")

## 辅助建模
library(modelr)
ex = resample_partition(mtcars, c(test = 0.3, train = 0.7))
mod = lm(mpg ~ wt, data = ex$train)
rmse(mod, ex$test)

mod = lm(mpg ~ wt + cyl + vs, data = mtcars)
data_grid(mtcars, wt = seq_range(wt, 10), cyl, vs) %>%
  add_predictions(mod)

cv10 = crossv_kfold(mtcars, 10)
cv10

cv10 %>%
  mutate(models = map(train, ~ lm(mpg ~ wt, data = .x)),
         rmse = map2_dbl(models, test, rmse))

## 批量建模
load("data/ecostats.rda")
by_region = ecostats %>%
  group_nest(Region)
by_region

by_region$data[[1]]       # 查看列表列的第1 个元素的内容
unnest(by_region, data)   # 解除嵌套, 还原到原数据
ecostats

by_region = by_region %>%
  mutate(model = map(data, ~ lm(Consumption ~ gdpPercap, .x)))
by_region

library(modelr)
by_region %>%
  mutate(rmse = map2_dbl(model, data, rmse),
         rsq = map2_dbl(model, data, rsquare),
         slope = map_dbl(model, ~ coef(.x)[[2]]),
         pval = map_dbl(model, ~ glance(.x)$p.value))

by_region %>%
  mutate(result = map(model, tidy)) %>%
  select(Region, result) %>%
  unnest(result)

by_region %>%
  mutate(result = map(model, glance)) %>%
  select(Region, result) %>%
  unnest(result)

by_region %>%
  mutate(result = map(model, augment)) %>%
  select(Region, result) %>%
  unnest(result)

# rowwise法
by_region = ecostats %>%
  nest_by(Region)
by_region

by_region = by_region %>%
  mutate(model = list(lm(Consumption ~ gdpPercap, data)))
by_region

by_region %>%
  mutate(rmse = rmse(model, data),
         rsq = rsquare(model, data),
         slope = coef(model)[[2]],
         pval = glance(model)$p.value)

by_region %>%
  summarise(tidy(model))

by_region %>%
  summarise(glance(model))

by_region %>%
  summarise(augment(model))

## 分组滚动回归
library(lubridate)
library(slider)

load("data/stocks.rda")
df = stocks %>%
  pivot_wider(names_from = Stock, values_from = Close) %>%
  mutate(season = quarter(Date))
df

df %>%
  ggplot(aes(Amazon, Google)) +
  geom_line(color = "steelblue", size = 1.1)

df_roll = df %>%
  group_by(season) %>%
  mutate(models = slide(cur_data(), ~ lm(Google ~ Amazon, .x),
                        .before = 2, .after = 2, .complete = TRUE)) %>%
  ungroup()
df_roll

df_roll %>%
  filter(!map_lgl(models, is.null)) %>%
  mutate(rsq = map_dbl(models, ~ glance(.x)$r.squared),
         sigma = map_dbl(models, ~ glance(.x)$sigma),
         slope = map_dbl(models, ~ tidy(.x)$estimate[2]))
