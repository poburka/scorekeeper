A Scorekeeper Vignette
================

The following example depicts how to use the scoresheet package for
manipulating data and saving some scored data. This example will use 7
items used to assess binge eating behavior at age 14 in the Avon
Longitudinal Study of Parents and Children
[(ALSPAC)](http://www.bristol.ac.uk/alspac/). You can use load this
synthetic data and scoresheet in the package to test the example and
familiarize yourself with the package. Building a scoresheet should be
an approachable and reproducible process, even for R beginners. While
all of this can be accomplished (in some cases more efficiently) with
some savvy dplyr coding, the scoresheet format should harmonize the
process, increase approachabiity by reducing the need for heavy coding,
allow for straightforward and reproducible implementation of scoring
practices across studies, and offer a useful way to document and
disseminate assessment scoring for publication. This package assumes
some *basic* r knowledge (i.e. how to start up r, load packages and
data, assign variables, and use basic computations). Some functions
require a minimum of thoughtful coding, and I try to make that process a
bit less painful via this vignette. I recommend reading the [dplyr
documentation](https://dplyr.tidyverse.org) as well as the [scorekeeper
documentation](https://embark-lab.github.io/scorekeeper/reference/index.html)
for a specific operation if you are stuck on a particular piece of code.

Ok! Let’s get started. First, we load the scorekeeper package:

``` r
library(scorekeeper)
```

Next, let’s familiarize ourselves with the raw data. This example data
file includes an `id` variable, 7 binge eating variables (`ccq360`,
`ccq370`, `ccq371`, `ccq372`, `ccq373`, `ccq374`, and `ccq375`). I have
also included 4 ‘noisy’ variables which are related to other assessments
of eating behavior, `ccq380`, `ccq381`, `ccq382` and `ccq383`.

## Raw Data

|  id | ccq360 | ccq370 | ccq371 | ccq372 | ccq373 | ccq374 | ccq375 | ccq380 | ccq381 | ccq382 | ccq383 |
|----:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|
|   1 |      1 |    -10 |    -10 |    -10 |    -10 |    -10 |    -10 |     -1 |     -1 |     -1 |     -1 |
|   2 |      2 |      3 |      3 |      3 |      3 |      3 |      3 |      1 |      1 |      1 |      1 |
|   3 |      2 |      1 |      2 |      2 |      1 |      1 |      1 |      1 |      1 |      2 |      1 |
|   4 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |
|   5 |      2 |      3 |      2 |      1 |      2 |      3 |      1 |      4 |      1 |      1 |      1 |
|   6 |      1 |    -10 |    -10 |    -10 |    -10 |    -10 |    -10 |      1 |      1 |      1 |      1 |
|   7 |      2 |      2 |      2 |      2 |      2 |      3 |      2 |      4 |      2 |      1 |      2 |
|   8 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |
|   9 |      4 |      3 |      2 |      2 |      3 |      3 |      2 |      1 |      2 |      1 |      4 |
|  10 |      2 |      1 |      3 |      3 |      2 |      3 |      2 |      1 |      1 |      1 |      1 |

As you can see from the examples below, these variables are coded in
ways that are slightly odd. For instance, `ccq360` is not a descriptive
name, and a response of ‘never’ corresponds to the value of 1. There are
also two missing data values currently coded as ‘no response’ that I’d
like to recode as `NA` for analysis.

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

Similarly, you can see that `ccq370` has a ‘no’ answer coded as a 3,
with ‘yes, usually’ coded as 1 and ‘yes, sometimes’ coded as a 2. I also
see a different missing code pop up here, which is ‘not completed’. If I
look at the data patterns and the documentation, I notice that variables
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

## Scoresheet

When preparing to make a scoresheet - I split my thought process into
three chunks (1) cleaning raw variables, (2) creating composite scores,
and (3) selecting your final, cleaned variables to save. We’ll start
with the first chunk below:

I have identified 4 things that I would like to do to clean raw
variables prior to analysis:

**1**. Select only `id`, `ccq360`, `ccq370`, `ccq371`, `ccq372`,
`ccq373`, `ccq374`, and `ccq375` as the variables that I am interested
in scoring.

**2**. Appropriately account for skip patterns and change entries to
‘no’ for variables where a skip pattern was employed.

**3**. Recode all negative numbers as ‘missing’; recode other responses
to be more sensible (e.g. for `ccq370`: 0 = No, 1 = Yes, sometimes, 2 =
Yes, usually for an ordinal variable AND/OR 0 = No and 1 = Yes -
sometimes or usually for a dichotomized variable).

**4**. Rename variables with more descriptive names. Clean up variable
labels

Thinking about the order that these will need to be completed: I can do
the `select` operation at any point, but it makes sense to do it first
in order to reduce clutter in my data as I manipulate it. I can complete
the unskipping (`if_else`) and `recode` in either order, but the VALUE
that is entered for skipped variables would be different if I completed
this before vs. after the recode, as a ‘No’ answer would have a
different value before vs. after recoding. It seems most sensible to me
to start with filling out the skipped variables, so I will do that step
first before recoding. Finally, I would like to rename the variables to
be more descriptive names and clean up the variable labels a bit. This
renaming and cleaning up labels can be accomplished within the recode
step, so I have 3 steps to complete in order to clean my raw variables.

At present, scoresheets should include up to 11 columns which must have
names that **exactly** match the following: `raw_vars`, `new_var`,
`label`, `operation`, `step`, `val_labs`, `new_vals`, `if_condition`,
`if_true_return`, `else_return`, `code`. Not all operations use all
columns, so if there is an operation you do not need, you may not need
all columns in your scoresheet. Your scoresheet will run regardless of
whether your include unnecessary columns, but it will give an error if
you do not include columns that are necessary.

Steps 0-3 (below) represent this first chunk of data cleaning -
preparing the raw variables:

## Step 0

I’ll just document my raw variables of interest in Step 0, so that
anyone who is interested in replicating my scoring can verify that their
variables are coded as mine are. This will also give me a starting point
to refer back to if I would like to remember how the original varialbes
were coded before transformation. For example, see the first three rows
of raw variables below:

| raw_vars | new_var | label                                                                      | operation | step | val_labs                                                                                                                                                                                      | new_vals | if_condition | if_true_return | else_return | code |
|:---------|:--------|:---------------------------------------------------------------------------|:----------|-----:|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------|:-------------|:---------------|:------------|:-----|
| ccq360   | NA      | B12/B11: Frequency respondent went on an eating binge during the past year | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Never = 1, \< once a month = 2, 1-3 times a month = 3, once a week = 4, \> once a week = 5 | NA       | NA           | NA             | NA          | NA   |
| ccq370   | NA      | B13a/B12a: Respondent felt out of control when on a binge (ccq370)         | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Yes, usually = 1, Yes, sometimes = 2, No =3                                                | NA       | NA           | NA             | NA          | NA   |
| ccq371   | NA      | B13b/B12b: Respondent ate very fast or faster than normal when on a binge  | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Yes, usually = 1, Yes, sometimes = 2, No =3                                                | NA       | NA           | NA             | NA          | NA   |

## Step 1

I’m going to enter a row in a scoresheet (I use a .csv file in generic
spreadsheet software for easy entry and revision, then load it into r
using `load_csv`, make more minor edits, then save your working/final
scoresheet as an RData file and/or export as .csv).

To select only the variables that I want, I add a row to my scoresheet
with `operation` = select and `step` = 1. In the ‘raw_vars’ column, I
list the variables that I would like to select in a comma separated
charachter string. Any time there is a list of variables for input, they
can be in one of two formats - a single, comma separated character
string, or a vector of character strings.

*note - currently the select operation only works with each element in a
scoresheet fully listed. It is not able to accommodate tidyselect
actions*

| raw_vars                                                   | new_var | label | operation | step | val_labs | new_vals | if_condition | if_true_return | else_return | code |
|:-----------------------------------------------------------|:--------|:------|:----------|-----:|:---------|:---------|:-------------|:---------------|:------------|:-----|
| id, ccq360, ccq370, ccq371, ccq372, ccq373, ccq374, ccq375 | NA      | NA    | select    |    1 | NA       | NA       | NA           | NA             | NA          | NA   |

Now I’ll use this row to select my variables of interest using the
scorekeep function, with my raw data file (`binge_raw`) and scoresheet
that contains Steps 0-1 (`score1`):

``` r
knitr::kable (scorekeep(binge_raw, score1))
```

|  id | ccq360 | ccq370 | ccq371 | ccq372 | ccq373 | ccq374 | ccq375 |
|----:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|
|   1 |      1 |    -10 |    -10 |    -10 |    -10 |    -10 |    -10 |
|   2 |      2 |      3 |      3 |      3 |      3 |      3 |      3 |
|   3 |      2 |      1 |      2 |      2 |      1 |      1 |      1 |
|   4 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |
|   5 |      2 |      3 |      2 |      1 |      2 |      3 |      1 |
|   6 |      1 |    -10 |    -10 |    -10 |    -10 |    -10 |    -10 |
|   7 |      2 |      2 |      2 |      2 |      2 |      3 |      2 |
|   8 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |
|   9 |      4 |      3 |      2 |      2 |      3 |      3 |      2 |
|  10 |      2 |      1 |      3 |      3 |      2 |      3 |      2 |

## Step 2

We now have only the 8 variables that we would like to use. Our next
step will be to ‘unskip’ the currently skipped variables. To do this,
I’m going to use `if_else` code (see package documentation for
additional details). For each row column ccq370-375, I will create a new
variable with ’\_unskip’ appended to the end of each variable. For
example, if `ccq370` == 1, I’ll change the value of the skipped variable
to 3; otherwise, I’ll keep the original value. See below for example of
this code which creates a new variable ‘ccq370_unskip’:

*note - the if_else operation is currently designed to recode one
variable per row. Vectorization may be available in future releases*

| raw_vars | new_var       | label | operation | step | val_labs | new_vals | if_condition | if_true_return | else_return        | code |
|:---------|:--------------|:------|:----------|-----:|:---------|:---------|:-------------|:---------------|:-------------------|:-----|
| ccq370   | ccq370_unskip | NA    | if_else   |    2 | NA       | NA       | ccq360 == 1  | 3              | as.numeric(ccq370) | NA   |

Now we’ll expand our scoring to Steps 1-2

``` r
#complete the `scorekeep` function using my raw data and the first two scoresheet steps:
knitr::kable (scorekeep(binge_raw, score2))
```

|  id | ccq360 | ccq370 | ccq371 | ccq372 | ccq373 | ccq374 | ccq375 |
|----:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|
|   1 |      1 |    -10 |    -10 |    -10 |    -10 |    -10 |    -10 |
|   2 |      2 |      3 |      3 |      3 |      3 |      3 |      3 |
|   3 |      2 |      1 |      2 |      2 |      1 |      1 |      1 |
|   4 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |
|   5 |      2 |      3 |      2 |      1 |      2 |      3 |      1 |
|   6 |      1 |    -10 |    -10 |    -10 |    -10 |    -10 |    -10 |
|   7 |      2 |      2 |      2 |      2 |      2 |      3 |      2 |
|   8 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |
|   9 |      4 |      3 |      2 |      2 |      3 |      3 |      2 |
|  10 |      2 |      1 |      3 |      3 |      2 |      3 |      2 |

|  id | ccq360 | ccq370 | ccq371 | ccq372 | ccq373 | ccq374 | ccq375 | ccq370_unskip | ccq371_unskip | ccq372_unskip | ccq373_unskip | ccq374_unskip | ccq375_unskip |
|----:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|--------------:|--------------:|--------------:|--------------:|--------------:|--------------:|
|   1 |      1 |    -10 |    -10 |    -10 |    -10 |    -10 |    -10 |             3 |             3 |             3 |             3 |             3 |             3 |
|   2 |      2 |      3 |      3 |      3 |      3 |      3 |      3 |             3 |             3 |             3 |             3 |             3 |             3 |
|   3 |      2 |      1 |      2 |      2 |      1 |      1 |      1 |             1 |             2 |             2 |             1 |             1 |             1 |
|   4 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |            -1 |            -1 |            -1 |            -1 |            -1 |            -1 |
|   5 |      2 |      3 |      2 |      1 |      2 |      3 |      1 |             3 |             2 |             1 |             2 |             3 |             1 |
|   6 |      1 |    -10 |    -10 |    -10 |    -10 |    -10 |    -10 |             3 |             3 |             3 |             3 |             3 |             3 |
|   7 |      2 |      2 |      2 |      2 |      2 |      3 |      2 |             2 |             2 |             2 |             2 |             3 |             2 |
|   8 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |            -1 |            -1 |            -1 |            -1 |            -1 |            -1 |
|   9 |      4 |      3 |      2 |      2 |      3 |      3 |      2 |             3 |             2 |             2 |             3 |             3 |             2 |
|  10 |      2 |      1 |      3 |      3 |      2 |      3 |      2 |             1 |             3 |             3 |             2 |             3 |             2 |

You’ll see that we now have **2** tibbles in our output, one for each
step. The first step selects the variables, and the second step corrects
the skip logic.

*Note - the scorekeeper package is designed to be very conservative in
variable conservation. What this means is that original variables are
never discarded, and output tibbles will generally lengthen as you
create new variables. There are two operations where this is not the
case. First, the `select` function will reduce columns in a tibble by
selecting only those that are identified. Second, the `rename` function
renames a column in a tibble directly. All other operations will
generally require a ‘new_var’ name that is NOT yet a named variable and
will append the newly created variable to the end of a tibble. You can
always select your final variables and rename them back to an original
name as a final step in the scorekeeping process if you prefer the
original name of a variable but need to make modifications to the data.*

## Step 3

Now we’re ready for **Step 3**, recoding and renaming. Below is an
example of what a scoresheet row will look like for this operation

| raw_vars      | new_var        | label                                                 | operation | step | val_labs                               | new_vals                     | if_condition | if_true_return | else_return | code |
|:--------------|:---------------|:------------------------------------------------------|:----------|-----:|:---------------------------------------|:-----------------------------|:-------------|:---------------|:------------|:-----|
| ccq370_unskip | binge_loc_d.14 | Eating binges felt out of control - present or absent | recode    |    3 | no = 0, yes - sometimes or usually = 1 | 1 = 1, 2 = 1, 3 = 0, -1 = NA | NA           | NA             | NA          | NA   |

I am using the newly minted `ccq370_unskip` variable when recoding. I
rename the variable something more sensible `binge_loc_d.14` - which
notes that it’s a binge eating variable assessing loss of control,
dichotomized, assessed at age 14. I edited the label just a bit as well.
The new value labels are coded as ‘label’ = ‘value’, and the new values
recode the old values under the pattern ‘old’ = ‘new’, with commas
separating each element in the recoding scheme. Recoded variables will
also include a companion variable ‘new_var.factor’, which includes the
value label easily visible, so that you can double check that your
recoding scheme is correct.

*Note - do not use commas within the value labels (e.g. ‘yes, sometimes
or usually’ includes a comma and would not parse as an accurate value.
Other punctuation may be used within value labels)*

Beginning with this step, I’m only going to show the parts of output for
readability – as noted above, the scorekeep function scores iteratively
and **saves each step** as a tibble in your output so that you can
ensure that the correct transformations were made on each step and
troubleshoot if necessary.

|  id | ccq360 | ccq370 | ccq371 | ccq372 | ccq373 | ccq374 | ccq375 | ccq370_unskip | ccq371_unskip | ccq372_unskip | ccq373_unskip | ccq374_unskip | ccq375_unskip | binge_freq_d.14 | binge_freq_d.14.factor | binge_loc_d.14 | binge_loc_d.14.factor      | binge_fast_d.14 | binge_fast_d.14.factor     | binge_stomach_d.14 | binge_stomach_d.14.factor  | binge_large_d.14 | binge_large_d.14.factor    | binge_hide_d.14 | binge_hide_d.14.factor     | binge_guilt_d.14 | binge_guilt_d.14.factor    |
|----:|-------:|-------:|-------:|-------:|-------:|-------:|-------:|--------------:|--------------:|--------------:|--------------:|--------------:|--------------:|----------------:|:-----------------------|---------------:|:---------------------------|----------------:|:---------------------------|-------------------:|:---------------------------|-----------------:|:---------------------------|----------------:|:---------------------------|-----------------:|:---------------------------|
|   1 |      1 |    -10 |    -10 |    -10 |    -10 |    -10 |    -10 |             3 |             3 |             3 |             3 |             3 |             3 |               0 | \<1x/mo; absent        |              0 | no                         |               0 | no                         |                  0 | no                         |                0 | no                         |               0 | no                         |                0 | no                         |
|   2 |      2 |      3 |      3 |      3 |      3 |      3 |      3 |             3 |             3 |             3 |             3 |             3 |             3 |               0 | \<1x/mo; absent        |              0 | no                         |               0 | no                         |                  0 | no                         |                0 | no                         |               0 | no                         |                0 | no                         |
|   3 |      2 |      1 |      2 |      2 |      1 |      1 |      1 |             1 |             2 |             2 |             1 |             1 |             1 |               0 | \<1x/mo; absent        |              1 | yes - sometimes or usually |               1 | yes - sometimes or usually |                  1 | yes - sometimes or usually |                1 | yes - sometimes or usually |               1 | yes - sometimes or usually |                1 | yes - sometimes or usually |
|   4 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |            -1 |            -1 |            -1 |            -1 |            -1 |            -1 |              NA | NA                     |             NA | NA                         |              NA | NA                         |                 NA | NA                         |               NA | NA                         |              NA | NA                         |               NA | NA                         |
|   5 |      2 |      3 |      2 |      1 |      2 |      3 |      1 |             3 |             2 |             1 |             2 |             3 |             1 |               0 | \<1x/mo; absent        |              0 | no                         |               1 | yes - sometimes or usually |                  1 | yes - sometimes or usually |                1 | yes - sometimes or usually |               0 | no                         |                1 | yes - sometimes or usually |
|   6 |      1 |    -10 |    -10 |    -10 |    -10 |    -10 |    -10 |             3 |             3 |             3 |             3 |             3 |             3 |               0 | \<1x/mo; absent        |              0 | no                         |               0 | no                         |                  0 | no                         |                0 | no                         |               0 | no                         |                0 | no                         |
|   7 |      2 |      2 |      2 |      2 |      2 |      3 |      2 |             2 |             2 |             2 |             2 |             3 |             2 |               0 | \<1x/mo; absent        |              1 | yes - sometimes or usually |               1 | yes - sometimes or usually |                  1 | yes - sometimes or usually |                1 | yes - sometimes or usually |               0 | no                         |                1 | yes - sometimes or usually |
|   8 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |     -1 |            -1 |            -1 |            -1 |            -1 |            -1 |            -1 |              NA | NA                     |             NA | NA                         |              NA | NA                         |                 NA | NA                         |               NA | NA                         |              NA | NA                         |               NA | NA                         |
|   9 |      4 |      3 |      2 |      2 |      3 |      3 |      2 |             3 |             2 |             2 |             3 |             3 |             2 |               1 | 1x/mo or more; present |              0 | no                         |               1 | yes - sometimes or usually |                  1 | yes - sometimes or usually |                0 | no                         |               0 | no                         |                1 | yes - sometimes or usually |
|  10 |      2 |      1 |      3 |      3 |      2 |      3 |      2 |             1 |             3 |             3 |             2 |             3 |             2 |               0 | \<1x/mo; absent        |              1 | yes - sometimes or usually |               0 | no                         |                  0 | no                         |                1 | yes - sometimes or usually |               0 | no                         |                1 | yes - sometimes or usually |

This concludes the first chunk of data cleaning - recoding the raw
variables – in this example. Our variables binge_freq_d.14 through the
end of the tibble now represent appropriately coded (dichotomized)
variables for our analysis. For the second chunk of data cleaning, we’ll
create composite scores. The composite scores that I have decided to
create are a sum of symptoms that are present: `binge_sx_sum.14`, a
variable that dichotomizes binge eating issues as present if individuals
report binge at least once per month with at least two of the six
additional symptoms, and a variable that splits the sum score into
categories of absent, mild, and severe. We’ll need to first create the
sum score before we can complete the next two operations.

## Step 4

Our next step will be to create a sum score. Below is the scoresheet row
to create our symptom sum score, which gives a count of the number of
binge eating symptoms (0-6) that are present for each individual

| raw_vars                                                                                                 | new_var         | label                               | operation | step | val_labs | new_vals | if_condition | if_true_return | else_return | code |
|:---------------------------------------------------------------------------------------------------------|:----------------|:------------------------------------|:----------|-----:|:---------|:---------|:-------------|:---------------|:------------|:-----|
| binge_loc_d.14, binge_fast_d.14, binge_stomach_d.14, binge_large_d.14, binge_hide_d.14, binge_guilt_d.14 | binge_sx_sum.14 | Sum of binge eating symtpoms Age 14 | sum       |    4 | NA       | NA       | NA           | NA             | NA          | NA   |

The sum operation computes five variables, the raw sum of the list of
variables provided in `raw_vars` (NAs excluded), the raw sum of those
with complete data only, the number of missing values, the percent of
values that are missing, and a weighted sum (weighted by the number of
non-missing values). Below are the last 5 columns of the tibble created
in Step 4:

| binge_sx_sum.14 | binge_sx_sum.14_complete | binge_sx_sum.14_NAs | binge_sx_sum.14_NA_percent | binge_sx_sum.14_weighted_sum |
|----------------:|-------------------------:|--------------------:|---------------------------:|-----------------------------:|
|               0 |                        0 |                   0 |                          0 |                            0 |
|               0 |                        0 |                   0 |                          0 |                            0 |
|               6 |                        6 |                   0 |                          0 |                            6 |
|               0 |                       NA |                   6 |                        100 |                           NA |
|               4 |                        4 |                   0 |                          0 |                            4 |
|               0 |                        0 |                   0 |                          0 |                            0 |
|               5 |                        5 |                   0 |                          0 |                            5 |
|               0 |                       NA |                   6 |                        100 |                           NA |
|               3 |                        3 |                   0 |                          0 |                            3 |
|               3 |                        3 |                   0 |                          0 |                            3 |

## Step 5

In step 5, we create two additional variables based on the sum score
created in step 4, and we filter the tibble to exclude cases with all
missing data. We can do all of these operations in the same step because
they are independent and do not rely on one another. The `if_else`
operation computes a variable that notes binge eating is present (‘1’)
if an individual reports binge eating at least once per month with more
than two additional symptoms. The `case_when` operation splits the sum
score into ‘absent’, ‘mild’, and ‘severe’ cases based on the number of
symtpoms reported. See `if_else`, `filter_at` and `case_when`
documentation in the package help files for more information.

| raw_vars                         | new_var               | label                                              | operation | step | val_labs                         | new_vals | if_condition                                | if_true_return | else_return | code                                                                                                   |
|:---------------------------------|:----------------------|:---------------------------------------------------|:----------|-----:|:---------------------------------|:---------|:--------------------------------------------|:---------------|:------------|:-------------------------------------------------------------------------------------------------------|
| binge_sx_sum.14, binge_freq_d.14 | binge_present.14      | binge eating present and more than 2 symptoms      | if_else   |    5 | present = 1, absent = 0          | NA       | binge_freq_d.14 == 1 & binge_sx_sum.14 \> 2 | 1              | 0           | NA                                                                                                     |
| binge_sx_sum.14                  | binge_sx_sum_split.14 | Binge symptoms sum split into absent, mild, severe | case_when |    5 | absent = 0, mild = 1, severe = 2 | NA       | NA                                          | NA             | NA          | binge_sx_sum.14 == 0 \~ 0, binge_sx_sum.14 \> 0 & binge_sx_sum.14 \<=3 \~ 1, binge_sx_sum.14 \> 3 \~ 2 |
| NA                               | NA                    | NA                                                 | filter_at |    5 | NA                               | NA       | NA                                          | NA             | NA          | c(15:28), any_vars(!is.na(.))                                                                          |

The last two variables created are seen below:

| binge_present.14 | binge_sx_sum_split.14 |
|-----------------:|----------------------:|
|                0 |                     0 |
|                0 |                     0 |
|                0 |                     2 |
|                0 |                     0 |
|                0 |                     2 |
|                0 |                     0 |
|                0 |                     2 |
|                0 |                     0 |
|                1 |                     1 |
|                0 |                     1 |

## Steps 6-7

Now we’ve created the final composite scores. In our final chunk, we’ll
clean up the dataset. In step 6, we select only a few columns that will
go into the final dataset, and in step 7, we rename
`binge_sx_sum_split.14` to a simpler name: `binge_severity.14`

| raw_vars                                                                                                                                                                                | new_var           | label | operation | step | val_labs | new_vals | if_condition | if_true_return | else_return | code |
|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------|:------|:----------|-----:|:---------|:---------|:-------------|:---------------|:------------|:-----|
| id, binge_freq_d.14, binge_loc_d.14, binge_fast_d.14, binge_stomach_d.14, binge_large_d.14, binge_hide_d.14, binge_guilt_d.14, binge_present.14, binge_sx_sum.14, binge_sx_sum_split.14 | NA                | NA    | select    |    6 | NA       | NA       | NA           | NA             | NA          | NA   |
| binge_sx_sum_split.14                                                                                                                                                                   | binge_severity.14 | NA    | rename    |    7 | NA       | NA       | NA           | NA             | NA          | NA   |

## The Final Reveal

Putting it all together: we now have a full scoresheet -

| raw_vars                                                                                                                                                                                | new_var               | label                                                                                              | operation | step | val_labs                                                                                                                                                                                      | new_vals                                  | if_condition                                | if_true_return | else_return        | code                                                                                                   |
|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------|:---------------------------------------------------------------------------------------------------|:----------|-----:|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------|:--------------------------------------------|:---------------|:-------------------|:-------------------------------------------------------------------------------------------------------|
| ccq360                                                                                                                                                                                  | NA                    | B12/B11: Frequency respondent went on an eating binge during the past year                         | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Never = 1, \< once a month = 2, 1-3 times a month = 3, once a week = 4, \> once a week = 5 | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq370                                                                                                                                                                                  | NA                    | B13a/B12a: Respondent felt out of control when on a binge (ccq370)                                 | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Yes, usually = 1, Yes, sometimes = 2, No =3                                                | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq371                                                                                                                                                                                  | NA                    | B13b/B12b: Respondent ate very fast or faster than normal when on a binge                          | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Yes, usually = 1, Yes, sometimes = 2, No =3                                                | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq372                                                                                                                                                                                  | NA                    | B13c/B12c: Respondent ate until their stomach hurt or they felt sick when on a binge               | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Yes, usually = 1, Yes, sometimes = 2, No =3                                                | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq373                                                                                                                                                                                  | NA                    | B13d/B12d: Respondent ate really large amounts of food when not hungry when on a binge (ccq373)    | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Yes, usually = 1, Yes, sometimes = 2, No =3                                                | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq374                                                                                                                                                                                  | NA                    | B13e/B12e: Respondent ate by themselves to hide amount eaten when on a binge (ccq374)              | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Yes, usually = 1, Yes, sometimes = 2, No =3                                                | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq375                                                                                                                                                                                  | NA                    | B13f/B12f: Respondent felt really bad / guilty after eating a lot of food when on a binge (ccq375) | raw       |    0 | consent withrdrawn by YP = -9999, triplet/quadruplet = -11, Not completed = -10, No response = -1, Yes, usually = 1, Yes, sometimes = 2, No =3                                                | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |
| id, ccq360, ccq370, ccq371, ccq372, ccq373, ccq374, ccq375                                                                                                                              | NA                    | NA                                                                                                 | select    |    1 | NA                                                                                                                                                                                            | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq370                                                                                                                                                                                  | ccq370_unskip         | NA                                                                                                 | if_else   |    2 | NA                                                                                                                                                                                            | NA                                        | ccq360 == 1                                 | 3              | as.numeric(ccq370) | NA                                                                                                     |
| ccq371                                                                                                                                                                                  | ccq371_unskip         | NA                                                                                                 | if_else   |    2 | NA                                                                                                                                                                                            | NA                                        | ccq360 == 1                                 | 3              | as.numeric(ccq371) | NA                                                                                                     |
| ccq372                                                                                                                                                                                  | ccq372_unskip         | NA                                                                                                 | if_else   |    2 | NA                                                                                                                                                                                            | NA                                        | ccq360 == 1                                 | 3              | as.numeric(ccq372) | NA                                                                                                     |
| ccq373                                                                                                                                                                                  | ccq373_unskip         | NA                                                                                                 | if_else   |    2 | NA                                                                                                                                                                                            | NA                                        | ccq360 == 1                                 | 3              | as.numeric(ccq373) | NA                                                                                                     |
| ccq374                                                                                                                                                                                  | ccq374_unskip         | NA                                                                                                 | if_else   |    2 | NA                                                                                                                                                                                            | NA                                        | ccq360 == 1                                 | 3              | as.numeric(ccq374) | NA                                                                                                     |
| ccq375                                                                                                                                                                                  | ccq375_unskip         | NA                                                                                                 | if_else   |    2 | NA                                                                                                                                                                                            | NA                                        | ccq360 == 1                                 | 3              | as.numeric(ccq375) | NA                                                                                                     |
| ccq360                                                                                                                                                                                  | binge_freq_d.14       | Eating binges (eating a large amount of food) present or absent in the past year’                  | recode    |    3 | \<1x/mo; absent = 0, 1x/mo or more; present = 1                                                                                                                                               | 1 = 0, 2= 0, 3 = 1, 4 = 1, 5 = 1, -1 = NA | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq370_unskip                                                                                                                                                                           | binge_loc_d.14        | Eating binges felt out of control - present or absent                                              | recode    |    3 | no = 0, yes - sometimes or usually = 1                                                                                                                                                        | 1 = 1, 2 = 1, 3 = 0, -1 = NA              | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq371_unskip                                                                                                                                                                           | binge_fast_d.14       | Eating Very fast or faster than normal when on a binge - present or absent                         | recode    |    3 | no = 0, yes - sometimes or usually = 1                                                                                                                                                        | 1 = 1, 2 = 1, 3 = 0, -1 = NA              | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq372_unskip                                                                                                                                                                           | binge_stomach_d.14    | Eating until Stomach hurt or felt sick - present or absent                                         | recode    |    3 | no = 0, yes - sometimes or usually = 1                                                                                                                                                        | 1 = 1, 2 = 1, 3 = 0, -1 = NA              | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq373_unskip                                                                                                                                                                           | binge_large_d.14      | Eating large amounts of food when not hungry - present or absent                                   | recode    |    3 | no = 0, yes - sometimes or usually = 1                                                                                                                                                        | 1 = 1, 2 = 1, 3 = 0, -1 = NA              | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq374_unskip                                                                                                                                                                           | binge_hide_d.14       | Hiding amount eaten when on a binge - present or absent                                            | recode    |    3 | no = 0, yes - sometimes or usually = 1                                                                                                                                                        | 1 = 1, 2 = 1, 3 = 0, -1 = NA              | NA                                          | NA             | NA                 | NA                                                                                                     |
| ccq375_unskip                                                                                                                                                                           | binge_guilt_d.14      | Feeling bad or guilty after a binge - present or absent                                            | recode    |    3 | no = 0, yes - sometimes or usually = 1                                                                                                                                                        | 1 = 1, 2 = 1, 3 = 0, -1 = NA              | NA                                          | NA             | NA                 | NA                                                                                                     |
| binge_loc_d.14, binge_fast_d.14, binge_stomach_d.14, binge_large_d.14, binge_hide_d.14, binge_guilt_d.14                                                                                | binge_sx_sum.14       | Sum of binge eating symtpoms Age 14                                                                | sum       |    4 | NA                                                                                                                                                                                            | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |
| binge_sx_sum.14, binge_freq_d.14                                                                                                                                                        | binge_present.14      | binge eating present and more than 2 symptoms                                                      | if_else   |    5 | present = 1, absent = 0                                                                                                                                                                       | NA                                        | binge_freq_d.14 == 1 & binge_sx_sum.14 \> 2 | 1              | 0                  | NA                                                                                                     |
| binge_sx_sum.14                                                                                                                                                                         | binge_sx_sum_split.14 | Binge symptoms sum split into absent, mild, severe                                                 | case_when |    5 | absent = 0, mild = 1, severe = 2                                                                                                                                                              | NA                                        | NA                                          | NA             | NA                 | binge_sx_sum.14 == 0 \~ 0, binge_sx_sum.14 \> 0 & binge_sx_sum.14 \<=3 \~ 1, binge_sx_sum.14 \> 3 \~ 2 |
| NA                                                                                                                                                                                      | NA                    | NA                                                                                                 | filter_at |    5 | NA                                                                                                                                                                                            | NA                                        | NA                                          | NA             | NA                 | c(15:28), any_vars(!is.na(.))                                                                          |
| id, binge_freq_d.14, binge_loc_d.14, binge_fast_d.14, binge_stomach_d.14, binge_large_d.14, binge_hide_d.14, binge_guilt_d.14, binge_present.14, binge_sx_sum.14, binge_sx_sum_split.14 | NA                    | NA                                                                                                 | select    |    6 | NA                                                                                                                                                                                            | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |
| binge_sx_sum_split.14                                                                                                                                                                   | binge_severity.14     | NA                                                                                                 | rename    |    7 | NA                                                                                                                                                                                            | NA                                        | NA                                          | NA             | NA                 | NA                                                                                                     |

And we can use that scoresheet to fully score our binge eating measure
with just **one line of code**:

``` r
cleaned_data <-  scorekeep(binge_raw, binge_scoresheet)
```

The last tibble in this set of 7 tibbles will be the fully cleaned data

|  id | binge_freq_d.14 | binge_loc_d.14 | binge_fast_d.14 | binge_stomach_d.14 | binge_large_d.14 | binge_hide_d.14 | binge_guilt_d.14 | binge_present.14 | binge_sx_sum.14 | binge_severity.14 |
|----:|----------------:|---------------:|----------------:|-------------------:|-----------------:|----------------:|-----------------:|-----------------:|----------------:|------------------:|
|   1 |               0 |              0 |               0 |                  0 |                0 |               0 |                0 |                0 |               0 |                 0 |
|   2 |               0 |              0 |               0 |                  0 |                0 |               0 |                0 |                0 |               0 |                 0 |
|   3 |               0 |              1 |               1 |                  1 |                1 |               1 |                1 |                0 |               6 |                 2 |
|   5 |               0 |              0 |               1 |                  1 |                1 |               0 |                1 |                0 |               4 |                 2 |
|   6 |               0 |              0 |               0 |                  0 |                0 |               0 |                0 |                0 |               0 |                 0 |
|   7 |               0 |              1 |               1 |                  1 |                1 |               0 |                1 |                0 |               5 |                 2 |
|   9 |               1 |              0 |               1 |                  1 |                0 |               0 |                1 |                1 |               3 |                 1 |
|  10 |               0 |              1 |               0 |                  0 |                1 |               0 |                1 |                0 |               3 |                 1 |

And we can start to analyze our cleaned variables, which I can then
save, export, and connect with other data files :)

    #> Binge symptoms sum split into absent, mild, severe (x) <numeric> 
    #> # total N=8 valid N=8 mean=1.00 sd=0.93
    #> 
    #> Value |  Label | N | Raw % | Valid % | Cum. %
    #> ---------------------------------------------
    #>     0 | absent | 3 | 37.50 |   37.50 |  37.50
    #>     1 |   mild | 2 | 25.00 |   25.00 |  62.50
    #>     2 | severe | 3 | 37.50 |   37.50 | 100.00
    #>  <NA> |   <NA> | 0 |  0.00 |    <NA> |   <NA>

While developing this initial scoresheet was somewhat labor intensive,
the scoresheet creates a **documented, reproducible scoring and data
cleaning system** that can be easily shared. For instance, if another
individual has data on the same measure, they can use my scoresheet
(which I can save to a .csv file and post/send) to clean and score their
data in the exact same way that I did, using **one line of code**. If
raw variables are named slightly differently across projects, I would
only need to adjust the raw variable names in a few places in the
scoresheet for it to work on new data. While the scorekeeper package can
be used for any multi-item scoring tasks, it shines for algorithmic
tasks (i.e. deriving psychological diagnoses), which often involve
multiple `if_else` or `case_when` statements.

**Happy scoring!**
