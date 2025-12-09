# Tally votes for favorite shows
library(tidyverse)
shows <- read.csv("shows.csv")

shows |>
  group_by(show) |>
  summarize(votes = n()) |>
  ungroup() |>
  arrange(desc(votes))

shows$show <- shows$show |>
  str_trim() |>
  str_to_title() |>
  str_squish() # Standardize formatting trim whitespace and capitalization
shows$show[str_detect(shows$show, 'Avatar')] <- 'Avatar: The Last Airbender'

shows |>
  group_by(show) |>
  summarise(votes = n()) |>
  ungroup() |>
  arrange(desc(votes))
