---
  title: "ybocs_scoresheet"
output: html_document
---
  #background: 

The Yale-Brown Obsessive Compulsive Scale was developed by Wayne Goodman 
Dennis Charney, and is designed to rate the types of symptoms in patients with
Obsessive Compulsive Disorder and their severity. This rating sclae is intended
for use as a semi-structured interview. The interview should assess the items in
the listed order and use the questions provided. The total score is usually 
computed from the subscales for obsessions (items 1-5) and compulsions (items 6-10).

```{r}
#load necessary packages
library(haven)
library(cgwtools)
library(readxl)
library(scorekeeper)
#load in raw data and scoresheet

maxed_raw <- read.csv("MAXED_RA_raw.csv")
ybocs_scoresheet <- read_excel("ybocs_scoresheet.xlsx")

#run scorekeeper function
scorekeep(maxed_raw, ybocs_scoresheet)

#outro
```