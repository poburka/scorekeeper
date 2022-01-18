

#This function specifically parses the value labels to be a list of values that are named
#' value labels function
#'
#' @param scoresheet A scoresheet
#' @param i a scoresheet row
#'
#' @return a list of named values


n_val_lab_func <- function (scoresheet, i) {
  #if the value labels in the scoresheet 'val_labs' is present (not 'NA'), value labels are created
  if (scoresheet$val_labs[i] != 'NA')
    #make a list of all the value labels
  {new_val_labs <- as.list(el(strsplit(scoresheet$val_labs[i], ",")))
  #Make a list of value label NAMES, which are on the right hand side of the equals sign
  val_lab_names <- lapply(new_val_labs, function(x) sub("=.*", "", x))
  val_lab_names <- trimws(unlist(val_lab_names))
  #make a list of new values, which are on the left hand side of the equals sign
  n_vals<- lapply(new_val_labs, function(x) sub(".*=","",x))
  n_vals<- lapply(n_vals, function(x)as.numeric(x))
  n_vals <- unlist(n_vals)
  #name the new values with the new value names
  names(n_vals) <-val_lab_names}
  else n_vals <- NA
  return(n_vals)
}
