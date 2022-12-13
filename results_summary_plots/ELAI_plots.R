setwd("~/Github/Unphased-LAI/results_summary_plots")

if (!require(tidyverse)) install.packages('tidyverse')
library(tidyverse)
if (!require(ggplot2)) install.packages('ggplot2')
library(ggplot2)
if (!require(gridExtra)) install.packages('gridExtra')
library(gridExtra)

prefix="par1_par2_admixed"
mg=50


# ancestry dosage,  population mean across individuals --------------------

filename <- paste0("data/ELAI/", prefix ,".numgen", mg, "_Mean_Replicates.ans_ds1_per_pop.txt")
snpinfo_ancestry_ds1 <- read_tsv(filename)

ggplot(data=snpinfo_ancestry_ds1, aes(x=pos, y=ancestry_ds1)) +
  geom_line() +
  ylim(0,2) +
  scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                     labels=c("0", "2.5", "5", "7.5", "10")) +
  labs(x ="Position along chromosome (Mb)", y = "Estimated Dosage of Ancestry 1") +
  theme_classic()+
  ggtitle("ELAI, basic configuration")+
  theme(plot.title = element_text(size = 10)) +
  theme(axis.title = element_text(size = 8))

ggsave("plots/Population averge of ancestry 1 dosage_ELAI.png", width = 10, height = 9, units = "cm")

filename <- paste0("data/ELAI/", prefix ,".numgen", mg, "_Mean_Replicates.ans_ds2_per_pop.txt")
snpinfo_ancestry_ds2 <- read_tsv(filename)

ggplot(data=snpinfo_ancestry_ds2, aes(x=pos, y=ancestry_ds2)) +
  geom_line() +
  ylim(0,2) +
  scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                     labels=c("0", "2.5", "5", "7.5", "10")) +
  labs(x ="Position along chromosome (Mb)", y = "Estimated Dosage of Ancestry 2") +
  theme_classic()+
  ggtitle("ELAI, basic configuration")+
  theme(plot.title = element_text(size = 10)) +
  theme(axis.title = element_text(size = 8))

ggsave("plots/Population averge of ancestry 2 dosage_ELAI.png", width = 10, height = 9, units = "cm")


# ancestry dosage, for each individual -----------------------------------

## individual list
indiv_list <- read_tsv("data/ELAI/samples_id_admixed_n50.txt", col_names = F) %>% 
  mutate(ind=paste0("X",1:50))

filename <- paste0("data/ELAI/", prefix ,".numgen", mg, "_Mean_Replicates.ans_ds1_all.txt")
snpinfo_ancestry_ds1_all_unnumbered <- read_tsv(filename) %>% 
  pivot_longer(2:51, names_to = 'ind', values_to = 'dosage')

snpinfo_ancestry_ds1_all <- left_join(snpinfo_ancestry_ds1_all_unnumbered, indiv_list, by = "ind") %>% 
  select(-ind) %>% 
  rename(ind=X1) %>% 
  mutate(ind = gsub("\\indiv", "", ind))

plot_list <- list()

for (i in c(1:50)){
  ans_ds1_per_ind <- snpinfo_ancestry_ds1_all %>% 
    filter(ind == i)
  
  plot_list[[i]] <- ggplot(ans_ds1_per_ind, aes(x = pos, y = dosage, group = 1)) +
    geom_line() +
    theme_classic() +
    ylim(0,2) +
    scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                       labels=c("0", "2.5", "5", "7.5", "10"))  +
    labs(x ="", y = "") +
    ggtitle(paste0("Individual",i)) +
    theme(plot.title = element_text(size = 10))
}

grid.arrange(grobs=plot_list, nrow=5,top="ELAI",
             left="Per Indivdual Dosage of Ancestry 1", bottom="Position along chromosome (Mb)")


filename <- paste0("data/ELAI/", prefix ,".numgen", mg, "_Mean_Replicates.ans_ds2_all.txt")
snpinfo_ancestry_ds2_all_unnumbered <- read_tsv(filename) %>% 
  pivot_longer(2:51, names_to = 'ind', values_to = 'dosage')

snpinfo_ancestry_ds2_all <- left_join(snpinfo_ancestry_ds2_all_unnumbered, indiv_list, by = "ind") %>% 
  select(-ind) %>% 
  rename(ind=X1) %>% 
  mutate(ind = gsub("\\indiv", "", ind))

plot_list <- list()

for (i in c(1:50)){
  ans_ds2_per_ind <- snpinfo_ancestry_ds2_all %>% 
    filter(ind == i)
  
  plot_list[[i]] <- ggplot(ans_ds2_per_ind, aes(x = pos, y = dosage, group = 1)) +
    geom_line() +
    theme_classic() +
    ylim(0,2) +
    scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                       labels=c("0", "2.5", "5", "7.5", "10"))  +
    labs(x ="", y = "") +
    ggtitle(paste0("Individual",i)) +
    theme(plot.title = element_text(size = 10))
}

grid.arrange(grobs=plot_list, nrow=5,top="ELAI",
             left="Per Indivdual Dosage of Ancestry 2", bottom="Position along chromosome (Mb)")


