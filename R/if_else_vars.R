
#this function picks out the variables that need if_else, then puts the function on a loop
#' Title
#'
#' @param raw Raw data object
#' @param metadata Formatted metadata object
#' @import dplyr
#' @import labelled
#' @import tibble
#' @import rlang
#' @return a tibble with new variables appended that follow tidyverse evaluation of if_else metadata statements
#' @export
#'

if_else_vars <- function (raw, metadata){
  raw_data <- raw
  metadata <- metadata %>%
    filter (recode_operation_r == 'if_else')


  #create a new tibble with just the raw data --we'll add columns with if_else alogrithm variables as we loop down below
  new_table2 <- tibble(raw_data)

  for (i in 1:nrow(metadata)){
    new_var <- metadata$recoded_var[i]
    raw_var <-  metadata$raw_vars_r[i]
    new_label <- metadata$recode_label_r[i]
    if_condition <- metadata$if_condition [i]
    if_true_return <- metadata$if_true_return[i]
    else_return <- metadata$else_return[i]


    if_else_table <- if_else_function(raw_tbl = raw_data, n_var = new_var, if_cond = if_condition, if_true_r = if_true_return, else_r = else_return, n_val_lab = n_val_lab_func(metadata, i), n_lab = new_label)

    #save the last column and append to the 'new table'
    new_table1 <- if_else_table[,ncol(if_else_table)]
    new_table2 <- new_table2 %>%
      add_column(new_table1[1])
  }

  #return the new table
  return(new_table2)
}


if_else_function <- function (raw_tbl, n_var, if_cond, if_true_r, else_r, n_lab, n_val_lab) {
  new_tbl <-raw_tbl %>%
    #create a new variable that sums across the raw variables
    mutate("{n_var}" := if_else( (eval_tidy(rlang::parse_expr(if_cond))), eval(parse(text = if_true_r)), eval(parse(text = else_r)), missing = NULL )) %>%
    #label the new variable
    set_variable_labels(!!as.name(n_var) := n_lab)
  #if there are value labels - set the new value labels
  new_tbl <- new_tbl %>%
    mutate("{n_var}" := labelled(!!as.name(n_var), n_val_lab))
  return(new_tbl)
}


n_val_lab_func <- function (metadata, i) {
  if (!is.na(metadata$new_labs_r[i]))
  {val_lab_names <- as.list(el(strsplit(metadata$new_labs_r[i], ",")))
  new_val_labs <- as.list(el(strsplit(metadata$new_labs_r[i], ",")))
  val_lab_names <- lapply(new_val_labs, function(x) sub("=.*", "", x))
  val_lab_names <- trimws(unlist(val_lab_names))
  n_val_labs<- lapply(new_val_labs, function(x) sub(".*=","",x))
  n_val_labs<- lapply(n_val_labs, function(x)as.numeric(x))
  n_val_lab <- unlist(n_val_labs)
  names(n_val_lab) <-val_lab_names}
  else n_val_lab <- NA
  return(n_val_lab)
}

