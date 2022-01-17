A Scorekeeper Vignette
================

The following example depicts how to use the scoresheet package for
manipulating data and saving some scored data. This example will use 7
items used to assess binge eating behavior at age 14 in the Avon
Longitudinal Study of Parents and Children
[ALSPAC](http://www.bristol.ac.uk/alspac/). You can use load this
synthetic data and scoresheet in the package to test the example and
familiarize yourself with the package. My goal is that building a
scoresheet should be an approachable and reproducible process, even for
R beginners. While all of this can be accomplished with some savvy dplyr
coding, the scoresheet format should harmonize the process, increase
approachabiity by reducing the need for heavy coding, allow for easy and
reproducable implementation of scoring practices across studies, and
offer a useful way to document and disseminate assessment scoring for
publication. This package assumes some *very basic* r knowledge
(i.e. how to start up r, load packages and data, assign variables, and
use basic computations). Some functions require some thoughtful coding,
and I try to make that process a bit more approachable via this
vignette. I recommend reading the dplyr documentation for an operation
if you are stuck on a particular piece of code.

Ok\! Let’s get started. First, we load the scorekeeper package:

``` r
library(scorekeeper)
```

    #> Install package "strengejacke" from GitHub (`devtools::install_github("strengejacke/strengejacke")`) to load all sj-packages at once!
    #> 
    #> Attaching package: 'sjmisc'
    #> The following objects are masked from 'package:scorekeeper':
    #> 
    #>     add_case, is_empty, to_character, to_factor, trim

Next, let’s familiarize ourselves with the raw data. This example data
file includes an `id` variable, 6 binge eating variables (`ccq360`,
`ccq370`, `ccq371`, `ccq372`, `ccq373`, `ccq374`, and `ccq375`). I have
also included 4 ‘noisy’ variables which are related to other assessments
of eating behavior, `ccq380`, `ccq381`, `ccq382` and `ccq383`.

## Raw Data

| id | ccq360 | ccq370 | ccq371 | ccq372 | ccq373 | ccq374 | ccq375 | ccq380 | ccq381 | ccq382 | ccq383 |
| -: | -----: | -----: | -----: | -----: | -----: | -----: | -----: | -----: | -----: | -----: | -----: |
|  1 |      1 |   \-10 |   \-10 |   \-10 |   \-10 |   \-10 |   \-10 |    \-1 |    \-1 |    \-1 |    \-1 |
|  2 |      2 |      3 |      3 |      3 |      3 |      3 |      3 |      1 |      1 |      1 |      1 |
|  3 |      2 |      1 |      2 |      2 |      1 |      1 |      1 |      1 |      1 |      2 |      1 |
|  4 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |
|  5 |      2 |      3 |      2 |      1 |      2 |      3 |      1 |      4 |      1 |      1 |      1 |
|  6 |      1 |   \-10 |   \-10 |   \-10 |   \-10 |   \-10 |   \-10 |      1 |      1 |      1 |      1 |
|  7 |      2 |      2 |      2 |      2 |      2 |      3 |      2 |      4 |      2 |      1 |      2 |
|  8 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |    \-1 |
|  9 |      4 |      3 |      2 |      2 |      3 |      3 |      2 |      1 |      2 |      1 |      4 |
| 10 |      2 |      1 |      3 |      3 |      2 |      3 |      2 |      1 |      1 |      1 |      1 |

As you can see from the examples below, these variables are coded in
ways that are slightly odd. For instance, `ccq360` is not a descriptive
name, and a response of ‘never’ corresponds to the value of 1. There are
also two missing data values currently coded as ‘no response’ that I’d
like to recode as `NA` for analysis.

``` r
frq(binge_raw$ccq360)
#> B12/B11: Frequency respondent went on an eating binge during the past year (x) <numeric> 
#> # total N=10 valid N=10 mean=1.40 sd=1.51
#> 
#> Value |                   Label | N | Raw % | Valid % | Cum. %
#> --------------------------------------------------------------
#> -9999 | Consent withdrawn by YP | 0 |     0 |       0 |      0
#>   -11 |    Triplet / quadruplet | 0 |     0 |       0 |      0
#>   -10 |           Not completed | 0 |     0 |       0 |      0
#>    -1 |             No response | 2 |    20 |      20 |     20
#>     1 |                   Never | 2 |    20 |      20 |     40
#>     2 |          < Once a month | 5 |    50 |      50 |     90
#>     3 |       1-3 times a month | 0 |     0 |       0 |     90
#>     4 |             Once a week | 1 |    10 |      10 |    100
#>     5 |            <Once a week | 0 |     0 |       0 |    100
#>  <NA> |                    <NA> | 0 |     0 |    <NA> |   <NA>
```

Similarly, you can see that `ccq370` has a ‘no’ answer coded as a 3,
with ‘yes, usually’ coded as 1 and ‘yes, sometimes’ coded as a 2. I also
see a different missing code pop up here, which is ‘not completed’. If I
look at the data (and the documentation) I notice that variables
ccq370-ccq375 were actually *skipped* if someone answered that they had
never binge eaten in question ccq360. I will also need to recode those
variables as ‘No’ instead of ‘not completed’ for those variables in
order to account for/fill in what the skip logic in the questionnaire
missed

    #> B13a/B12a: Respondent felt out of control when on a binge (x) <numeric> 
    #> # total N=10 valid N=10 mean=-0.90 sd=5.02
    #> 
    #> Value |                   Label | N | Raw % | Valid % | Cum. %
    #> --------------------------------------------------------------
    #> -9999 | Consent withdrawn by YP | 0 |     0 |       0 |      0
    #>   -11 |    Triplet / quadruplet | 0 |     0 |       0 |      0
    #>   -10 |           Not completed | 2 |    20 |      20 |     20
    #>    -1 |             No response | 2 |    20 |      20 |     40
    #>     1 |            Yes, usually | 2 |    20 |      20 |     60
    #>     2 |          Yes, sometimes | 1 |    10 |      10 |     70
    #>     3 |                      No | 3 |    30 |      30 |    100
    #>  <NA> |                    <NA> | 0 |     0 |    <NA> |   <NA>

So far, I have identified 4 things that I would like to do to clean
these variables prior to analysis:

**1**. select only `id`, `ccq370`, `ccq371`, `ccq372`, `ccq373`,
`ccq374`, and `ccq375` as the variables that I am interested in scoring.

**2**. appropriately account for skip patterns and change entries to
‘no’ for variables where a skip pattern was employed.

**3**. recode all negative numbers as ‘missing’; recode other responses
to be more sensible (e.g. for `ccq370`: 0 = No, 1 = Yes, sometimes, 2 =
Yes, usually, OR, if I want to dichotomize these symtpoms, perhaps 0 =
No and 1 = Yes - sometimes or usually).

**4**. rename the variables with more descriptive names.

## Scoresheet

Currently, your scoresheet should include up to 11 columns which must
have names that **exactly** match the following: `raw_vars`, `new_var`,
`label`, `operation`, `step`, `val_labs`, `new_vals`, `if_condition`,
`if_true_return`, `else_return`, `code`. Not all operations use all
columns, so if there is an operation you do not need, you may need fewer
columns in your scoresheet. Your scoresheet will still run if you leave
out unnecessary columns, but it will give an error if you do not include
columns that are needed.

**Step 0**: I’ll just document my raw variables of interest in Step 0,
so that anyone who is interested in replicating my scoring can verify
that their variables are coded as mine are. This will also give me a
starting point to refer back to if I would like to remember how the
original varialbes were coded before transformation. For example, see
the first three rows (out of 7 variables) below:

| raw\_vars | new\_var | label                                                                      | operation | step | val\_labs                                                                                                                                                                                     | new\_vals | if\_condition | if\_true\_return | else\_return | code |
| :-------- | :------- | :------------------------------------------------------------------------- | :-------- | ---: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------- | :------------ | :--------------- | :----------- | :--- |
| ccq360    | NA       | B12/B11: Frequency respondent went on an eating binge during the past year | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Never = 1, \< once a month = 2, 1-3 times a month = 3, once a week = 4, \> once a week = 5 | NA        | NA            | NA               | NA           | NA   |
| ccq370    | NA       | B13a/B12a: Respondent felt out of control when on a binge (ccq370)         | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Yes, usually = 1, Yes, sometimes = 2, No =3                                                | NA        | NA            | NA               | NA           | NA   |
| ccq371    | NA       | B13b/B12b: Respondent ate very fast or faster than normal when on a binge  | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Yes, usually = 1, Yes, sometimes = 2, No =3                                                | NA        | NA            | NA               | NA           | NA   |

**Step 1**: I’m going to enter a row in a scoresheet (I use a .csv file
with my 11 columns for easy entry and revision, then load it into r
using `load_csv`). To select only the variables that I want, I add a row
to my scoresheet with `operation` = select and `step` = 1:

| raw\_vars                                                  | new\_var | label | operation | step | val\_labs | new\_vals | if\_condition | if\_true\_return | else\_return | code |
| :--------------------------------------------------------- | :------- | :---- | :-------- | ---: | :-------- | :-------- | :------------ | :--------------- | :----------- | :--- |
| id, ccq360, ccq370, ccq371, ccq372, ccq373, ccq374, ccq375 | NA       | NA    | select    |    1 | NA        | NA        | NA            | NA               | NA           | NA   |

Ok\! Now for our first test. I’m going to use this row to see if I can
select my variables of interest using the scorekeeper package.

``` r
#select1 creates a scoreshet tibble with only the 8th row - which contains my 'select' operation that I would like to do in Step 1
select1 <- binge_scoresheet[8,]
#complete the 'scorekeep' function using my raw data and select 1
scorekeep(binge_raw, select1)
#> [[1]]
#> # A tibble: 10 × 8
#>       id    ccq360     ccq370     ccq371    ccq372    ccq373    ccq374    ccq375
#>    <dbl> <dbl+lbl>  <dbl+lbl>  <dbl+lbl> <dbl+lbl> <dbl+lbl> <dbl+lbl> <dbl+lbl>
#>  1     1  1 [Neve… -10 [Not … -10 [Not … -10 [Not… -10 [Not… -10 [Not… -10 [Not…
#>  2     2  2 [< On…   3 [No]     3 [No]     3 [No]    3 [No]    3 [No]    3 [No] 
#>  3     3  2 [< On…   1 [Yes,…   2 [Yes,…   2 [Yes…   1 [Yes…   1 [Yes…   1 [Yes…
#>  4     4 -1 [No r…  -1 [No r…  -1 [No r…  -1 [No …  -1 [No …  -1 [No …  -1 [No …
#>  5     5  2 [< On…   3 [No]     2 [Yes,…   1 [Yes…   2 [Yes…   3 [No]    1 [Yes…
#>  6     6  1 [Neve… -10 [Not … -10 [Not … -10 [Not… -10 [Not… -10 [Not… -10 [Not…
#>  7     7  2 [< On…   2 [Yes,…   2 [Yes,…   2 [Yes…   2 [Yes…   3 [No]    2 [Yes…
#>  8     8 -1 [No r…  -1 [No r…  -1 [No r…  -1 [No …  -1 [No …  -1 [No …  -1 [No …
#>  9     9  4 [Once…   3 [No]     2 [Yes,…   2 [Yes…   3 [No]    3 [No]    2 [Yes…
#> 10    10  2 [< On…   1 [Yes,…   3 [No]     3 [No]    2 [Yes…   3 [No]    2 [Yes…
```

Great\! now the next
