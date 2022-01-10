

#' Select Variables Using scoresheet
#'
#' @param raw - raw data object
#' @param scoresheet - formatted scoresheet object
#' @return tibble with selected variables
#' @import dplyr
#' @import glue
#' @export
#'

select_vars <- function (raw, scoresheet){
  raw_data <- raw
  scoresheet <- scoresheet %>%
    filter (operation == 'select')

#create a new tibble with just the raw data
  new_table2 <- tibble(raw_data)
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
