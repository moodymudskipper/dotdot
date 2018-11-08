<!-- README.md is generated from README.Rmd. Please edit that file -->
dotdot
======

This package contains 10 lines of code, it proposes an improved assignment using the shorthand `..`.

Think about the `..` as the `:` of the `:=` sign laid horizontally.

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

In case you've attached a package containing `:=` such as *`data.table`* or *`rlang`* you can use `dotdot_first()` to make sure that our `:=` is not masked, the operator will still work fine in *`data.table`* and *`rlang`* as they only use it for parsing but don't actually call it.

``` r
library(data.table)
#> 
#> Attaching package: 'data.table'
#> The following object is masked from 'package:dotdot':
#> 
#>     :=
try(levels(z) := c(.., "level5"))
dotdot_first()
#> 
#> Attaching package: 'dotdot'
#> The following object is masked from 'package:data.table':
#> 
#>     :=
levels(z) := c(.., "level5")
z
#> [1] a b c
#> Levels: a b c level4 level5
data <- as.data.table(head(iris))
data[,new_col := 3] # it still works!
data 
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species new_col
#> 1:          5.1         3.5          1.4         0.2  setosa       3
#> 2:          4.9         3.0          1.4         0.2  setosa       3
#> 3:          4.7         3.2          1.3         0.2  setosa       3
#> 4:          4.6         3.1          1.5         0.2  setosa       3
#> 5:          5.0         3.6          1.4         0.2  setosa       3
#> 6:          5.4         3.9          1.7         0.4  setosa       3
```
