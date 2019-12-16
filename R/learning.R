library(tidyverse)
library(caret)

load("data/tax_abundances.RDS")
# superkingdom, phylum, class, order etc. can be loaded.
# change tax_level as required for pathway analyses load pathway_abundances.RDS
# load("data/pathway_abundances.RDS")
tax_level = "species"
df <- taxa_by_level[[tax_level]]

features <- select(df, -group) 
labels <- select(df, sampleID, group) 


