<!-- README.md is generated from README.Rmd. Please edit that file -->
dotdot
======

This package proposes an improved assignment using the shorthand `..`.

Think about the `..` as the `:` of the `:=` sign laid horizontally.

Install it with `devtools::install_github("moodymudskipper/dotdot")`

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

The operator `:=` is used by prominent packages *`data.table`* and *`rlang`* (mostly through *`tidyverse`* functions), but they only use it parse expressions, due to it's convenient operator precedence. It's not actually called.

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
data <- as.data.table(head(iris))
data[,new_col := 3] # `:= ` works as if dotdot wasn't attached
data 
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species new_col
#> 1:          5.1         3.5          1.4         0.2  setosa       3
#> 2:          4.9         3.0          1.4         0.2  setosa       3
#> 3:          4.7         3.2          1.3         0.2  setosa       3
#> 4:          4.6         3.1          1.5         0.2  setosa       3
#> 5:          5.0         3.6          1.4         0.2  setosa       3
#> 6:          5.4         3.9          1.7         0.4  setosa       3
```

In case you've attached another package containing `:=`, you can use `dotdot_first()` to make sure that our `:=` is not masked.
