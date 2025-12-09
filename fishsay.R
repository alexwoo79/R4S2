fishsay <- function(phrase = "hello, world") {
  paste(
    phrase,
    " ____ ",
    "(o   \\",
    " \\   / ",
    "  \\ /  ",
    "  ( )  ",
    sep = "\n"
  )
}
cat(fishsay("Blub blub!"))
