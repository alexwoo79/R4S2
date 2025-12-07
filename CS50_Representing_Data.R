# Description: This script demonstrates basic R functions including readline, paste, print, and read.table.
# This script prompts the user for their name and greets them.

name <- readline("Enter your name: ")
greeting <- paste("Hello,", name)
print(greeting)
# End of script

# readline example from R documentation
fun <- function() {
  ANSWER <- readline("Are you a satisfied R user? ")
  ## a better version would check the answer less cursorily, and
  ## perhaps re-prompt
  if (substr(ANSWER, 1, 1) == "n") {
    cat("This is impossible.  YOU LIED!\n")
  } else {
    cat("I knew it.\n")
  }
}
if (interactive()) {
  fun()
}

#paste example from R documentation
x <- "world"
y <- paste("Hello", x)
y <- paste0("Hello", x) # no space
print(y)

# print example from R documentation
print("Hello, world!")


# read.table example from R documentation
library(here)
file <- here('votes.csv')
votes <- read.table(file, sep = ',', header = TRUE)
print(votes)

votes2 <- read.csv(file) # quite simpler
print(votes2)
class(votes2)
str(votes2)
summary(votes2)
head(votes2)
tail(votes2)
dim(votes2)
nrow(votes2)
ncol(votes2)
names(votes2)
colnames(votes2)
rownames(votes2)

votes2[, 2] # second column
votes2[1, ] # first row
votes2[1, 2] # first row, second column
votes2$candidate # Candidate column
votes2$poll[1] # poll column first row
votes2$mail # Mail column
votes[1, 'poll'] # first row, poll column
sum(votes2$poll)
# Add a new column 'total' which is the sum of 'poll' and 'mail'
votes2$total <- votes2$poll + votes2$mail
votes2
# Write the modified data frame to a new CSV file
write.csv(votes2, here('votes_with_totals.csv'), row.names = FALSE)


#using url to read data from the web
url <- "https://github.com/fivethirtyeight/data/raw/master/non-voters/nonvoters_data.csv"

votes <- read.csv(url)
nrow(votes)
ncol(votes)
names(votes)
library(tidyverse)
glimpse(votes)
summary(votes)

votes$voter_category
unique(votes$voter_category) # unique values in voter_category column
table(votes$voter_category)
prop.table(table(votes$voter_category))


votes$Q22
unique(votes$Q22)
votes$Q21
table(votes$Q21)
prop.table(table(votes$Q21))

# Convert Q21 to a factor variable
factor(votes$Q21)
#Levels of Q21
factor(
  votes$Q21,
  labels = c("yes", "no", 'unsure/undecided'),
  exclude = c(-1)
)
