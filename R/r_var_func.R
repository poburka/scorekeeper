

#the r_var_function takes raw variables to be summed are defined in a list,
#splitting by the commas in the charachter string,
#trimming the whitespace


#' Title
#'
#' @param scoresheet A scoresheet object
#' @param i a scoresheet row
#'
#' @return a list of raw variables

r_var_func <- function (scoresheet, i) {
    raw_var_var <- scoresheet$raw_vars[i]
    if (class(raw_var_var) == 'list') {
      raw_vars <- scoresheet$raw_vars[[i]]
      return(raw_vars)}
    else {
      raw_vars <- as.list(el(strsplit(scoresheet$raw_vars[i], ",")))
      raw_vars <- trimws(raw_vars)
  return(raw_vars)}
}
