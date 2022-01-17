## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(scorekeeper)

## -----------------------------------------------------------------------------
knitr::kable(head(binge_raw))

## -----------------------------------------------------------------------------
knitr::kable(head(binge_scoresheet[10,]), align = 'l', caption = 'Example row from binge_scoresheet')

