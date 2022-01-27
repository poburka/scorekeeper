
step_func <- function (op, dat, scoresheet) {
  scoresheet <- scoresheet
  dat <- dat
  if ({{op}} %in% {{scoresheet}}$operation) {
    function_for_data <- glue('{op}_vars')
    data_step <- match.fun(function_for_data)(dat, scoresheet)}
  else {data_step <-dat}
  return(data_step)}

#' score function
#'The score function completes all scoring for a single step of a scoresheet. Operations are conducted in the following order:
#'`select`, `if_else`, `recode`, `sum`, `case_when`, `filter_at`, `rename`, `mean`
#' @param raw A raw data object
#' @param scoresheet A formatted scoresheet object with one step selected, operations that can all be preformed
#' in a single step, simultaneously
#' For sequential operations, see scorekeep function)
#' @importFrom purrr map
#' @import tibble
#' @import dplyr
#' @return a tibble
#' @export


score <- function (raw, scoresheet) {
  operations <- c('select', 'if_else', 'recode', 'sum', 'case_when', 'filter_at', 'rename', 'mean')
  data0 <- raw
  scoresheet1 <- scoresheet

  data1 <- step_func(op = 'select', dat = data0, scoresheet = scoresheet1)
  data2 <- step_func(op = 'if_else', dat = data1, scoresheet = scoresheet1)
  data3 <- step_func(op = 'recode', dat = data2, scoresheet = scoresheet1)
  data4 <- step_func(op = 'sum', dat = data3, scoresheet = scoresheet1)
  data5 <- step_func(op = 'case_when', dat = data4, scoresheet = scoresheet1)
  data6 <- step_func(op = 'filter_at', dat = data5, scoresheet = scoresheet1)
  data7 <- step_func(op = 'rename', dat = data6, scoresheet = scoresheet1)
  data8 <- step_func(op = 'mean', dat = data7, scoresheet = scoresheet1)


  return (data8)}

tibble_func_1 <- function(x) {
  y = as_tibble(x)
  return (y) }

tibble_func_2 <- function (meta) {
  steps <- c(unique(meta$step))
  empty_vec <- vector(mode = 'list', length = (length(steps) + 1))
  tibbles <- purrr::map(empty_vec, tibble_func_1)
  return(tibbles) }

#' Scorekeep Function
#'
#' Scores raw data in a step-by-step fashion using scoresheet provided
#'
#' @param raw Raw data object
#' @param scoresheet Formatted scoresheet object with appropriate columns
#'
#' @return a series of tibbles representing data manipulations at each step as specified in scoresheet file. The last tibble in
#' the returned file will include fully cleaned data
#' @export
#'
scorekeep <- function (raw, scoresheet) {
  meta4 <- scoresheet %>% filter(scoresheet$step > 0)
  raw_data <- raw
  steps <- c(unique({{meta4}}$step))
  i <- 1
  m <- 2
  x <- ((length(steps) + 1))
  tibbles4 <- tibble_func_2(meta4)
  tibbles4[[1]] <- raw_data
  while (i < x) {
    scoresheet_for_func <- meta4 %>%
      filter (meta4$step == steps[i])
    data_for_fun <- tibbles4[[i]]
    tibbles4[[m]] <- score(raw = data_for_fun, scoresheet = scoresheet_for_func)
    i <- i+1
    m <- m+1}
  return(tibbles4[(c(2:x))]) }
