

#' Select Variables Using scoresheet
#'
#' @param raw - raw data object
#' @param scoresheet - formatted scoresheet object. Key variables in this operation are `raw_vars`. The select operation currently takes a list of
#' `raw_vars` and selects those variables. Remember to select any necessary variables for identification of your data when scoring a measure
#' (so that you can later stitch tibbles back together for analysis if needed). Currently, you must enter the names of variables you would like
#' in a simple, comma separated list. You cannot use shorthand expressions (e.g. `starts_with` or `c(1:7)` will not work as input. Full variables
#' names are necessary. Additional flexibility for this function is planned for future releases
#' @return tibble with selected variables
#' @import dplyr
#' @import glue
#' @export
#'

select_vars <- function (raw, scoresheet){
  raw_data <- raw
  scoresheet <- scoresheet %>%
    filter (scoresheet$operation == 'select')

#create a new tibble with just the raw data
  new_table2 <- tibble(raw_data)
#for each select row, create a select_table -- note --- this currently doesn't loop
  for (i in 1:nrow(scoresheet)){
  select_table <- select_function(raw_tbl = raw, r_vars = r_var_func (scoresheet, i)) }
#return the new table
  return(select_table) }

select_function <- function (raw_tbl, r_vars) {
  '{r_vars}' <- list (r_vars)
  raw_tbl <- raw_tbl %>%
    select(all_of(r_vars))
  return (raw_tbl) }

r_var_func <- function (scoresheet, i) {
  raw_vars <- as.list(el(strsplit(scoresheet$raw_vars[i], ",")))
  raw_vars <- trimws(raw_vars)
  return(raw_vars) }
