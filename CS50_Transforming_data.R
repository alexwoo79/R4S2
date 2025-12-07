# CS50: Introduction to Data Science
# This is the Second course , Transforming Data
# temperature
# load .Rdata
library(here)
file <- here('temps.Rdata')
load(file)
temps
mean(temps)

temps[2] # access second element of vector
temps[4] # access fourth element of vector
temps[7] # access seventh element of vector
temps[c(2, 4, 7)] # access multiple elements of vector
temps[-c(2, 4, 7)] # access all but multiple elements of vector

# logical expressions
# ==, !=, >, <, >=, <=
temps[temps > 40]
temps[temps <= 32]
temps[1] > 0

temps < 0
# get positions of temps less than 0

which(temps < 0)
which(temps > 60)

# logical operators
# & (and), | (or), ! (not)
temps[temps > 32 & temps < 50]
temps[temps < 32 | temps > 50]
temps[!(temps > 32)]
# get positions of temps between 32 and 50
which(temps > 32 & temps < 50)

# && and ||
# only evaluates first element of each vector

which(temps < 0 | temps > 60)

# any() and all() functions show true or false if any or all elements meet condition
any(temps < 0 | temps > 60)
all(temps > 0 & temps < 100)

temps[which(temps < 0 | temps > 60)]
temps[temps < 0 | temps > 60]
temps[!(temps < 0 | temps > 60)]

# create a logical vector to use as a filter
filter <- !(temps < 0 | temps > 60)
temps[filter]

# save filtered temps to a new variable

no_outliers <- temps[filter]
outliers <- temps[!filter]

save(no_outliers, file = here('no_outliers.Rdata'))
save(outliers, file = here('outliers.Rdata'))


# chicks example
chicks_file <- here('chicks.csv')
chicks <- read.csv(chicks_file)
glimpse(chicks)

# mean weight of chicks
mean(chicks$weight) #NA
mean(chicks$weight, na.rm = FALSE) #NA
mean(chicks$weight, na.rm = TRUE) # 280.7692

#group by feed
library(dplyr)
chicks %>%
  group_by(feed) %>%
  summarize(mean_weight = mean(weight, na.rm = TRUE))


filter <- chicks$feed == 'casein'
casein_chicks <- chicks[filter, ]
casein_chicks
mean(casein_chicks$weight, na.rm = TRUE)

which(!is.na(chicks$weight))

chicks_narm <- chicks[!is.na(chicks$weight), ]

chicks_narm <- subset(chicks, !is.na(weight))

soybean_chicks <- subset(chicks, feed == 'soybean')

# reset row names
rownames(chicks) <- NULL
rownames(chicks)

#sum logical vectors
sum(is.na(chicks$weight)) # 0

#feed options
feed_options <- unique(chicks$feed)

# prompt user for feed type
cat('1', feed_options[1], '\n')
cat('2', feed_options[2], '\n')
cat('3', feed_options[3], '\n')
cat('4', feed_options[4], '\n')
cat('5', feed_options[5], '\n')
cat('6', feed_options[6], '\n')

formatted_options <- paste0(1:length(feed_options), '. ', feed_options)
cat(formatted_options, sep = '\n')
feed_choice <- as.integer(readline(prompt = 'Feed type: '))
# Print chosen feed type
chosen_feed <- feed_options[feed_choice]

#handle invalid input
if (feed_choice < 1 | feed_choice > length(feed_options) | is.na(feed_choice)) {
  cat(
    'Invalid choice. Please choose a number between 1 and',
    length(feed_options),
    '\n'
  )
} else {
  cat('You chose feed type:', chosen_feed, '\n')

  chosen_data <- subset(chicks, feed == chosen_feed)
  chosen_data
}


#combine dataset Cs50 sales.R
# using Q1, Q2, Q3, Q4 csv files
Q1 <- read.csv(here('Q1.csv'))
Q1$quarter <- 'Q1'
Q2 <- read.csv(here('Q2.csv'))
Q2$quarter <- 'Q2'
Q3 <- read.csv(here('Q3.csv'))
Q3$quarter <- 'Q3'
Q4 <- read.csv(here('Q4.csv'))
Q4$quarter <- 'Q4'

# combine datasets using rbind
sales <- rbind(Q1, Q2, Q3, Q4)
# high value sales
sales$values <- ifelse(sales$sale_amount > 100, 'High_Value', 'Regular_Value')
sales

#use case_when to create a new variable
library(dplyr)
sales_case_when <- sales %>%
  mutate(
    values = case_when(
      sale_amount > 500 ~ 'Very_High_Value',
      sale_amount > 100 ~ 'High_Value',
      TRUE ~ 'Regular_Value'
    )
  )
sales_case_when
