---
  title: "bis_bas_scoresheet"
output: html_document
---
  #background: 
  
The BIS/BAS Scale is a 24-item self-report questionnaire designed by C.S. Carver
and T.L. White. The scale is designed to measure two motivational systems: 
the behavioral inhibition system (BIS), which corresponds to motivation to 
avoid aversive outcomes, and the behavioral activation system (BAS), which 
corresponds to motivation to approach goal-oriented outcomes. Participants 
respond to each item using a 4-point Likert scale: 1 (very true for me), 2 
(somewhat true for me), 3 (somewhat false for me), and 4 (very false for me).

```{r}
#load necessary packages
library(haven)
library(cgwtools)
library(readxl)
library(scorekeeper)
#load in raw data and scoresheet

maxed_raw <- read.csv("MAXED_RA_raw.csv")
bis_bas_scoresheet <- read_excel("bis_bas_scoresheet.xlsx")

#run scorekeeper function
scorekeep(maxed_raw, bis_bas_scoresheet)

#outro
```