
<!-- README.md is generated from README.Rmd. Please edit that file -->

# scorekeeper

<!-- badges: start -->
<!-- badges: end -->

A data cleaning package, by Katherine Schaumberg

The goal of scorekeeper is to support the development of accessible,
approachable, and reproducible scoring algorithms for multi-item
measures. This package was designed with psychological assessment
measures in mind, but can be broadly applicable to other multi-item
assessments. The package requires a raw data file and a scoresheet
(metadata file) as input. Scorekeeper uses dplyr functionality to
manipulate and clean data in a systematic way, as specified in the
scoresheet. The scoresheet can then serve as a resource that will make
your data cleaning process both reproducible and easily shared (e.g. if
a colleague would like to score a measure in the same way that you did
for their project on a different sample, you can send or post your
scoresheet and it should easily replicate your scoring algorithm – no
need to send or post additional code). While scoresheets are structured
to be more easily developed and interpreted as compared to raw code, I
also recommend a companion text file outlining each step in your data
cleaning to maximize ease of interpretation when sharing with others (or
your future self!). Currently, scoresheets must be formatted in
accordance with guidelines outlined in each of the ‘operation’ functions
and with steps that proceed in an appropriate order.

I recommend building a scoresheet step-by-step. Add one ‘step’ at a time
in your data manipulaton and complete error checking by running
functions in the scorekeeper package as you build the scoresheet.

***Necessary columns in a scoresheet include***:

**raw_vars** : a raw variable or list of raw variables needed for an
operation

**new_var**: the desired name of a new variable created during the
operation

**label**: the new variable label, if needed

**operation**: the operation to preform (`select`, `filter_at`,
`recode`, `sum`, `if_else`, `case_when`, `rename`)

**step**: identifies the order of operations to be preformed, starting
with ‘1’. I recommend entering any raw metadata as ‘0’ to increase
transparency of your scoring method when sharing a scoresheet

**val_labs**: value labels for a new variable

**new_vals**: values to be recoded in a `recode` operation. Follow the
convention ‘old’ = ‘new’, with commas separating each old/new pair

**if_condition**: a logical condition to be evaluated for an `if_else`
operation

**if_true_return**: value that is returned if the ‘if_condition’ == TRUE
in `if_else` operations

**else_return**: value that is returned if the ‘if_condition’ != TRUE in
`if_else` operations

**code**: code for performing a ‘filter_at’ or ‘case_when’ operation

The required columns in a scoresheet currently have limited flexibility.
I anticipate adding additional functionality in the future. Enter `NA`
for any elements that are unnecessary for a given operation. Current
operations supported are:

**select** : selects variables that you identify in
`scoresheet$raw_vars`.

**filter_at**: filters rows of a dataset. Use `filter_at` dplyr
conventions using `scoresheet$code`

**recode**: recodes a variable into a new variable, using values defined
in `scoresheet$new_vals`

**sum**: sums variables identified in `scoresheet$raw_vars`. Provides
weighted and unweighted sums, along with the number of and proportion of
`NA` values in the sum

**if_else** : creates a new variable defined in
`scoresheet$if_condition`, `scoresheet$if_true return`,
`soresheet$else_return`

**case_when** : creates a new variable using case_when code defined in
`scoresheet$code`

## Installation

Install scorekeeper from its GitHub repository. If you do not have the
remotes package installed, first install the remotes package.

``` r
install.packages("remotes")
```

then install R/scorekeeper using the install_github function in remotes.

``` r
library(remotes)
install_github("embark-lab/scorekeeper")
```