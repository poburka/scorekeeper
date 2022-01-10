

#' Filter at function
#'
#' @param raw a raw data object
#' @param scoresheet a scoresheet object
#' @import dplyr
#' @return tibble that is filtered at specific variables
#' @export
#'

filter_at_vars <- function (raw, scoresheet) {

  raw_data <- raw
  meta1 <- scoresheet %>%
    filter (recode_operation_r == 'filter_at')
  code <- meta1$code[1]
  LHS <- gsub(",.*", "",code)
  LHS <- as_vector(str_eval(LHS))
  RHS<-  gsub(".*,","",code)
  RHS <- eval(parse(text = (RHS)))


  new_table2 <- tibble(raw_data)
  filter_table <- new_table2 %>%
    filter_at(LHS, RHS)
  #return the new table
  return (filter_table)}


str_eval<- function(x) {return(eval(parse(text=x)))}
