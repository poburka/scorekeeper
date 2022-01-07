

#' The recode_vars function recodes variables according to metadata instructions
#'
#' @param raw : A raw data object (tibble or dataframe)
#' @param metadata  : A metadata object (tibble or dataframe)
#' @import dplyr
#' @import labelled
#' @import haven
#' @import tibble
#' @return A tibble with both original and recoded varaibles
#' @export
#'
#'

recode_vars <- function (raw, metadata){

  #from the metadata file - filter rows where the variables need to be recoded
  raw_data <-raw
  #create a new, empty tibble with just the id numbers
  new_table2 <- tibble(raw_data)
  #filter rows of the metadata where the operation is 'recode'
  metadata <- metadata %>%
    filter (recode_operation_r == 'recode')
  #loop through the recode function, using the arguments defined frp, the metadata file and using the functions above
  for (i in 1:nrow(metadata)){
    new_var <- metadata$recoded_var[i]
    raw_var <- metadata$raw_vars_r[i]
    new_label <- metadata$recode_label_r[i]

    new_table <- recode_function(raw_tbl = raw, n_var = new_var, r_var = raw_var, n_val = n_val_func(metadata,i), n_val_lab = n_val_lab_func(metadata,i), n_lab = new_label, n_var_factor = n_var_factor_func(metadata,i))
  #save the last two columns (the new named variable and the '.factor' variable as columns in the new table at each loop)
    new_table1 <- new_table[,(ncol(new_table)-1):ncol(new_table)]
    new_table2 <- new_table2 %>%
      add_column(new_table1[1], new_table1[2])
  }
#close the loop  - return the new table
  return(new_table2)
}


#define function to recode using variables that will be read in from metadata. This is the primary function that will recode the data and be put on loop down each row of the metadata. This function takes a raw data table (raw_tbl), a new variable name (n_var) and raw variable name (r_var), new value assignments (n_val) and new value labels (n_val_lab), the new varaible label (n_lab), and a second new variable name that will be the 'factor' variable where the variable labels will be presented instead of variable values in each row (n_var_factor).

recode_function <- function (raw_tbl, n_var, r_var, n_val, n_val_lab, n_lab, n_var_factor) {
  raw_tbl <-raw_tbl %>%
    #make a new variable using the new variable name, recode the old variable using the new value assignments. get rid of the old value labels that are now incorrect
    mutate("{n_var}" := recode(!!as.name(r_var), !!!n_val, .keep_value_labels = FALSE)) %>%
    #relabel values in accordance with the new, correct variable labels
    mutate("{n_var}" := labelled(!!as.name(n_var), n_val_lab)) %>%
    #label the new variable
    set_variable_labels("{n_var}" := n_lab) %>%
    #create the factor variable by using the 'as_factor' function on the new variable"
    mutate("{n_var_factor}" := as_factor(!!as.name(n_var), ordered = TRUE)) %>%
    #label the factor variable using the same label
    set_variable_labels("{n_var_factor}" := n_lab)
  #return the raw table with the two new variables appended. We'll pull just these two variables into a new table later as we run the loop
  return(raw_tbl)
}

#The next three functions build the arguments that we will feed into the above 'recode_function' when we put it on loop. The raw info from the metadata file is in 'charachter' format when it comes in,   we need to manipulate it just a little bit in order to get it into a form that r finds acceptable for that argument

#the new value function takes the 'new_vals_r' data and changes it from a charachter string to a named vector

n_val_func <- function (metadata, i) {
  #new values are defined in a list, splitting by the commas in the charachter string
  new_vals <- as.list(el(strsplit(metadata$new_vals_r[i], ",")))
  #the original values are defined as those on the left of the equals sign for each element in the list
  origin_list <- lapply(new_vals, function(x) sub("=.*", "", x))
  #the new values are defined as those on the right of the equals sign for each element in the list
  new_vals <- lapply(new_vals, function(x) sub(".*=","",x))
  # new values are converted from charachters to numeric values
  n_val <- lapply(new_vals, function(x)as.numeric(x))
  #the orignal values are now added as the 'names' of the new values
  names(n_val) <-origin_list
  #the list of new values (with the old values as their names) is returned
  return(n_val)
}

#this function repeats the same process for the new value labels -- the charachter vector is split into two lists, and the new value labels become 'names' of the new values
n_val_lab_func <- function (metadata, i) {
  val_lab_names <- as.list(el(strsplit(metadata$new_labs_r[i], ",")))
  new_val_labs <- as.list(el(strsplit(metadata$new_labs_r[i], ",")))
  val_lab_names <- lapply(new_val_labs, function(x) sub("=.*", "", x))
  val_lab_names <- trimws(unlist(val_lab_names))
  n_val_labs<- lapply(new_val_labs, function(x) sub(".*=","",x))
  n_val_labs<- lapply(n_val_labs, function(x)as.numeric(x))
  n_val_lab <- unlist(n_val_labs)
  names(n_val_lab) <-val_lab_names
  return(n_val_lab)
}

#this final function just creates the name of the .factor variable, taking the 'new variable' name and appending .factor to the end
n_var_factor_func <- function(metadata, i) {
  n_var <- metadata$recoded_var[i]
  n_var_factor <- paste(n_var,'.factor')
  n_var_factor <- gsub (" ", "", n_var_factor, fixed = TRUE)
  return(n_var_factor)
}
