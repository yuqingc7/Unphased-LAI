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
  ggtitle("Ancestry_HMM result with basic configuration") +
  theme(plot.title = element_text(size = 20)) +
  theme(axis.title = element_text(size = 15)) 


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
  ggtitle("Ancestry_HMM result with basic configuration") +
  theme(plot.title = element_text(size = 20)) +
  theme(axis.title = element_text(size = 15)) 


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

