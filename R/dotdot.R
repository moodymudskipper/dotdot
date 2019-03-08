#' Enhanced assignment to overwrite or grow objects
#'
#' Use \code{..} on the right hand side as a shorthand for the left hand side
#'
#' \code{:=} is **NOT** meant to be a complete replacement of the `<-` operator,
#' it's meant to be explicit about growing an object or overwriting it using its
#' previous value, avoid repeating a variable
#' name, and saving keystrokes.
#'
#' It is slightly slower than the standard assignment operator
#' (though we're speaking microseconds). This should not distract the user from
#' the fact that growing an object is often inefficient, especially in a loop.
#'
#' \code{:=} can in principle be used several times in a statement like
#' \code{z <- (x := .. + 1) + (y:= .. +1)} but it never makes sense to use it
#' \code{:=} several times in an assignment such as \code{x := (y := .. + 2)}
#' as all the \code{..} will be replaced by the name of the variable on the lhs
#' of the first evaluated \code{:=} in any case.
#'
#' @param e1 left hand side
#' @param e2 right handside
#' @export
#' @examples
#' x <- 1
#' x := .. + 1
#' x
#'
#' x <- factor(letters[1:3])
#' levels(x) := c(.., "level4")
#' x
`:=` <- function(e1,e2) {
  mc <- match.call()
  mc[[1]] <- quote(.Primitive("<-"))
  mc[[3]] <- eval(substitute(
    substitute(e2, list(.. = mc[[2]])),list(e2 = mc[[3]])
  ))
  eval.parent(mc)
}

#' Make sure `:=` is unmasked
#'
#' This is not necessary to call this function after attaching
#' *rlang*/*tidyverse* or *data.table*
#'
#' @export
dotdot_first <- function(){
  detach("package:dotdot")
  library(dotdot, warn.conflicts = FALSE, quietly = TRUE )
}
