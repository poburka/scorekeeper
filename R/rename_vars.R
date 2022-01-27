
tibble_func_1 <- function(x) {
  y = as_tibble(x)
  return (y) }

tibble_func_2 <- function (meta) {
  empty_vec <- vector(mode = 'list', length = length(meta$step))
  tibbles <- purrr::map(empty_vec, tibble_func_1)
  return(tibbles) }

rename_func <- function (data, old_name, new_name){
  renamed <- data %>%
    rename({{new_name}} := old_name)
  return(renamed)}

#' Rename Function
#' Renames variables to new variable name
#' @param raw Raw data
#' @param scoresheet  scoresheet
#'
#' @return table with renamed variables
#' @export

rename_vars <- function (raw, scoresheet) {
  #from the scoresheet file - filter rows where the variables need to be renamed
  raw_data <-raw
  #filter rows of the scoresheet where the operation is 'recode'
  scoresheet1 <- scoresheet %>%
    filter (scoresheet$operation == 'rename')
  #loop through the rename function, using the arguments defined in the scoresheet file and using the functions above
  i <- 1
  m <- 2
  x <- ((length(scoresheet1$step) + 1))
  tibbles <- tibble_func_2(scoresheet1)
  tibbles[[1]] <- raw_data
  while (i < x) {
    raw_var <- scoresheet1$raw_vars[i]
    new_var <- scoresheet1$new_var[i]
    data_for_fun <- tibbles[[i]]
    tibbles[[m]] <- rename_func(data = data_for_fun, old_name = raw_var, new_name = {{new_var}})
    i <- i+1
    m <- m+1}
  return(tibbles[[x]]) }

