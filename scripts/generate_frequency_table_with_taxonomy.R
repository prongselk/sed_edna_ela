library(readr)
library(dplyr)
library(readxl)
library(janitor)


df <- read_tsv("./data/qiime2/relative_frequency_table.tsv", col_names = TRUE, comment = "#")



df_clean <- df %>%
  select(
    -ELAoextractioncontrolo2020o07o14,
    -ELAoextractioncontrolo2020o06o24,
    -ELAoextractioncontrolo2020o07o21,
    -ELAoextractioncontrolo2020o06o25,
    -ELAoextractioncontrolo2020o06o30,
    -BlankpcrCES,
    -ELAoextractioncontrolo2020o07o28
  )


taxonomy <- read_excel("./data/ELA_sediment.xlsx", sheet ="taxaFinal", col_names = FALSE) %>% 
  row_to_names(row_number = 3) %>% 
  slice(1:n()) %>% 
  select(seq_id, scientificName) %>% 
  rename( 'zOTU'= 'seq_id')


frequency_with_taxonomy <- df_clean %>% 
  merge(taxonomy)

write.csv(frequency_with_taxonomy, "./data/frequency_with_taxonomy.csv")
