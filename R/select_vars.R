

#' Select Variables Using Metadata
#'
#' @param raw - raw data object
#' @param metadata - formatted metadata object
#' @return tibble with selected variables
#' @import dplyr
#' @import glue
#' @export
#'

select_vars <- function (raw, metadata){
  raw_data <- raw
  metadata <- metadata %>%
    filter (recode_operation_r == 'select')

#create a new tibble with just the raw data
  new_table2 <- tibble(raw_data)
  for (i in 1:nrow(metadata)){
  select_table <- select_function(raw_tbl = raw, r_vars = r_var_func (metadata, i)) }
#return the new table
  return(select_table) }

select_function <- function (raw_tbl, r_vars) {
  '{r_vars}' <- list (r_vars)
  raw_tbl <- raw_tbl %>%
    select(all_of(r_vars))
  return (raw_tbl) }

r_var_func <- function (metadata, i) {
  raw_vars <- as.list(el(strsplit(metadata$raw_vars_r[i], ",")))
  raw_vars <- trimws(raw_vars)
  return(raw_vars) }
