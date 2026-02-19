library(readxl)
library(tidyverse)
library(tibble)
library(missMDA)
library(vegan)
library(openxlsx)
library(mice)
library(VIM)
library(leaflet)
library(sf)
library(Hmsc)
library(pryr)
library(beepr)
library(knitr)
library(cowplot)
library(multcompView)
library(RSQLite)
library(viridis)
library(cowplot)
library(corrplot)
library(reshape2)
library(ggbreak)
library(dplyr)
library(tibble)
library(circlize)
library(janitor)

#### sources for this: ./sources/hmsc.cindy.11.12.2024.html and official HMSC sources https://www.helsinki.fi/en/researchgroups/statistical-ecology/software/hmsc

setwd("E:/sed_edna_ela")

not_all_na <- function(x) any(!is.na(x)) #there is probably an in built function for this I just couldn't figure it out...


# reading into the excel to extract sample metadata

metadata <- read_excel("./data/ELA_sediment.xlsx", sheet = "sampleMetadata", col_names = FALSE) %>% 
  row_to_names(row_number = 3) %>% 
  slice(1:n()) %>% 
  select(where(not_all_na)) 
 
 
# reading into environmental data (from Rebecca Garner)

env <- read_table("./data/input/ela_env_sedintervals_joanne.tsv") 

env$sample_id <- paste0(
  "ELAo",
  gsub("[_-]", "o",
       gsub("\\.", "", env$sample_id)
  )
)

  
# reading into the frequency table and converting it into presence-absence format (where presence = more than 10 reads)

sp <- read.csv("./data/frequency_with_taxonomy.csv") %>% 
  select(-X) %>% 
  column_to_rownames("zOTU")

sp_long <- sp %>%
  pivot_longer(
    cols = -"scientificName",
    names_to = "SampleID",
    values_to = "Value"
  ) 

sp_long <- sp_long %>% 
  subset(Value>10)

sp_long["Value"]<-1

sp_wide <- sp_long %>%
  pivot_wider(
    names_from = scientificName,
    values_from = Value,
    values_fn = \(x) as.integer(any(x == 1)),  
    values_fill = 0
  )


sp <- sp_wide %>%
  column_to_rownames("SampleID")


# extracting spatial data from the metadata

spatial <- metadata %>% 
  select(samp_name, decimalLongitude, decimalLatitude) %>% 
  filter(samp_name %in% rownames(sp)) %>% 
  drop_na(decimalLongitude, decimalLatitude) %>% 
  rename(longitude = decimalLongitude,
         latitude = decimalLatitude) %>% 
  column_to_rownames("samp_name") 


# filtering the environmental data to have no blanks

env <- env %>% 
  filter(sample_id %in% rownames(sp)) %>% 
  column_to_rownames("sample_id") %>% 
  select(-lake_id) %>% 
  select(where(~ !any(is.na(.))))


##### insert here: combining zOTUs into groups, adding trait data, 
##### splitting data by lakes or time periods, etc


# the following code is what constructing the model would look like
# I've done lots of test runs with the previous iterations of the dataset, 
# running it as is wouldn't work, 
# as the data is too granular, it needs to be split by lake/time period, 
# and/or ZOTUs need to be grouped together 
# (e.g. into groups like 'green algae' and 'rotifers')
# this type of model also allows trait data input, 
# we don't have dynamic trait observations for ELA for a long enough time period, 
# but these could be static traits (e.g. a photosynthesis proxy metric for plants)


# how many chains to sample
nChains = 2
# how many samples to obtain per chain
samples = 1000
# how much thinning to apply
thin = 5
# length of the transient
transient = 500*thin
# verbose
verbose = 500*thin
# to define a spatial random effect at the level of the sampling site, we need 
# to include the site id in the studyDesign
studyDesign <- rownames(spatial)
studyDesign = data.frame(SiteID = as.factor(studyDesign))
rL = HmscRandomLevel(units = studyDesign$SiteID)

r.model <- Hmsc(Y = sp, 
                   XData = env, 
                   #TrData = run.287.trait.prep,
                   #TrFormula = ~ MLD + zoo.length + fish.length,
                   studyDesign = studyDesign, 
                   ranLevels = list("SiteID" = rL), 
                   distr= ("probit"),YScale = TRUE, XScale = TRUE)


{start.time <- Sys.time()
  start.memory <- mem_used()
  r.model = sampleMcmc(r.model, thin = thin, samples = samples,
                          transient = transient, nChains = nChains,
                          verbose = verbose)
  print(Sys.time() - start.time)
  print(mem_used() - start.memory)
  beep(sound = 8)}


mpost = convertToCodaObject(r.model)
mean(gelman.diag(mpost$Beta,multivariate=FALSE)$psrf[,1])
mpost = convertToCodaObject(r.model)
plot(mpost$Beta)

preds = computePredictedValues(r.model)
MF = evaluateModelFit(r.model, predY = preds)
mean(MF$TjurR2)

postBeta = getPostEstimate(r.model, parName = "Beta")
par(mar = c (10,10,2,2))
plotBeta(r.model, post = postBeta, param = "Sign", plotTree = FALSE,
         supportLevel = 0.95, mar = NULL, spNamesNumbers = c(T,F),
         cex = c(0.8,0.7,0.8))



postBeta = getPostEstimate(r.model, parName = "Beta")
par(mar = c (10,10,2,2))
plotBeta(r.model, post = postBeta, param = "Sign", plotTree = FALSE,
         supportLevel = 0.95, mar = NULL, spNamesNumbers = c(T,F),
         cex = c(0.8,0.7,0.8))




