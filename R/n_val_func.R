#the new value function takes the 'new_vals_r' data and changes it from a charachter string to a named vector

#' n_val_func
#'
#' @param scoresheet scoresheet
#' @param i row
#'
#' @return new values

n_val_func <- function (scoresheet, i) {
  #new values are defined in a list, splitting by the commas in the charachter string
  new_vals <- new_vals(scoresheet, i)
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



new_vals <- function (scoresheet, i) {
  new_vals_var <- scoresheet$new_vals[[i]]
  if (length(new_vals_var) >1) {
    val_labs <- new_vals_var
    return(new_vals)}
  else {
    new_vals <- as.list(el(strsplit(scoresheet$new_vals[i], ",")))
    new_vals <- trimws(new_vals)
    return(new_vals)}
}
