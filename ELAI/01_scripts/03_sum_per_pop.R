setwd("/local/workdir/yc2644/AHMM_ELAI_comparison/ELAI_test/sum")

# this script is to average across individuals within every population
# should be run after 02_sum_across_replicates.R

if (!require(tidyverse)) install.packages('tidyverse')
library(tidyverse)
if (!require(ggplot2)) install.packages('ggplot2')
library(ggplot2)

prefix="par1_par2_admixed"
mg=50

ds <- read_tsv(paste0(prefix ,".numgen", mg, "_Mean_Replicates.ps21.txt"), col_names=F) # every row represents an individual
# 123667 snps, 50 individuals
# 123667*2 columns, 50 rows

# extract odd and even data (ancestry dosage from two source populations)
odd_cols <- seq_len(ncol(ds)) %% 2
ds_odd <- ds[, odd_cols == 1] # A tibble: 89 × 983
ds_even <- ds[, odd_cols == 0] # A tibble: 89 × 983

# average across individuals
ancestry_ds1 <- colMeans(ds_odd) # native
ancestry_ds2 <- colMeans(ds_even) # aquaculture

# extract snp positions
snpinfo <- read_tsv(paste0("/local/workdir/yc2644/AHMM_ELAI_comparison/ELAI_test/output/", prefix ,".numgen", mg,".replicate01.snpinfo.txt"), col_names=T)[,2]

snpinfo_ancestry_ds1 <- data.frame(snpinfo, ancestry_ds1)
row.names(snpinfo_ancestry_ds1) <- NULL

filename <- paste0("/local/workdir/yc2644/AHMM_ELAI_comparison/ELAI_test/sum/", prefix ,".numgen", mg, "_Mean_Replicates.ans_ds1.txt")
write_tsv(snpinfo_ancestry_ds1, filename)

snpinfo_ancestry_ds2 <- data.frame(snpinfo, ancestry_ds2)
row.names(snpinfo_ancestry_ds2) <- NULL

filename <- paste0("/local/workdir/yc2644/AHMM_ELAI_comparison/ELAI_test/sum/", prefix ,".numgen", mg, "_Mean_Replicates.ans_ds2.txt")
write_tsv(snpinfo_ancestry_ds2, filename)
  
# clean up R memory
rm(list = ls())
gc()
.rs.restartR()
gc()
