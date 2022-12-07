# Unphased-LAI

This github repo host ... and it can be used a working directory. Scripts are organized into mixnmatch, ELAI, ancestryinfer. 

## Note:
1. All the analyses were run on a Cornell biohpc server (Rocky 9.0). The R codes are run under R version 4.2.2 (2022-10-31) -- "Innocent and Trusting". 
2. On Cornell biohpc server, `docker1` was used instead of `docker`. Your `/workdir/netID` will also be automatically mounted as `/workdir`. If you are working on your own computer, you will need to mount your local directory and use that to replace `/workdir`. 
3. mixnmatch and ancestryinfer need to be run inside the docker container in the interactive mode. 
4. snakemake can be a better choice to streamline the process than what I have here. 

## Set up your working directory and docker image
```
### download github repo in your working directory
NETID=yc2644 # update this to your netid
cd /workdir/$NETID
git clone https://github.com/yuqingc7/Unphased-LAI
ls Unphased-LAI # check if all files are there

### load the image from tar file
cd Unphased-LAI
docker1 load -i lai_unphased.tar
```
Your working directory will be `/workdir/$NETID/Unphased-LAI` (outside the docker container), which will be mounted as `/workdir/Unphased-LAI` inside the docker container. 

Refer to "docker_image_set_up.md" to learn how the tar file was made. 

## Simulate admixed genomes using mixnmatch (need to be run inside the docker interactively)
```
### load the image from tar file
docker1 load -i lai_unphased.tar

### start a Docker container from the image
NETID=yc2644 # update this to your netid
docker1 run -dit biohpc_$NETID/lai_unphased 
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

## Perform Ancestry_HMM on simulated admixed genomes (need to be run inside the docker interactively)
```
### inside the same container where you used mixnmatch simulation
cd /mixnmatch_ancestryinfer_docker/mixnmatch

### run ancestryinfer
## bash_command_for_ahmm.sh usage: bash bash_command_for_ahmm.sh configuration_file.cfg working_directory (local)
bash bash_command_for_ahmm.sh ahmm_configuration_file.cfg /workdir/Unphased-LAI/AHMM
# warning message can be ignored
# test command: bash bash_command_for_ahmm.sh ahmm_configuration_file.cfg /workdir/AHMM_ELAI_comparison/test_ahmm
```

## Perform ELAI on simulated admixed genomes 
```
### In your working directory (outside the container)
exit # if you are in the container, type exit
NETID=yc2644 # update this to your netid
cd /workdir/$NETID/Unphased-LAI
docker1 claim

### convert simulated phased haploypes into unphased diploid genotypes
cd ELAI/01_scripts
bash generate_simulated_genotypes.sh

### prepare input bimbam files for ELAI
cd ../04_bimbam
bash vcf2bimbam.sh

### run ELAI
# note that ELAI's singularity image on Cornell biohpc server doesn't work after system upgrade to Rocky 9
cd ..
git clone https://github.com/haplotype/ELAI.git
mv ELAI/elai-lin elai-lin
bash 01_scripts/01_run_elai.sh &> 01_run_elai.log &
# output files will be in the output folder
```

## Results

