# Unphased-LAI
 
This github repo has codes for simulation and analyses in BTRY 6840 final project "Local ancestry inference (LAI) for unphased diploid data: starting from genotypes or mapped sequence reads?" by Yuqing Chen (yc2644@cornell.edu). Results presented in the final report can be found in `results_summary_plots`. 

## Note:
1. All the analyses were run on a Cornell biohpc server (Rocky 9.0). R codes are run under R version 4.2.1 (2022-06-23) on the platform x86_64-pc-linux-gnu using Rstudio Server on the Cornell biohpc server. R codes for plotting are run under R version 4.2.2 (2022-10-31) on aarch64-apple-darwin20. 
2. On Cornell biohpc server, `docker1` was used instead of `docker`. Your `/workdir/netID` will also be automatically mounted as `/workdir`. If you are working on your own computer, you will need to mount your local directory and use that to replace `/workdir`. 
3. mixnmatch and ancestryinfer need to be run inside the docker container in the interactive mode.  
4. snakemake can be a better choice to streamline the process than what I have here. 

# Simulation 
## Set up your working directory and docker image
```
### download github repo in your working directory
NETID=yc2644 # update this to your netid
cd /workdir/$NETID
git clone https://github.com/yuqingc7/Unphased-LAI
ls Unphased-LAI # check if all files are there

### load the image from docker hub
docker1 pull yuqingchen/unphased-lai:latest
#Digest: sha256:284cb2887fdf62ffbe2fc5ea3d414fd7c20fe5433499a6918cfb10576a648748
#Status: Downloaded newer image for yuqingchen/unphased-lai:latest
#docker.io/yuqingchen/unphased-lai:latest

### check if docker image loaded
docker1 images
#REPOSITORY                              TAG                              IMAGE ID       CREATED        SIZE
#yuqingchen/unphased-lai                 latest                           d275714c1264   15 hours ago   2.31GB
```

Your working directory will be `/workdir/$NETID/Unphased-LAI` (outside the docker container), which will be mounted as `/workdir/Unphased-LAI` inside the docker container. 

Refer to "docker_image_set_up.md" to learn how the docker image was made. 

## Simulate admixed genomes using mixnmatch (need to be run inside the docker interactively)
```
### start a Docker container from the image
NETID=yc2644 # update this to your netid
docker1 run -dit yuqingchen/unphased-lai 
docker1 ps -a

### run the Docker container
export CID=xxxxxxxx # replace xxxxxxxx with the "CONTAINER ID"
docker1 exec -it $CID bash

### edit your configuration file

### inside the container, run the mixnmatch simulation
cd /mixnmatch_ancestryinfer_docker/mixnmatch

## bash_command_for_mixnmatch.sh usage: bash bash_command_for_mixnmatch.sh configuration_file.cfg working_directory (local)
bash bash_command_for_mixnmatch.sh hybrid_simulation_configuration_file.cfg /workdir/Unphased-LAI/mixnmatch_simulation
# Runtime: 0:43:35 (hh:mm:ss)

## if prompted with "gzip: simulated_hybrids_reads_gen50_prop_par1_0.5/indiv1_read*.fq.gz already exists; do you wish to overwrite (y or n)?" - (this should not appear after I fixed the mixnmatch perl script)
## all enter "y" 
```

# Local Ancestry Inference
## Ancestry_HMM (need to be run inside the docker interactively)
```
### inside the same container where you used mixnmatch simulation
cd /mixnmatch_ancestryinfer_docker/ancestryinfer

### run ancestryinfer
mkdir /workdir/Unphased-LAI/AHMM/output
## bash_command_for_ahmm.sh usage: bash bash_command_for_ahmm.sh configuration_file.cfg working_directory (local)
bash bash_command_for_ahmm.sh ahmm_configuration_file.cfg /workdir/Unphased-LAI/AHMM
# can igore warning message
# Runtime: 0:39:34 (hh:mm:ss)
```

