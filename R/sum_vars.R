

#' Sum variables using scoresheet
#'
#' @param raw A raw data object
#' @param scoresheet A formatted scoresheet object
#' @import dplyr
#' @import glue
#' @return raw tibble with four additional columns appended:
#' `{n_var}` : a column which is the sum of items - NAs are treated as '0' values
#' `{n_var}_complete` : a column with the sum of items -- rows that contain any NA values return NA
#' `{n_var}_NAs` : a column with the count of NAs among items contributing to the sum
#' `{n_var}_NA_percent` : a column with the percentage of NAs among the variables contributing to the sum
#' `{n_var}_weighted_sum` : a column with a sum weighted by the number of items contributing to the sum
#' @export
#'


sum_vars <- function (raw, scoresheet){
  raw_data <- raw
  scoresheet <- scoresheet %>%
    filter (scoresheet$operation == 'sum')

  #create a new tibble with just the raw data --we'll add columns with sum scores as we loop down below
  new_table2 <- tibble(raw_data)

  for (i in 1:nrow(scoresheet)){
    new_var <- scoresheet$new_var[i]
    raw_var <-  scoresheet$raw_vars[i]
    new_label <- scoresheet$label[i]

    sum_table <- sum_function(raw_tbl = raw, n_var = new_var, r_vars = r_var_func(scoresheet, i), n_lab = new_label)

    #save the last 4 columns (the new sum column, the NAs column, the NA percent column, and the weighted sum column), and append to the 'new table'
    new_table1 <- sum_table[,(ncol(sum_table)-4):ncol(sum_table)]

    new_table2 <- new_table2 %>%
      add_column(new_table1[1], new_table1[2], new_table1[3], new_table1[4], new_table1[5]) %>%
      mutate_all(~replace(., is.nan(.), NA))
  }

  #return the new table
  return(new_table2)
}


#The sum function takes a raw table and several variables from the scoresheet. n_var is the new variable name, r_vars are the raw variables to be summed, and n_lab is the is the variable label for the new summed variable
sum_function <- function (raw_tbl, n_var, r_vars, n_lab) {
    n_lab_completers = paste({{n_lab}}, ' - completers only')
    n_lab_NAs = paste({{n_lab}}, '- number of NAs')
    n_lab_weighted_sum = paste({{n_lab}}, ' - weighted sum')
    n_lab_NA_percent = paste({{n_lab}}, '- percent NAs')
  new_tbl <-raw_tbl %>%
    #create a new variable that sums across the raw variables
    mutate("{n_var}" := rowSums(across(r_vars), na.rm = TRUE)) %>%
    mutate("{n_var}_complete" := rowSums(across(r_vars), na.rm = FALSE)) %>%
    #label the new variable
    set_variable_labels("{n_var}" := n_lab) %>%
    set_variable_labels("{n_var}_complete" := n_lab_completers) %>%
    #create a new variable that tells you -- across the raw variables, the number that are missing
    mutate("{n_var}_NAs" := rowSums(is.na(across(r_vars))))  %>%
    set_variable_labels("{n_var}_NAs" := n_lab_NAs) %>%
    #create a new variable that tells you -- across the raw variables that are summed, the percent that are missing
    mutate("{n_var}_NA_percent" := ((rowSums(is.na(across(r_vars))))/(length(r_vars))*100)) %>%
    set_variable_labels("{n_var}_NA_percent" := n_lab_NA_percent) %>%
    #create a new variable that is your weighted sum score
    mutate ("{n_var}_weighted_sum" := ((rowSums(across(r_vars), na.rm = TRUE))/(1-(((rowSums(is.na(across(r_vars))))/(length(r_vars))))))) %>%
    set_variable_labels("{n_var}_weighted_sum" := n_lab_weighted_sum) %>%
  return(new_tbl)
}



