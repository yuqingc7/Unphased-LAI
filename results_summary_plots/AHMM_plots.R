setwd("~/Github/Unphased-LAI/results_summary_plots")

if (!require(tidyverse)) install.packages('tidyverse')
library(tidyverse)
if (!require(ggplot2)) install.packages('ggplot2')
library(ggplot2)
if (!require(gridExtra)) install.packages('gridExtra')
library(gridExtra)


# posterior probability, population mean across individuals ---------------

ans1_probs <- read_tsv("data/AHMM/ancestry-probs-par1_transposed_allchrs.tsv")

ans1_probs_mean <- ans1_probs %>% rename(site = `...1`) %>% 
  separate(site, into=c("chr", "bp"), sep = ":") %>% 
  mutate(mean_prob = rowMeans(select(ans1_probs,starts_with("indiv")), na.rm = F)) %>% 
  select(2,mean_prob) %>% 
  mutate(bp = as.numeric(bp))

ggplot(ans1_probs_mean, aes(x = bp, y = mean_prob, group = 1)) +
  geom_line() +
  theme_classic() +
  ylim(0,1) +
  scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                     labels=c("0", "2.5", "5", "7.5", "10"))  +
  labs(x ="Position along chromosome (Mb)", y = "Mean Posterior Probability of Ancestry 1") +
  ggtitle("Ancestry_HMM, basic configuration") +
  theme(plot.title = element_text(size = 10)) +
  theme(axis.title = element_text(size = 8))

ggsave("plots/Population averge posterior probability of ancestry 2_AHMM.png", width = 10, height = 9, units = "cm")


ans2_probs <- read_tsv("data/AHMM/ancestry-probs-par2_transposed_allchrs.tsv")

ans2_probs_mean <- ans2_probs %>% rename(site = `...1`) %>% 
  separate(site, into=c("chr", "bp"), sep = ":") %>% 
  mutate(mean_prob = rowMeans(select(ans2_probs,starts_with("indiv")), na.rm = FALSE)) %>% 
  select(2,mean_prob) %>% 
  mutate(bp = as.numeric(bp))

ggplot(ans2_probs_mean, aes(x = bp, y = mean_prob, group = 1)) +
  geom_line() +
  theme_classic() +
  ylim(0,1) +
  scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                     labels=c("0", "2.5", "5", "7.5", "10"))  +
  labs(x ="Position along chromosome (Mb)", y = "Mean Posterior Probability of Ancestry 2") +
  ggtitle("Ancestry_HMM, basic configuration") +
  theme(plot.title = element_text(size = 10)) +
  theme(axis.title = element_text(size = 8))

ggsave("plots/Population averge posterior probability of ancestry 1_AHMM.png", width = 10, height = 9, units = "cm")


# posterior probability, for each individual -----------------------------

plot_list <- list()

for (ind in c(3:52)){
  
ans1_probs_per_ind <- ans1_probs %>% rename(site = `...1`) %>% 
  separate(site, into=c("chr", "bp"), sep = ":") %>% 
  select(2,ind) %>% 
  rename(prob = 2) %>% 
  mutate(bp = as.numeric(bp))
    
plot_list[[ind-2]] <- ggplot(ans1_probs_per_ind, aes(x = bp, y = prob, group = 1)) +
  geom_line() +
  theme_classic() +
  ylim(0,1) +
  scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                     labels=c("0", "2.5", "5", "7.5", "10"))  +
  labs(x ="", y = "") +
  ggtitle(paste0("Individual",ind-2)) +
  theme(plot.title = element_text(size = 10))
}

grid.arrange(grobs=plot_list, nrow=5,top="Ancestry_HMM",
             left="Per Indivdual Posterior Probability of Ancestry 1", bottom="Position along chromosome (Mb)")


# ancestry dosage, population mean across individuals --------------------
files <- dir(path = "data/AHMM", pattern = "*_genotypes_file_transposed")

ans_ds_all <- files %>% map(~ read_tsv(file.path("data/AHMM", .))) %>% 
  reduce(full_join, by = c("pos"="pos","chr"="chr")) %>% 
  select(-chr) %>% 
  pivot_longer(2:51, names_to = 'ind', values_to = 'dosage') %>% 
  mutate(ind = gsub("\\_read1.fq", "", ind)) %>% 
  mutate(ind = gsub("\\indiv", "", ind))

ans_ds_per_pop <- ans_ds_all %>% 
  group_by(pos) %>% 
  summarise(dosage_pep_pop = mean(dosage, na.rm=T)) 

ggplot(ans_ds_per_pop, aes(x = pos, y = dosage_pep_pop)) + 
  geom_line() +
  ylim(0,2) +
  scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                     labels=c("0", "2.5", "5", "7.5", "10")) +
  labs(x ="Position along chromosome (Mb)", y = "Estimated Dosage of Ancestry 2") +
  theme_classic()+
  ggtitle("Ancestry_HMM, basic configuration")+
  theme(plot.title = element_text(size = 10)) +
  theme(axis.title = element_text(size = 8))

ggsave("plots/Population averge of ancestry 2 dosage_AHMM.png", width = 10, height = 9, units = "cm")

# ancestry dosage, for each individual -----------------------------------

plot_list <- list()

for (ind in c(1:50)){
  ans_ds_per_ind <- ans_ds_all %>% 
    select(pos,ind+1)
  
  plot_list[[ind]] <- ggplot(ans_ds_per_ind, aes(x = pos, y = dosage, group = 1)) +
    geom_line() +
    theme_classic() +
    ylim(0,2) +
    scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                       labels=c("0", "2.5", "5", "7.5", "10"))  +
    labs(x ="", y = "") +
    ggtitle(paste0("Individual",ind)) +
    theme(plot.title = element_text(size = 10))
}

grid.arrange(grobs=plot_list, nrow=5,top="Ancestry_HMM",
             left="Per Indivdual Dosage of Ancestry 2", bottom="Position along chromosome (Mb)")

