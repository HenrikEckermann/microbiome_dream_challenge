library(tidyverse)
library(glue)
library(here)

# There are 2 datasets (Schirmer et al (sch) and He et al (he))

# labels 
labels_he <- read.delim(
  file = here("data/testset_subchallenge2_files/Class_labels_He.txt"))
labels_sch <- read.delim(
  file = here("data/testset_subchallenge2_files/Class_labels_Schirmer.txt"))

# taxonomic data
taxa_id_info <- read.delim(
  file = here("data/testset_subchallenge2_files/TaxID_Description.txt"))
taxa_abu_he <- read.delim(
  file = here("data/testset_subchallenge2_files/TrainingHe_TaxonomyAbundance_matrix.txt"))
taxa_abu_sch <- read.delim(
  file = here("data/testset_subchallenge2_files/TrainingSchirmer_TaxonomyAbundance_matrix.txt"))

# the abundances table includes all taxonomic levels 
# therefore I split by taxonomic level 
taxa_by_level_he <- taxa_abu_he %>% 
  left_join(taxa_id_info, by = "TaxID") %>%
  select(Taxon, everything(), -TaxID) %>%
  group_by(Rank) %>% 
  nest()
taxa_by_level_sch <- taxa_abu_sch %>% 
  left_join(taxa_id_info, by = "TaxID") %>%
  select(Taxon, everything(), -TaxID) %>%
  group_by(Rank) %>% 
  nest()
  
# how many taxons per level?
map2(taxa_by_level_he$Rank, taxa_by_level_he$data, function(rank, df) {
  n_taxa <- dim(df)[1]
  n_samples <- dim(df)[2]
  glue("{n_samples} samples, {n_taxa} {rank}")
})
map2(taxa_by_level_sch$Rank, taxa_by_level_sch$data, function(rank, df) {
  n_taxa <- dim(df)[1]
  n_samples <- dim(df)[2]
  glue("{n_samples} samples, {n_taxa} {rank}")
})

# store each table in separate df
species_he <- taxa_by_level_he$data[[1]]
genus_he <- taxa_by_level_he$data[[2]]
family_he <- taxa_by_level_he$data[[3]]
order_he <- taxa_by_level_he$data[[4]]
class_he <- taxa_by_level_he$data[[5]]
phylum_he <- taxa_by_level_he$data[[6]]
superkingdom_he <- taxa_by_level_he$data[[7]]

# to check, the colSums should be ~100 for each sample now
map(taxa_by_level_sch$data, ~select(.x, -Taxon) %>% colSums())
map(taxa_by_level_he$data, ~select(.x, -Taxon) %>% colSums())
taxa_by_level_sch %>% class()




