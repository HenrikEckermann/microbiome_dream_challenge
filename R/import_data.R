library(tidyverse)
library(glue)
library(here)



###### There are 2 datasets (Schirmer et al (sch) and He et al (he))
###### I will combine those for further analysis

# labels 
labels_he <- read.delim(
  file = here("data/testset_subchallenge2_files/Class_labels_He.txt"),
  colClasses = c("integer", "character", "character")) 
labels_sch <- read.delim(
  file = here("data/testset_subchallenge2_files/Class_labels_Schirmer.txt"),
  colClasses = c("integer", "character", "character"))
labels <- bind_rows(labels_he, labels_sch) %>% 
  select(-row) %>%
  mutate(                 # xgb requires one-hot coding
    group = ifelse(
      group == "nonIBD", 0, ifelse(
        group == "CD", 1, 2))) 
labels$group <- as.factor(labels$group)
group_by(labels, group) %>% summarise(n = n())



###### taxonomic data

taxa_id_info <- read.delim(
  file = here("data/testset_subchallenge2_files/TaxID_Description.txt"))
taxa_abu_he <- read.delim(
  file = here("data/testset_subchallenge2_files/TrainingHe_TaxonomyAbundance_matrix.txt"))
taxa_abu_sch <- read.delim(
  file = here("data/testset_subchallenge2_files/TrainingSchirmer_TaxonomyAbundance_matrix.txt"))
taxa_abu <- bind_cols(taxa_abu_he, taxa_abu_sch) 


# the abundances table includes all taxonomic levels 
# therefore I split by taxonomic level 
taxa_by_level <- taxa_abu %>% 
  left_join(taxa_id_info, by = "TaxID") %>%
  select(TaxID, Taxon, everything(), -TaxID1) %>%
  group_by(Rank) %>% 
  nest()

# how many samples and how many taxons per level? (should be 54 + 116 = 170
map2(taxa_by_level$Rank, taxa_by_level$data, function(rank, df) {
  n_taxa <- dim(df)[1]
  n_samples <- dim(df)[2] - 2 # minus the ID/taxlevel columns
  glue("{n_samples} samples, {n_taxa} {rank}")
})

# # CHECK: the colSums should be ~100 for each sample now for each tax level
# map(taxa_by_level$data, ~select(.x, -Taxon, -TaxID) %>% colSums())


# store names for list (see below)
list_names <- as.character(taxa_by_level$Rank)
# transpose and add labels for analysis 
taxa_by_level <- map(taxa_by_level$data, function(x) {
  x %>% 
    select(-Taxon) %>% 
    gather(sampleID, abundance, -TaxID) %>%
    spread(TaxID, abundance) %>%
    left_join(labels, by = "sampleID") %>%
    select(sampleID, group, everything())
})
names(taxa_by_level) <- list_names



# metadata 
meta <- read.csv(here("data/hmp2_metadata.csv")) %>%
  filter(data_type == "metagenomics", consent_age >= 18)

library(glue)
sample_ids <- labels_sch %>% mutate_at("sampleID", function(sampleID) {
  part1 <- substr(sampleID, 2, 3)
  part2 <- substr(sampleID, 4, length(sampleID))
  return(glue("{part1}-{part2}"))
}) %>% .$sampleID

filter(meta, Stool.Sample.ID...Tube.A...EtOH. %in% sample_ids) 
labels_sch %>% dim()


### pathway data 

path_id_info <- read.delim(
  file = here("data/testset_subchallenge2_files/PathID_Description.txt"))
path_abu_he <- read.delim(
  file = here("data/testset_subchallenge2_files/TrainingHe_PathwayAbundance_matrix.txt"))
path_abu_sch <- read.delim(
  file = here("data/testset_subchallenge2_files/TrainingSchirmer_PathwayAbundance_matrix.txt"))
path_abu <- left_join(path_abu_he, path_abu_sch, by = "PathID") %>%
  gather(sampleID, abundance, -PathID) %>%
  spread(PathID, abundance) %>%
  left_join(labels, by = "sampleID") %>%
  select(sampleID, group, everything())

# The df has too many columns for printing in IRKernel, therefore need to check 
# manually head and tail:
dim(path_abu)
path_abu[c(1:5, 165:170), c(1:5, 12645:12650)]

save(
  path_abu, 
  path_id_info, 
  file = here("data/processed/pathway_abundances.RDS"))
save(
  taxa_by_level, 
  taxa_id_info, 
  file = here("data/processed/tax_abundances.RDS"))


###  test set import 

testset_taxa <- read.delim(
  file = here("data/testset_subchallenge2_files/TestingDataset_TaxonomyAbundance_matrix.txt")) %>% 
    gather(sampleID, abundance, -TaxID) %>%
    spread(TaxID, abundance)
    
test_path <- read.delim(
  file = here("data/testset_subchallenge2_files/TestingDataset_PathwayAbundance_matrix.txt")) %>% 
    gather(sampleID, abundance, -PathID) %>%
    spread(PathID, abundance)
test_taxa <- read.delim(
  file = here("data/testset_subchallenge2_files/TestingDataset_TaxonomyAbundance_matrix.txt"))    

# the abundances table includes all taxonomic levels 
# therefore I split by taxonomic level 
test_taxa_by_level <- test_taxa %>% 
  left_join(taxa_id_info, by = "TaxID") %>%
  select(TaxID, Taxon, everything()) %>%
  group_by(Rank) %>% 
  nest()
  
# store names for list (see below)
list_names <- as.character(test_taxa_by_level$Rank)
# transpose and add labels for analysis 
test_taxa_by_level <- map(test_taxa_by_level$data, function(x) {
  x %>% 
    select(-Taxon) %>% 
    gather(sampleID, abundance, -TaxID) %>%
    spread(TaxID, abundance) %>%
    select(sampleID, everything())
})
names(test_taxa_by_level) <- list_names


save(
  test_taxa_by_level, 
  test_path, 
  file = here("data/processed/testdataset.RDS"))
  