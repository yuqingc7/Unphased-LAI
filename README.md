# Unphased-LAI
 
This github repo has codes for simulation and analyses in BTRY 6840 final project "Local ancestry inference (LAI) for unphased diploid data: starting from genotypes or mapped sequence reads?" by Yuqing Chen (yc2644@cornell.edu). Results presented in the final report can be found in `results_summary_plots`. 

## Note:
1. All the analyses were run on a Cornell biohpc server (Rocky 9.0). R codes are run under R version 4.2.1 (2022-06-23) on the platform x86_64-pc-linux-gnu using Rstudio Server on the Cornell biohpc server. 
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
#Digest: sha256:0ca6b17e6f3c9d304108bda99b1a71925409c3aab3607857f13d97d787979f77
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
bash bash_command_for_mixnmatch.sh hybrid_simulation_configuration.cfg /workdir/Unphased-LAI/mixnmatch_simulation
# test command: bash bash_command_for_mixnmatch.sh hybrid_simulation_configuration_file.cfg /workdir/AHMM_ELAI_comparison/test_mixnmatch

## if prompted with "gzip: simulated_hybrids_reads_gen50_prop_par1_0.5/indiv1_read*.fq.gz already exists; do you wish to overwrite (y or n)?" - (this should not appear after I fixed the mixnmatch perl script)
## all enter "y" 
```

# Local Ancestry Inference
## Perform Ancestry_HMM on simulated admixed genomes (need to be run inside the docker interactively)
```
### inside the same container where you used mixnmatch simulation
cd /mixnmatch_ancestryinfer_docker/ancestryinfer

### run ancestryinfer
mkdir /workdir/Unphased-LAI/AHMM/output
## bash_command_for_ahmm.sh usage: bash bash_command_for_ahmm.sh configuration_file.cfg working_directory (local)
bash bash_command_for_ahmm.sh ahmm_configuration_file.cfg /workdir/Unphased-LAI/AHMM
# warning message can be ignored
# test command: bash bash_command_for_ahmm.sh ahmm_configuration_file.cfg /workdir/AHMM_ELAI_comparison/test_ahmm

### run accuracy test that comes with the pipeline
cd /mixnmatch_ancestryinfer_docker/mixnmatch
# usage: perl post_hmm_accuracy_shell.pl ancestry-probs-par1_file ancestry-probs_par2_file path_to_simulation_reads_folder posterior_thresh path_to_simulator_install
perl post_hmm_accuracy_shell.pl /mixnmatch_ancestryinfer_docker/ancestryinfer/ancestry-probs-par1_allchrs.tsv /mixnmatch_ancestryinfer_docker/ancestryinfer/ancestry-probs-par2_allchrs.tsv simulated_hybrids_reads_gen50_prop_par1_0.5 0.9 /mixnmatch_ancestryinfer_docker/mixnmatch
cp results_summary_simulated_hybrids* /workdir/Unphased-LAI/AHMM
cp accuracy_indiv*_transposed /workdir/Unphased-LAI/AHMM
```

## Perform ELAI on simulated admixed genomes 
```
### In your working directory (outside the container)
exit # if you are in the container, type exit
NETID=yc2644 # update this to your netid
cd /workdir/$NETID/Unphased-LAI
docker1 claim

### convert simulated phased haploypes into unphased diploid genotypes
mkdir ELAI/02_fa ELAI/02_fa
cd ELAI/01_scripts
bash generate_simulated_genotypes.sh

### prepare input bimbam files for ELAI
cd ../04_bimbam
bash vcf2bimbam.sh

### run ELAI
# note that ELAI's singularity image on Cornell biohpc server doesn't work after system's upgraded to Rocky 9
cd ..
git clone https://github.com/haplotype/ELAI.git
mv ELAI/elai-lin elai-lin
bash 01_scripts/01_run_elai.sh &> 01_run_elai.log &
# result files will be in the "output" folder

mkdir sum
### summary across replicates
cd 01_scripts
R 02_sum_across_replicates.R &> 02_sum_across_replicates.log &

### summary across individuals
R 03_sum_per_pop.R &> 03_sum_per_pop.log &
```

# Evaluation & Comparison
You can run R on the Cornell biohpc server. Check out https://biohpc.cornell.edu/lab/userguide.aspx?a=software&i=266 on how to use Rstudio Server (without docker) on a Cornell biohpc server. Briefly, run the command "/programs/rstudio_server/rstudio_start" to start RStudio server. From a browser on your laptop/desktop computer, go to this site "http://cbsuxxxxxx.biohpc.cornell.edu:8015". (replacing the "cbsuxxxxx" with the acutal machine name). Log in with your BioHPC username and password.

Another way, what I did is downloading the sum files to my local machine (I used FileZilla) into a directory `results_summary_plots/data`, running Rstudio using the R scripts in the folder `results_summary_plots`, and producing plots in `results_summary_plots/plots`. 

In this repo, the folder `results_summary_plots/data` hosts the plots and sresults in my final project report. 

- True
  - "*.bed": true ancestry bed files for individuals 1-50
- ELAI
  - "par1_par2_admixed.numgen50_Mean_Replicates.ans_ds1_all.txt" & "par1_par2_admixed.numgen50_Mean_Replicates.ans_ds2_all.txt" (ELAI): ancestry dosage for every individual (n=50)
  - "par1_par2_admixed.numgen50_Mean_Replicates.ans_ds1_per_pop" & "par1_par2_admixed.numgen50_Mean_Replicates.ans_ds2_per_pop" (ELAI): ancestry dosage for ancestry 1 & 2 averaged across 50 individuals in admixed population
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

