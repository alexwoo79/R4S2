library(here)
library(tidyverse)
# Load csv file
votes <- read.csv(here('votes.csv'))

votes <- votes |>
  mutate(
    total = poll + mail
  )

# Visualize the votes using ggplot2

p <- ggplot(
  votes,
  aes(x = reorder(candidate, desc(total)), y = total)
) +
  geom_col(
    aes(fill = candidate),
    show.legend = FALSE # Remove legend
  ) +
  scale_y_continuous(limits = c(0, max(votes$total) + 20)) +
  scale_fill_viridis_d() +
  labs(
    title = "Election Results",
    x = "Candidate",
    y = "Total Votes"
  ) +
  theme_minimal() +
  coord_flip()

# Save the plot to a file
ggsave(
  filename = here('election_results.png'),
  plot = p,
  width = 8,
  height = 6,
  dpi = 300
)

library(plotly)
# Convert ggplot to interactive plotly plot
interactive_plot <- ggplotly(p)
# Save the interactive plot to an HTML file
htmlwidgets::saveWidget(
  interactive_plot,
  file = here('election_results.html')
)


# Candy data visualization

candy_raw <- load(here('candy.RData'))

glimpse(candy)

candy |>
  ggplot(mapping = aes(x = price_percentile, y = sugar_percentile)) +
  geom_jitter(
    color = 'darkorchid',
    size = 2,
    shape = 21,
    fill = 'green',
    alpha = 0.6
  ) +
  labs(
    title = 'Sugar vs Price Percentile of Candies',
    x = 'Price Percentile',
    y = 'Sugar Percentile'
  ) +
  theme_classic()


# timeseries data visualization

anita_raw <- load(here('anita.RData'))

glimpse(anita)
anita |>
  ggplot(aes(x = timestamp, y = wind)) +
  geom_line(linetype = 3, linewidth = 0.5) +
  geom_point(color = 'deepskyblue4', size = 2) +
  geom_hline(
    yintercept = 65,
    color = 'red',
    linetype = 'dashed'
  ) +
  labs(
    title = 'Hurricane Anita',
    x = 'Date',
    y = 'Wind_Speed(knots)'
  ) +
  theme_light()


library(ggplot2)
yline <- 65

p2 <- anita |>
  ggplot(aes(x = timestamp, y = wind)) +
  geom_line(linetype = 3, linewidth = 0.5) +
  geom_point(color = "deepskyblue4", size = 2) +
  geom_hline(yintercept = yline, color = "red", linetype = "dashed") +
  annotate(
    "text",
    x = -Inf,
    y = yline,
    label = paste0(yline, ""),
    color = "red",
    hjust = 1.4,
    vjust = 0,
    size = 3
  ) +
  coord_cartesian(clip = "off") +
  theme_light() +
  theme(plot.margin = grid::unit(c(0.5, 1.5, 0.5, 0.5), "lines")) # 给右侧留出空间

#hjust：水平对齐；0 = 左对齐，0.5 = 居中，1 = 右对齐。小于0会把文本再向左移，大于1会把文本再向右移。
#vjust：垂直对齐；0 = 底部对齐，0.5 = 垂直居中，1 = 顶部对齐。小于0会向下移，大于1会向上移。

ggsave(
  filename = here('hurricane_anita.png'),
  plot = p2,
  width = 8,
  height = 6,
  dpi = 300
)

ggplotly(p2)
