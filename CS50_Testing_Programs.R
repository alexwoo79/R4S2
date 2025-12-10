# Testing programs for CS50 course
# Fix ordering of error handling

average <- function(x) {
  if (any(is.na(x))) {
    warning("`x` contains one or more NA values.")
    return(NA)
  }
  if (!is.numeric(x)) {
    stop("`x` must be a numeric vector.")
  }
  sum(x) / length(x)
}


# Test cases
# print(average(c(1, 2, 3))) # Should return 2
# print(average(c(1, 2, NA))) # Should give a warning and

# print(average(c("a", "b", "c"))) # Should give an error

# usting testthat checks for error handling
library(testthat)
test_that("`average` calculates mean", {
  expect_equal(average(c(1, 2, 3)), 2)
  expect_equal(average(c(-1, -2, -3)), -2)
  expect_equal(average(c(-1, 0, 1)), 0)
  expect_equal(average(c(-2, -1, 1, 2)), 0)
  expect_equal(average(c(0.1, 0.5)), 0.3)
})

test_that("`average` returns NA with NAs in input", {
  expect_equal(suppressWarnings(average(c(1, NA, 3))), NA)
  expect_equal(suppressWarnings(average(c(NA, NA, NA))), NA)
})

test_that("`average` warns about NAs in input", {
  expect_warning(average(c(1, NA, 3)))
  expect_warning(average(c(NA, NA, NA)))
})

test_that("`average` stops if `x` is non-numeric", {
  expect_error(average(c("quack!")))
  expect_error(average(c("1", "2", "3")))
})


# Demonstrates floating-point imprecision

print(0.3)
print(0.3, digits = 17)


# using describe it from the desc package
# Provides default argument value

greet <- function(to = "world") {
  return(paste("hello,", to))
}
# Test cases
print(greet()) # Should return "hello, world"
print(greet("Alice")) # Should return "hello, Alice"

# using testthat to check the greet function
test_that("`greet` function works correctly", {
  expect_equal(greet(), "hello, world")
  expect_equal(greet("Alice"), "hello, Alice")
  expect_equal(greet("Bob"), "hello, Bob")
})


#describe function use it helpers from desc package
library(desc)
describe("greet function", {
  it("returns default greeting when no argument is provided", {
    expect_equal(greet(), "hello, world")
  })

  it("returns personalized greeting when a name is provided", {
    expect_equal(greet("Alice"), "hello, Alice")
    expect_equal(greet("Bob"), "hello, Bob")
  })
})
