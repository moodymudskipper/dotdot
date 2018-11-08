#' Enhanced assignment
#'
#' Use \code{..} on the right hand side as a shorthand for the left hand side
#'
#' @export
#' @examples
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
#' @export
dotdot_first <- function(){
  detach("package:dotdot")
  library(dotdot)
}
