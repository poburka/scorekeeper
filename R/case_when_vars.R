


#this function picks out the variables that need case_when, then puts the function on a loop
#' Title
#'
#' @param raw raw data object
#' @param metadata formatted metadata object
#' @import dplyr
#' @import labelled
#' @import tibble
#' @import rlang
#' @return  a tibble with new variables appended that follow tidyverse evaluation of case_when metadata statements
#' @export


case_when_vars <- function (raw, metadata){
  raw_data <- raw
  metadata <- metadata %>%
    filter (recode_operation_r == 'case_when')

  #create a new tibble with just the raw data --we'll add columns with if_else alogrithm variables as we loop down below
  new_table2 <- tibble(raw_data)

  for (i in 1:nrow(metadata)){
    raw_var1 <- metadata$raw_vars_r[1]
    new_var <- metadata$recoded_var[i]
    new_label <- metadata$recode_label_r[i]
    case_when_code <- metadata$case_when_code[i]


    case_when_table <- case_when_function(raw_tbl = raw, n_var = new_var, case_when_code = case_when_code, n_val_lab = n_val_lab_func(metadata, i), n_lab = new_label)

    #save the last column and append to the 'new table'
    new_table1 <- case_when_table[,ncol(case_when_table)]
    new_table2 <- new_table2 %>%
      add_column(new_table1[1])
  }

  #return the new table
  return(new_table2)
}


case_when_function <- function (raw_tbl, n_var, case_when_code, n_lab, n_val_lab) {
  code <- as.list(el(strsplit(case_when_code, ",")))
  LHS <- lapply(code, function(x) sub("~.*", "",x))
  LHS <- trimws(unlist(LHS))
  RHS<- lapply(code, function(x) sub(".*~","",x))
  RHS <- trimws(unlist(RHS))
  tbl_0 <- raw_tbl
  LHS_len <- length(LHS)


  for (i in 1:LHS_len) {
    tbl_0 <- tbl_0 %>%
    mutate("temp{n_var}_{i}" := as.numeric(case_when((eval_tidy(rlang::parse_expr(LHS[i]))) ~ (!!RHS[i]),))) }

  tbl_0 <- tbl_0 %>%
    mutate(NAs := rowSums(is.na(across(starts_with('temp'))))) %>%
    mutate("{n_var}" := ifelse(NAs < 3, rowSums(across(starts_with('temp')), na.rm = TRUE), NA)) %>%
    select(-starts_with('temp'))

  tbl_0 <- tbl_0 %>%
    set_variable_labels(!!as.name(n_var):= n_lab) %>%
    mutate("{n_var}" := labelled(!!as.name(n_var), n_val_lab))

  return(tbl_0)
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

case_when_code_func <- function(metadata, i) {
  case_when_code_1 <- metadata$case_when_code[i]
  case_when_code_2 <- as.character(eval(parse(text=paste('{case_when_code_1}'))))
  case_when_code_3 <- as.list(el(strsplit(case_when_code_2, ",")))
  case_when_code_4 <- lapply(case_when_code_3, as.formula)
  case_when_code_5 <- unlist(case_when_code_4)

  return(case_when_code_3) }