## ELAI 
```
### In your working directory (outside the container)
exit # if you are in the container, type exit
NETID=yc2644 # update this to your netid
cd /workdir/$NETID/Unphased-LAI
docker1 claim

### convert simulated phased haploypes into unphased diploid genotypes
cd ELAI/01_scripts
bash generate_simulated_genotypes.sh
# Runtime: 0:2:17 (hh:mm:ss)

### prepare input bimbam files for ELAI
cd ../04_bimbam
bash vcf2bimbam.sh

### run ELAI
# note that ELAI's singularity image on Cornell biohpc server doesn't work after system's upgraded to Rocky 9
cd ..
git clone https://github.com/haplotype/ELAI.git
mv ELAI/elai-lin elai-lin
chmod a+x elai-lin
bash 01_scripts/01_run_elai.sh &> 01_run_elai.log &
jobs # to check the running status
# result files will be in the "output" folder
# Runtime: 14:47:50 (hh:mm:ss)
# can use slurm job scheduler to multithread on cornell biohpc server

### summary across replicates
mkdir sum
# open Rstudio and go to Unphased/ELAI/01_scripts
# run 02_sum_across_replicates.R

### summary across individuals
# open Rstudio and go to Unphased/ELAI/01_scripts
# run 03_sum_per_pop.R
```

# Evaluation & Comparison
You can run R on the Cornell biohpc server. Check out https://biohpc.cornell.edu/lab/userguide.aspx?a=software&i=266 on how to use Rstudio Server (without docker) on a Cornell biohpc server. Briefly, run the command "/programs/rstudio_server/rstudio_start" to start RStudio server. From a browser on your laptop/desktop computer, go to this site "http://cbsuxxxxxx.biohpc.cornell.edu:8015". (replacing the "cbsuxxxxx" with the acutal machine name). Log in with your BioHPC username and password.

Another way, what I did is downloading the files to be analyzed to my local machine (I used FileZilla) into a directory `results_summary_plots/data`, running Rstudio using the R scripts in the folder `results_summary_plots`, and producing plots in `results_summary_plots/plots`. 

In this repo, the folder `results_summary_plots/data` hosts the example outputs from my project report under basic simulation configuration. 

- True
  - "*.bed": true ancestry bed files for individuals 1-50
- ELAI
  - "samples_id_admixed_n50.txt": admixed individuals list (ELAI doesn't output admixed individuals names together with the dosage, need to use this name list to re-label the dosage with corresponding indiviuals; from `Unphased-LAI/ELAI/03_vcf/`)
  - "par1_par2_admixed.numgen50_Mean_Replicates.ans_ds1_all.txt" & "par1_par2_admixed.numgen50_Mean_Replicates.ans_ds2_all.txt": ancestry dosage for every individual (n=50)
  - "par1_par2_admixed.numgen50_Mean_Replicates.ans_ds1_per_pop" & "par1_par2_admixed.numgen50_Mean_Replicates.ans_ds2_per_pop" : ancestry dosage for ancestry 1 & 2 averaged across 50 individuals in admixed population
    - for *ans_ds1, 2: homozygous ancestry 1; 1: heterozygous; 0: homozygous ancestry 2
    - for *ans_ds2, 2: homozygous ancestry 2; 1: heterozygous; 0: homozygous ancestry 1
- AHMM
  - "ancestry-probs-par1_transposed_allchrs.tsv" & "ancestry-probs-par2_transposed_allchrs.tsv" (AHMM): posterior probability of acestry 1 & 2 for each individual
  - "accuracy_indiv*_genotypes_file_transposed": ancestry state called based on posterior probability 
    - 2: homozygous ancestry 2; 1: heterozygous; 0: homozygous ancestry 1
- "results_summary_simulated_hybrids_reads_gen50_prop_par1_0.5": 
  - columns represent indiv,start,stop,counts_het,counts_par1,counts_par2,true_ancestry,accurate_counts,inaccurate_counts,mean posterior probability (for AHMM)


## References
https://github.com/Schumerlab/mixnmatch

https://github.com/gchen98/macs 

https://github.com/Schumerlab/ancestryinfer 

https://github.com/haplotype/ELAI 

https://github.com/mleitwein/local_ancestry_inference_with_ELAI

https://github.com/sanger-pathogens/snp-sites

https://github.com/IARCbioinfo/VCF-tricks

