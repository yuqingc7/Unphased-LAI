setwd("~/Github/Unphased-LAI/results_summary_plots")

if (!require(tidyverse)) install.packages('tidyverse')
library(tidyverse)
if (!require(ggplot2)) install.packages('ggplot2')
library(ggplot2)
if (!require(ggsci)) install.packages('ggsci')
library(ggsci)
if (!require(grid)) install.packages('grid')
library(grid)
if (!require(gridExtra)) install.packages('gridExtra')
library(gridExtra)
if (!require(ggpubr)) install.packages('ggpubr')
library(ggpubr)


### ELAI ancestry dosage
filename <- paste0("data/ELAI/", prefix ,".numgen", mg, "_Mean_Replicates.ans_ds2_all.txt")
indiv_list <- read_tsv("data/ELAI/samples_id_admixed_n50.txt", col_names = F) %>% 
  mutate(ind=paste0("X",1:50))

ELAI_unnumbered <- read_tsv(filename) %>% 
  pivot_longer(2:51, names_to = 'ind', values_to = 'dosage')

ELAI <- left_join(ELAI_unnumbered, indiv_list, by = "ind") %>% 
  select(-ind) %>% 
  rename(ind=X1) %>% 
  mutate(ind = gsub("\\indiv", "", ind)) %>% 
  mutate(method = "ELAI")

### Ancestry_HMM ancestry dosage
files <- dir(path = "data/AHMM", pattern = "*_genotypes_file_transposed")
AHMM <- files %>% map(~ read_tsv(file.path("data/AHMM", .))) %>% 
  reduce(full_join, by = c("pos"="pos","chr"="chr")) %>% 
  select(-chr) %>% 
  pivot_longer(2:51, names_to = 'ind', values_to = 'dosage') %>% 
  mutate(ind = gsub("\\_read1.fq", "", ind)) %>% 
  mutate(ind = gsub("\\indiv", "", ind)) %>%
  mutate(method = "AHMM")

ELAI_AHMM <- bind_rows(ELAI, AHMM) 

### true ancestry dosage
true_sum <- read_tsv("data/results_summary_simulated_hybrids_reads_gen50_prop_par1_0.5", col_names = F) %>% 
  rename(ind=X1, start=X2, end=X3, counts_het=X4, counts_par1=X5, counts_par2=X6, 
         true_ancestry=X7,accurate_counts=X8,inaccurate_counts=X9,mean_posterior=X10) %>% 
  mutate(dosage = case_when(true_ancestry == "par1par1" ~ "0",
                            true_ancestry == "par2par2" ~ "2",
                            true_ancestry == "par2par1" ~ "1",
                            true_ancestry == "par1par2" ~ "1")) %>%
  select(ind, start, end, dosage) %>% 
  mutate(dosage=as.numeric(dosage)) %>% 
  mutate(ind = gsub("\\indiv", "", ind))

ELAI_AHMM_true <- left_join(ELAI_AHMM, true_sum, by = "ind")

ELAI_AHMM_True <- ELAI_AHMM_true %>% 
  rename(dosage = dosage.x, `True` = dosage.y) %>% 
  filter(pos <= end & pos >= start) %>% 
  pivot_wider(names_from = method, values_from = dosage) %>% 
  pivot_longer(5:7, names_to = 'method', values_to = 'dosage') %>% 
  drop_na() %>% 
  mutate(method = fct_relevel(method, 
                              "True", "ELAI", "AHMM"))

# averaged across individuals comparison ----------------------------------

ELAI_AHMM_True_per_pop <- ELAI_AHMM_True %>% 
  group_by(pos, method) %>% 
  summarise(dosage_pep_pop = mean(dosage))

ggplot(ELAI_AHMM_True_per_pop, aes(x = pos, y = dosage_pep_pop, color = method)) + 
  geom_line() +
  ylim(0,2) +
  scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                     labels=c("0", "2.5", "5", "7.5", "10")) +
  labs(x ="Position along chromosome (Mb)", y = "Population averge of ancestry 2 dosage") +
  theme_classic()+
  ggtitle("ELAI vs Ancestry_HMM, basic configuration")+
  theme(plot.title = element_text(size = 20))+
  theme(axis.title = element_text(size = 15))+
  theme(axis.text = element_text(size = 13))+
  theme(legend.position = "none")+
  scale_color_nejm()+
  facet_wrap(~method)

ggsave("plots/Population averge of ancestry 2 dosage.png", width = 30, height = 12, units = "cm")

# per individual dosage comparison ----------------------------------------

plot_list <- list()

for (i in c(1:50)){
  ELAI_AHMM_True_i <- ELAI_AHMM_True %>% filter(ind == i)
  plot_list[[i]] <- ggplot(ELAI_AHMM_True_i, aes(x = pos, y = dosage)) + 
    geom_line(aes(color = method, linetype=method)) +
    ylim(0,2) +
    scale_x_continuous(breaks=c(0, 2500000,5000000, 7500000, 10000000),
                       labels=c("0", "2.5", "5", "7.5", "10")) +
    theme_classic()+
    labs(x ="", y = "") +
    ggtitle(paste0("Individual ",i)) +
    theme(plot.title = element_text(size = 10))+
    #theme(legend.position = "none")+
    scale_color_nejm(name = "") +
    scale_linetype_manual(values=c("solid", "dashed","dashed"), name = "")
}

figure <- ggarrange(plotlist=plot_list, nrow=8, ncol= 7, common.legend = TRUE, legend = "bottom")
annotate_figure(figure, 
                top = textGrob("ELAI vs Ancestry_HMM, basic configuration", gp = gpar(cex = 1.6)),
                left = textGrob("Per Indivdual ancestry 2 dosage", rot = 90, vjust = 1, gp = gpar(cex = 1.3)),
                bottom = textGrob("Position along chromosome (Mb)", gp = gpar(cex = 1.3)))

ggsave("plots/Per indivdual ancestry 2 dosage.png", width = 40, height = 50, units = "cm")

