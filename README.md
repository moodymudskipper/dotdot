<!-- README.md is generated from README.Rmd. Please edit that file -->
dotdot
======

Installation :

``` r
devtools::install_github("moodymudskipper/dotdot")
#> Downloading GitHub repo moodymudskipper/dotdot@master
#> from URL https://api.github.com/repos/moodymudskipper/dotdot/zipball/master
#> Installing dotdot
#> "C:/PROGRA~1/R/R-35~1.1/bin/x64/R" --no-site-file --no-environ --no-save  \
#>   --no-restore --quiet CMD INSTALL  \
#>   "C:/Users/Antoine/AppData/Local/Temp/RtmpwrkuN4/devtools32ec1cc169d/moodymudskipper-dotdot-0bbf116"  \
#>   --library="C:/Users/Antoine/Documents/R/win-library/3.5"  \
#>   --install-tests
#> 
```

This package proposes an improved assignment using the shorthand `..`.

``` r
library(dotdot)
x <- y <- iris
x$Sepal.Length[5] <- x$Sepal.Length[5] + 3
y$Sepal.Length[5] := .. + 3
identical(x,y)
#> [1] TRUE

z <- factor(letters[1:3])
levels(z) := c(.., "level4")
z
#> [1] a b c
#> Levels: a b c level4
```

You can think about the `..` as the `:` of the `:=` symbol laid horizontally.

Integration with *`data.table`*, *`tidyverse`* and other packages using `:=`
----------------------------------------------------------------------------

The operator `:=` is used by prominent packages *`data.table`* and *`rlang`* (mostly through *`tidyverse`* functions), but they only use it to parse expressions, due to its convenient operator precedence. It's not actually called.

Thus *`dotdot`* is completely *`tidyverse`* and *`data.table`* compatible, and some adhoc adjustments were made so it even works when the latter are attached after *`dotdot`*.

``` r
library(data.table)
#> 
#> Attaching package: 'data.table'
#> The following object is masked _by_ 'package:dotdot':
#> 
#>     :=
levels(z) := c(.., "level5")
z
#> [1] a b c
#> Levels: a b c level4 level5
data <- as.data.table(head(iris,2))
data[,new_col := 3] # `:= ` works as if dotdot wasn't attached
data 
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species new_col
#> 1:          5.1         3.5          1.4         0.2  setosa       3
#> 2:          4.9         3.0          1.4         0.2  setosa       3
```

An example of fine integration of the operator being used by *`dotdot`* and *`rlang`* through *`dplyr`*

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:data.table':
#> 
#>     between, first, last
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
my_data_frame <- iris[3:5]
var = quo(Log.Petal.Width)
my_data_frame := .. %>% mutate(!!var := log(Petal.Width)) %>% head(2)
my_data_frame
#>   Petal.Length Petal.Width Species Log.Petal.Width
#> 1          1.4         0.2  setosa       -1.609438
#> 2          1.4         0.2  setosa       -1.609438
```

In case you've attached another package containing `:=`, you can use `dotdot_first()` to make sure that our `:=` is not masked (It seems to be rare enough though as I couldn't find an example)

Comparison with magrittr's `%<>%`
---------------------------------

The package *`magrittr`* contains the operator `%<>%` which serves a similar role to `:=`. Let's see how it is similar first, and then how it differs :

These calls have the same effect:

``` r
iris$Sepal.Length %<>% log
iris$Sepal.Length %<>% log(.)
iris$Sepal.Length := log(..)
```

Those as well, but here we see *`magrittr`* is less compact and readable.

``` r
iris$Sepal.Length[5] %<>% multiply_by(2) %>% add(3)
iris$Sepal.Length[5] %<>% {2*. + 3}
iris$Sepal.Length[5] := 2*.. + 3
```

Now for the differences, aside from compacity and readability :

-   attaching *`magrittr`* means often masking functions likes `extract` or `set_names`. *`dotdot`* only exports its operator and the `dotdot_first` function.
-   *`magrittr`* operators deal with environment in a way that is much less straightforward, so this won't work :

``` r
library(magrittr)
test <- function(some_parameter) {
  some_parameter %<>% {as.character(substitute(.))}
  some_parameter
  }
x <- try(test(foo))
inherits(x,"try-error")
#> [1] TRUE
```

While this will work fine:

``` r
test <- function(some_parameter) {
  some_parameter := as.character(substitute(..))
  some_parameter
  }
test(foo)
#> [1] "foo"
```

-   `:=` is also faster than `%<>%` , though these operations are fast anyway and not likely to be a bottleneck very often if ever:

``` r
 b <- x <- y <- z <- 1
 microbenchmark::microbenchmark(
   base      = {b <- b + 1},
   dotdot    = {x := .. + 1},
   magrittr  = {y %<>% add(1)},
   magrittr2 = {z %<>% {. + 1}},
   times = 1e4
)
#> Unit: nanoseconds
#>       expr   min    lq     mean median    uq     max neval
#>       base   200   400   503.68    400   500   33100 10000
#>     dotdot 10100 12000 16047.96  12900 13800 3781000 10000
#>   magrittr 61800 64400 76422.06  65800 68500 3643400 10000
#>  magrittr2 46300 48400 58700.53  49500 51500 5002100 10000
```

Edge cases and good practice
----------------------------

`:=` is **NOT** meant to be a complete replacement of the `<-` operator, the latter is explicit in the absence of `..` , so more readable, is faster (though we're speaking microseconds), and won't clutter your `traceback()` when debugging.

`:=` can be used several times in a statement like `z <- (x := .. + 1) + (y:= .. +1)` but it never makes sense to use it `:=` several times in an assignment such as `x := (y := .. + 2)` as all the `..` will be replaced by the name of the variable on the lhs of the first evaluated `:=` in any case. It can even produce counter intuitive output, see below.

This is all good and explicit :

    x <- 4
    y <- 7
    z <- (x := .. + 1) + (y:= .. +1)
    x
    y
    z

But using several nested `:=` is unuseful and potentially confusing, here the dots will be replaced by `x`, though one might have expected them to be replaced by `y`.

    x <- 4
    y <- 7
    x := (y := .. + 2) # same as `x <- (y := x + 2)` 
    x
    y

Good practice makes things unambiguous :

    x <- 4
    y <- 7
    x <- (y := .. + 2)
    x
    y

    x <- 4
    y <- 7
    x := (y <- .. + 2)
    x
    y
