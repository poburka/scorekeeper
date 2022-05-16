---
  title: "ders_scoresheet"
output: html_document
---
  #background: 
  
The Difficulties in Emotion Regulation Scale (DERS) is an instrument 
measuring emotion regulation problems developed by K.L. Gratz and L. Roemer.
The self-report scale is comprised of 36 items asking respondents how they 
relate to their emotions in order to produce scores on 6 different subscales.
This tool can be especially useful in helping patients identify areas for 
growth in how they respond to their emotions, especially those with 
Borderline Personality Disorder, Generalised Anxiety Disorder or Substance Use
Disorder. The DERS scale has been shown to have high internal consistency, 
good test–retest reliability, and adequate construct and predictive validity 
(Gratz & Roemer, 2003).


```{r}
#load necessary packages
library(haven)
library(cgwtools)
library(readxl)
library(scorekeeper)
#load in raw data and scoresheet

maxed_raw <- read.csv("MAXED_RA_raw.csv")
ders_scoresheet <- read_excel("ders_scoresheet.xlsx")

#run scorekeeper function
scorekeep(maxed_raw, ders_scoresheet)

#outro
```