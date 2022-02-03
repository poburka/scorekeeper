

# This function specifically parses the value labels to be a list of values that are named
#' value labels function
#'
#' @param scoresheet A scoresheet
#' @param i a scoresheet row
#'
#' @return a list of named values




n_val_lab_func <- function (scoresheet, i) {
  new_val_labs <- val_lab_func(scoresheet, i)
  #Make a list of value label NAMES, which are on the right hand side of the equals sign
  val_lab_names <- lapply(new_val_labs, function(x) sub("=.*", "", x))
  val_lab_names <- trimws(unlist(val_lab_names))
  #make a list of new values, which are on the left hand side of the equals sign
  n_vals<- lapply(new_val_labs, function(x) sub(".*=","",x))
  n_vals<- lapply(n_vals, function(x)as.numeric(x))
  n_vals <- unlist(n_vals)
  #name the new values with the new value names
  names(n_vals) <-val_lab_names

  return(n_vals)
}


val_lab_func <- function (scoresheet, i) {

  val_labs_var <- scoresheet$val_labs[i]
  if (class(val_labs_var) =='list') {
    val_labs <- scoresheet$val_labs[[i]]
    return(val_labs)}
  else {
    val_labs <- as.list(el(strsplit(scoresheet$val_labs[i], ",")))
    val_labs <- trimws(val_labs)
    return(val_labs)}
}

