A Scorekeeper Vignette
================

The following example depicts how to use the scoresheet package for
manipulating data and saving some scored data. This example will use 6
items used to assess binge eating behavior at age 14 in the Avon
Longitudinal Study of Parents and Children
[ALSPAC](http://www.bristol.ac.uk/alspac/). You can use load this
synthetic data and scoresheet in the package to test the example and
familiarize yourself with the package.

First, we load the scorekeeper package:

``` r
library(scorekeeper)
library(sjmisc)
#> 
#> Attaching package: 'sjmisc'
#> The following objects are masked from 'package:scorekeeper':
#> 
#>     add_case, is_empty, to_character, to_factor, trim
```

Next, let’s familiarize ourselves with the raw data. This example data
file includes an `id` variable, 6 binge eating variables (`ccq360`,
`ccq370`, `ccq371`, `ccq372`, `ccq373`, `ccq374`, and `ccq375`). I have
also included 4 ‘noisy’ variables which are related to other assessments
of eating behavior, `ccq380`, `ccq381`, `ccq382` and `ccq383`.

## Raw Data

| id | ccq360 | ccq370 | ccq371 | ccq372 | ccq373 | ccq374 | ccq375 | ccq380 | ccq381 | ccq382 | ccq383 |
| -: | -----: | -----: | -----: | -----: | -----: | -----: | -----: | -----: | -----: | -----: | -----: |
|  1 |      1 |     NA |     NA |     NA |     NA |     NA |     NA |     NA |     NA |     NA |     NA |
|  2 |      1 |      3 |      3 |      3 |      3 |      3 |      3 |      4 |     NA |     NA |     NA |
|  3 |      2 |      1 |      2 |      2 |      1 |      1 |      1 |      1 |      1 |      2 |      1 |
|  4 |     NA |     NA |     NA |     NA |     NA |     NA |     NA |     NA |     NA |     NA |     NA |
|  5 |      2 |      3 |      2 |      1 |      2 |      3 |      1 |      4 |     NA |     NA |     NA |
|  6 |      1 |     NA |     NA |     NA |     NA |     NA |     NA |     NA |     NA |     NA |     NA |

These variables are coded in ways that are slightly odd. For instance,
`ccq360` is not a descriptive name, and a response of ‘never’
corresponds to the value of 1.

``` r
frq(binge_raw$ccq370)
#> B13a/B12a: Respondent felt out of control when on a binge (x) <numeric> 
#> # total N=10 valid N=6 mean=2.17 sd=0.98
#> 
#> Value |                   Label | N | Raw % | Valid % | Cum. %
#> --------------------------------------------------------------
#> -9999 | Consent withdrawn by YP | 0 |     0 |    0.00 |   0.00
#>   -11 |    Triplet / quadruplet | 0 |     0 |    0.00 |   0.00
#>   -10 |           Not completed | 0 |     0 |    0.00 |   0.00
#>    -1 |             No response | 0 |     0 |    0.00 |   0.00
#>     1 |            Yes, usually | 2 |    20 |   33.33 |  33.33
#>     2 |          Yes, sometimes | 1 |    10 |   16.67 |  50.00
#>     3 |                      No | 3 |    30 |   50.00 | 100.00
#>  <NA> |                    <NA> | 4 |    40 |    <NA> |   <NA>
```

``` r
knitr::kable(head(binge_scoresheet[10,]), align = 'l', caption = 'Example row from binge_scoresheet')
```

| raw\_vars | new\_var       | label | operation | step | val\_labs | new\_vals | if\_condition | if\_true\_return | else\_return       | code |
| :-------- | :------------- | :---- | :-------- | :--- | :-------- | :-------- | :------------ | :--------------- | :----------------- | :--- |
| ccq371    | ccq371\_unskip | NA    | if\_else  | 2    | NA        | NA        | ccq360 == 1   | 3                | as.numeric(ccq371) | NA   |

Example row from binge\_scoresheet
