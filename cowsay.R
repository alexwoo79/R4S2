cowsay <- function(phrase = "hello, world") {
  paste(
    phrase,
    "^__^",
    "(oo)\\_______",
    "(__)\\       )\\/\\",
    sep = "\n"
  )
}
cat(cowsay("Moo!"))
