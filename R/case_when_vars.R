


#this function picks out the variables that need case_when, then puts the function on a loop
#' case_when function
#'
#' @param raw a raw data object
#' @param scoresheet a properly formatted scoresheet object. Key columns that must have data for a case_when function are new_var and code. Code should be formatted in accordance with
#' dplyr case_when input. See [case_when](https://dplyr.tidyverse.org/reference/case_when.html)
#' @import dplyr
#' @import labelled
#' @import tibble
#' @importFrom rlang parse_expr
#' @importFrom methods el
#' @importFrom stats as.formula
#' @return  a tibble with new variables appended that follow tidyverse evaluation of case_when scoresheet statements
#' @export


case_when_vars <- function (raw, scoresheet){
  raw_data <- raw
  scoresheet <- scoresheet %>%
    filter (operation == 'case_when')

  #create a new tibble with just the raw data --we'll add columns with if_else alogrithm variables as we loop down below
  new_table2 <- tibble(raw_data)

  for (i in 1:nrow(scoresheet)){
    raw_var1 <- scoresheet$raw_vars[1]
    new_var <- scoresheet$new_var[i]
    new_label <- scoresheet$label[i]
    case_when_code <- scoresheet$code[i]


    case_when_table <- case_when_function(raw_tbl = raw, n_var = new_var, case_when_code = case_when_code, n_labs = n_val_lab_func(scoresheet, i), label = new_label)

    #save the last column and append to the 'new table'
    new_table1 <- case_when_table[,ncol(case_when_table)]
    new_table2 <- new_table2 %>%
      add_column(new_table1[1])
  }

  #return the new table
  return(new_table2)
}


#splits the left hand side (side to be evaluated), and right hand side (new value if true) of the case when list
case_when_function <- function (raw_tbl, n_var, case_when_code, n_labs, label) {
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
    mutate("{n_var}" := ifelse(NAs < LHS_len, rowSums(across(starts_with('temp')), na.rm = TRUE), NA)) %>%
    select(-starts_with('temp'))

  tbl_1 <- tbl_0 %>%
    mutate("{n_var}" := labelled(!!as.name(n_var), n_labs)) %>%
    set_variable_labels('{n_var}' := label)

  return(tbl_1)
}

case_when_code_func <- function(scoresheet, i) {
  case_when_code_1 <- scoresheet$code[i]
  case_when_code_2 <- as.character(eval(parse(text=paste('{case_when_code_1}'))))
  case_when_code_3 <- as.list(el(strsplit(case_when_code_2, ",")))
  case_when_code_4 <- lapply(case_when_code_3, as.formula)
  case_when_code_5 <- unlist(case_when_code_4)

  return(case_when_code_3) }

