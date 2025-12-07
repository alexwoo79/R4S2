# This is third of five R scripts for the CS50 Applying Functions module.
# This script demonstrates how to apply functions to data structures in R.

# Demonstrates counting votes for 3 different candidates

# mario <- as.integer(readline("Mario: "))
# peach <- as.integer(readline("Peach: "))
# bowser <- as.integer(readline("Bowser: "))

# total <- sum(mario, peach, bowser)
# cat("Total votes:", total)

# make get_votes function
# get_votes <- function(candidate) {
#   votes <- as.integer(readline(paste(candidate, ": ")))
#   return(votes)
# }

# if type of input is not integer, ask again
# get_votes <- function(candidate) {
#   votes <- as.integer(readline(paste(candidate, ": ")))
#   if (is.na(votes)) {
#     cat("Please enter a valid integer.\n")
#     return(0)
#   } else {
#     return(votes)
#   }
# }

#use ifesle
# get_votes <- function(candidate) {
#   votes <- as.integer(readline(paste(candidate, ": ")))
#   ifelse(is.na(votes), 0, votes)
# }

#ignore the warning messages for NA values
# get_votes <- function(candidate) {
#   votes <- suppressWarnings(as.integer(readline(paste(candidate, ": "))))
#   ifelse(is.na(votes), 0, votes)
# }

# using repeat loop to ensure valid integer input
# get_votes <- function(candidate) {
#   repeat {
#     votes <- suppressWarnings(as.integer(readline(paste(candidate, ": "))))
#     if (!is.na(votes)) {
#       break
#     }
#   }
#   return(votes)
# }

# cancel break using return
get_votes <- function(candidate) {
  repeat {
    votes <- suppressWarnings(as.integer(readline(paste(candidate, ": "))))
    if (!is.na(votes)) {
      return(votes) #return also can exit the loop
    }
  }
}

# use get_votes function to get votes for each candidate
# mario_votes <- get_votes("Mario")
# peach_votes <- get_votes("Peach")
# bowser_votes <- get_votes("Bowser")
# total_votes <- sum(mario_votes, peach_votes, bowser_votes)
# cat("Total votes:", total_votes, "\n")

#using for loop to iterate over candidates

total <- 0
for (candidate in c("Mario", "Peach", "Bowser")) {
  votes <- get_votes(candidate)
  total <- total + votes
}
cat("Total votes:", total, "\n")


# LOOPS repeat,while ,for

cat("quack!\n")
cat("quack!\n")
cat("quack!\n")

# using repeat loop infinitely until break

i <- 3
repeat {
  cat("quack!\n")
  i <- i - 1
  if (i == 0) {
    break
  }
  # } else {
  #   next
  # }
  # break
}

# using while loop
i <- 3
while (i > 0) {
  cat("quack!\n")
  i <- i - 1
}

# Demonstrates a while loop, counting up

i <- 1
while (i <= 3) {
  cat("quack!\n")
  i <- i + 1
}

# using for loop
# for (i in 1:3) {
#   cat("quack!\n")
# }

for (i in 1:3) {
  cat("quack!\n")
}


# Demonstrates a for loop iterating over a vector
# Demonstrates summing votes for each candidate procedurally

votes <- read.csv(here("votes.csv"), row.names = 1) # row.names=1 to set first column as row names

total_votes <- c()
# for (candidate in rownames(votes)) {
#   total_votes[candidate] <- sum(votes[candidate, ])
# }
# for (method in colnames(votes)) {
#   total_votes[method] <- sum(votes[, method])
# }

for (conditate in rownames(votes)) {
  total_votes <- c(total_votes, sum(votes[conditate, ]))
}
total_votes

#use apply function MARGIN=1 for rows, MARGIN=2 for columns
total_votes <- apply(votes, MARGIN = 1, FUN = sum)

total_votes

total_votes_col <- apply(votes, MARGIN = 2, FUN = sum)

total_votes_col
