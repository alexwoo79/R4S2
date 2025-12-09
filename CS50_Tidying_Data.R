# storms example for learning dplyr and tidyr
# Load necessary libraries
library(tidyverse)

# Load the storms dataset
data()
storms
# View the structure of the dataset
str(storms)

glimpse(storms)

unique(storms$status)
# Select specific columns: name, year, status
# filter rows where status is 'hurricane'
filter(
  dplyr::select(
    storms,
    -c(starts_with('l'), ends_with('diameter'), pressure)
  ),
  status == 'hurricane'
)

# Introduce pipe operator

hurricane <- storms |>
  select(!c(lat, long, pressure, ends_with("diameter"))) |>
  filter(status == "hurricane") |>
  arrange(desc(wind), name) |>
  distinct(name, year, .keep_all = TRUE)

# View the resulting hurricane dataset
glimpse(hurricane)
# Save the hurricane dataset to a CSV file with selected columns
hurricane |>
  select(name, year, wind) |>
  write.csv("hurricane_data.csv", row.names = FALSE)


# using subset to create a similar hurricane dataset

# subset 中的select 不可以使用ends_with()，只能使用列名向量
hurricane_subset <- subset(
  storms,
  select = -c(
    lat,
    long,
    pressure,
    tropicalstorm_force_diameter,
    hurricane_force_diameter
  ),
  status == "hurricane"
)
hurricane_subset <- hurricane_subset[
  order(-hurricane_subset$wind, hurricane_subset$name),
]
hurricane_subset <- hurricane_subset[
  !duplicated(hurricane_subset[, c("name", "year")]),
]
# View the resulting hurricane_subset dataset
glimpse(hurricane_subset)
