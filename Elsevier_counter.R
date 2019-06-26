## Script for reading COUNTER statistics from Elsevier ##

library(tidyverse)
library(readxl)

# Reading title lists from file
freedom_collection <- read_csv("freedomcoll.csv", skip = 1) %>%
  filter(!is.na(FC2017)) %>%
  select(`Full Title`, ISSN)

# Reading download stats from file, converting to long format and removing 
# superfluous columns. NOTE: This ignores articles in press, modify code accordingly
elsevier_counter <- read_xlsx("CA-3066_JR5_S000000033_Account_level_input_list_of_accounts_2016_2017_se....xlsx", 
                              sheet = 1) %>%
  rename_at(vars(starts_with("jr5_yop_")), list(~ str_remove(., "jr5_yop_"))) %>%
  select(account_name:journal_display_name, '2018':pre_1995) %>%
  gather('2018':pre_1995, key = "Published_Year", value = "Downloads")

# Reading publications on the national level from file
publications <- read_csv2("norskepub 2017-2018.csv") %>%
  rename("pISSN" = `ISSN på tidsskrift (kun enkle artikler)`,
         "eISSN" = `ISSN_ELEKTRONISK på tidsskrift (kun enkle artikler)`,
         "Year" = ÅRSTALL,
         "Publications" = `Antall NVI-poster`) %>%
  gather(pISSN:eISSN, key = "ISSN type", value = "ISSN")

publications$ISSN <- str_remove(publications$ISSN, "-")

# Joins publications with Elsevier Freedom Collection title list
publications_list <- freedom_collection %>%
  left_join(publications, by = "ISSN") %>%
  filter(!is.na(Publications))
