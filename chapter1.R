library(tidyverse)
mpg
glimpse(mpg)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, colour = class))

# ?mpg

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))


ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, colour = class)) +
  facet_wrap(~class, nrow = 2)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = drv, y = cyl, colour = class)) +
  facet_grid(drv ~ cyl)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, colour = class)) +
  facet_grid(drv ~ .)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, colour = class)) +
  facet_grid(. ~ cyl)

# 几何对象

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg, mapping = aes(x = displ, y = hwy, colour = drv)) +
  geom_point() +
  geom_smooth()


ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(colour = drv)) +
  geom_smooth()

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(colour = drv)) +
  geom_smooth(
    data = filter(mpg, class == "subcompact"),
    # se = FALSE # 不显示置信区间
  )

# 统计变换

diamonds

glimpse(diamonds)
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut), fill = "lightblue", colour = "black")

ggplot(data = diamonds) +
  stat_count(mapping = aes(x = cut))
# 等价于
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))


# example
demo_df <- tribble(
  ~a      , ~b ,
  "bar_1" , 20 ,
  "bar_2" , 30 ,
  "bar_3" , 40
)

ggplot(data = demo_df) +
  geom_bar(mapping = aes(x = a, y = b), stat = "identity")

ggplot(data = diamonds) +
  geom_col(mapping = aes(x = cut, y = carat))
# 等价于
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, y = carat), stat = "identity")


#...prop...
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))

# using after_stat()
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, y = after_stat(prop), group = 1))

#group=1 means that we want to treat all the data as one group when calculating proportions.
# 中文解释：在计算比例时，我们希望将所有数据视为一个组。
# Without group = 1, the proportions would be calculated separately for each default group (which is each cut in this case), leading to incorrect results.
# By specifying group = 1, we ensure that the proportions are calculated based on the entire dataset, giving us the correct overall proportions for each cut category.

?stat_summary

ggplot(data = diamonds) +
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.min = min,
    fun.max = max,
    fun = median
  )
geom_point(mapping = aes(x = carat, y = price))

?stat_smooth
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  stat_smooth()

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, y = ..prop..))

ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = color, y = after_stat(prop), group = 1)
  )

ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = color, y = after_stat(prop), group = color)
  )

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity)) +
  theme_minimal()

ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) +
  geom_bar(alpha = 0.2, position = 'identity') +
  theme_minimal()


ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) +
  geom_bar(position = 'fill') +
  theme_minimal()

ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) +
  geom_bar(position = 'stack') +
  theme_minimal()

ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) +
  geom_bar(position = 'dodge') +
  theme_minimal()


ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy), position = "jitter")

ggplot(data = mpg) +
  geom_jitter(mapping = aes(x = displ, y = hwy))

?position_stack
?position_fill
?position_dodge
?position_identity
?position_jitterdodge
?position_jitter
?position_nudge

#坐标系
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot() +
  coord_flip()

p <- ggplot(mpg, aes(class, hwy))
p + geom_boxplot()
# Orientation follows the discrete axis
ggplot(mpg, aes(hwy, class)) + geom_boxplot()

p + geom_boxplot(notch = TRUE)
p + geom_boxplot(varwidth = TRUE)
p + geom_boxplot(fill = "white", colour = "#3366FF")


# map

nz <- map_data("world")
ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", colour = "black") +
  coord_quickmap()


bar <- ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = cut),
    show.legend = FALSE,
    width = 1
  ) +
  theme(aspect.ratio = 1) +
  theme_bw()

bar + coord_flip()
bar + coord_polar(theta = "y")
bar + coord_radial(expand = FALSE)
