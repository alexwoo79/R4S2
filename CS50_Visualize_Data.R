# Load csv file
votes <- read.csv(here('votes.csv'))

votes <- votes |>
  mutate(
    total = poll + mail
  )

# Visualize the votes using ggplot2
library(ggplot2)
ggplot(
  votes,
  aes(x = reorder(candidate, desc(total)), y = total)
) +
  geom_col(aes(fill = candidate)) +
  scale_y_continuous(limits = c(0, max(votes$total) + 20)) +
  labs(
    title = "Election Results",
    x = "Candidate",
    y = "Total Votes"
  ) +
  theme_minimal() +
  coord_flip()
