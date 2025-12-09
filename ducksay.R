ducksay <- function(phrase = "hello, world") {
  paste(
    phrase,
    ">(. )__",
    " (____/",
    sep = "\n"
  )
}
cat(ducksay("嘎嘎!"))
