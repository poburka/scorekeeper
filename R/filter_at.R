
#' filter_at_vars
#' `filter_at_vars` allows you to filter rows of a dataset based on values of specified columns
#'
#' @param raw a raw data object
#' @param scoresheet a scoresheet object. Key columns for the filter_at function are `code`. Code should include two arguments
#' separated by a comma. the first argument a numeric vector of column positions. *Note - this currently must be a numeric vector.
#' The second is a predicate function to be applied to the columns or a logical vector. Variables for which the predicate
#' returns true are selected. see dplyr for additional info. [filter_all](https://dplyr.tidyverse.org/reference/filter_all.html).
#' @import dplyr
#' @return tibble that is filtered at specific variables
#' @export
#'

filter_at_vars <- function (raw, scoresheet) {
  #from the scoresheet file - filter rows where the variables need to be renamed
  raw_data <-raw
  #filter rows of the scoresheet where the operation is 'recode'
  scoresheet1 <- scoresheet %>%
    filter (scoresheet$operation == 'filter_at')
#create empty tibbles -- one for each filter_at function in the step
i <- 1
m <- 2
x <- ((length(scoresheet1$step) + 1))
tibbles <- tibble_func_2(scoresheet1)
#populate the first empty tibble with the raw data
tibbles[[1]] <- raw_data

#iteratevely create the additional tibbles, using the first to create the second, second to create the third... and so forth
while (i < x) {
  code_for_fun <- scoresheet1$code[i]
  data_for_fun <- tibbles[[i]]
  tibbles[[m]] <- filter_at_fun(raw = data_for_fun, code = code_for_fun)
  i <- i+1
  m <- m+1}

#return the last tibble
return(tibbles[[x]]) }

tibble_func_2 <- function (meta) {
  empty_vec <- vector(mode = 'list', length = length(meta$step))
  tibbles <- purrr::map(empty_vec, tibble_func_1)
  return(tibbles) }

tibble_func_1 <- function(x) {
  y = as_tibble(x)
  return (y) }


filter_at_fun <- function (raw, code) {
  #create a raw data table from the raw data
  raw_data <- raw
  code <- code
  #specifies the left hand side of the filter_at code, which is the variables to be filtered on
  LHS <- gsub(",.*", "",code)
  LHS <- as_vector(str_eval(LHS))
  #specifies the left hand side of the filter_at code, which is the condition to be evaluated
  RHS<-  gsub(".*,","",code)
  RHS <- eval(parse(text = (RHS)))
  # a new table is created and the filter_at function is used to filter the table
  new_table2 <- tibble(raw_data)
  filter_table <- new_table2 %>%
    filter_at(LHS, RHS)
  #return the new table
  return (filter_table)}

str_eval<- function(x) {return(eval(parse(text=x)))}


