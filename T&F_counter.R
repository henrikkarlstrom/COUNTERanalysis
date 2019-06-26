## Script for reading COUNTER statistics from various academic publishers ##

library(tidyverse)
library(readxl)

# Reading title lists from file
title_list <- read_excel("T&F - Titlelist 2017.xlsx", sheet = 1) %>%
  gather(key = "ISSN type", value = "ISSN", `Print ISSN`:`Online ISSN`) %>%
  select(Title:`Subject Package 1`, "ISSN type", "ISSN")

# Reading publications on the national level from file
publications <- read_csv2("publisering tandf 2017 Norge.csv") %>%
  right_join(title_list, by = "ISSN") %>%
  filter(!is.na(`Antall NVI-poster`))

# T&F provide counter files in the form of Excel files where each sheet corresponds 
#to one institution of the national consortium. We now read in the sheets as list elements
path <- "TnF_JR1_CERES 2017 usage.xlsx"
sheetnames <- excel_sheets(path)
downloads <- lapply(sheetnames, read_excel, path = path, skip = 7)
names(downloads) <- sheetnames

# Binds the list to a data frame and filters out unnecessary columns
downloads <- downloads %>%
  bind_rows(.id = "Institusjon") %>%
  filter(Journal != "Total for all journals") %>%
  select(Institusjon, 
         Journal, 
         Publisher, 
         `Proprietary Identifier`,
         `Reporting Period Total`)

