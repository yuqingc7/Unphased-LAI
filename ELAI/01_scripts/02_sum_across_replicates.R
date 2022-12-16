setwd("/local/workdir/yc2644/Unphased-LAI/ELAI/output/")

if (!require(magrittr)) install.packages('magrittr')
library(magrittr)
if (!require(dplyr)) install.packages('dplyr')
library(dplyr)
if (!require(data.table)) install.packages('data.table')
library(data.table)
if (!require(reshape2)) install.packages('reshape2')
library(reshape2)

# the warnings are harmless; they are triggered by the merging step - we can simply ignore them

mean_replicate <- function(prefix, mg){
  
  PATH = ("/local/workdir/yc2644/Unphased-LAI/ELAI/output/")
  file_list = list.files(path=PATH, 
                       pattern=paste0(prefix, ".numgen", mg, ".replicate*[0-9]*.ps21.txt"))
  print(file_list)
  
  list.df = lapply(file_list, function(x) read.table(x))
  
  melt_list = rep( list(list()), length(list.df))
  melt_list = lapply(list.df, function(x) melt(as.matrix(x)))
  
  n_rep = length(melt_list)
  
  result <- Reduce(function(...) merge(...,by=c("Var1", 'Var2'), all=F), melt_list) %>% #merged files 
    set_colnames(., c("Var1", "Var2", as.character(seq(1,n_rep,1)))) %>% #rename headers
    mutate(., cell_mean = select(., -Var1, -Var2) %>% apply(.,1, mean)) # compute the mean
  
  res_mean_cell<-dcast(result,  Var1 ~ Var2, value.var = "cell_mean")
  res_mean_cell[1] <- NULL  # remove individuals 
  
  filename <- paste0("/local/workdir/yc2644/Unphased-LAI/ELAI/sum/", prefix, ".numgen", mg, "_Mean_Replicates.ps21.txt")
  write.table(res_mean_cell, filename, quote = FALSE, col.names=FALSE,row.names=FALSE,sep="\t")
}

# sd_replicate <- function(prefix, mg){
  
#   PATH = ("/local/workdir/yc2644/Unphased-LAI/ELAI/output/")
#   file_list = list.files(path=PATH, 
#                          pattern=paste0(prefix, ".numgen", mg, ".replicate*[0-9]*.ps21.txt"))
#   print(file_list)
  
#   list.df = lapply(file_list, function(x) read.table(x))
  
#   melt_list = rep( list(list()), length(list.df))
#   melt_list = lapply(list.df, function(x) melt(as.matrix(x)))
  
#   n_rep = length(melt_list)
  
#   result <- Reduce(function(...) merge(...,by=c("Var1", 'Var2'), all=F), melt_list) %>% #merged files 
#     set_colnames(., c("Var1", "Var2", as.character(seq(1,n_rep,1)))) %>% #rename headers
#     mutate(., cell_sd = select(., -Var1, -Var2) %>% apply(.,1, sd)) # compute the SD
  
#   res_sd_cell<-dcast(result,  Var1 ~ Var2, value.var = "cell_sd")
#   res_sd_cell[1] <- NULL  # remove individuals 
  
#   filename <- paste0("/local/workdir/yc2644/Unphased-LAI/ELAI/sum/", prefix ,".numgen", mg, "_SD_Replicates.ps21.txt")
#   write.table(res_sd_cell, filename, quote = FALSE, col.names=FALSE,row.names=FALSE,sep="\t")
# }

mean_replicate("par1_par2_admixed", 50)
#sd_replicate("par1_par2_admixed", 50)

# clean up R memory
rm(list = ls())
gc()
.rs.restartR()
gc()
