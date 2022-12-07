# How the Docker image was set up for this project

## Already done for you, the Docker image can be loaded from the tar file "lai_unphased.tar")

```
### pull the image from DockerHub
docker1 pull schumer/mixnmatch-ancestryinfer-image:mixnmatch-ancestryinfer-docker

### start a Docker container
docker1 run -dit schumer/mixnmatch-ancestryinfer-image:mixnmatch-ancestryinfer-docker
docker1 ps -a

### run the Docker container
export CID=xxxxxxxx # replace xxxxxxxx with the "CONTAINER ID"
docker1 exec -it $CID bash

### inside the container, install packages that we need
apt update
apt install -y google-perftools vim less wget git build-essential software-properties-common
apt-get install snp-sites

### modify the perl script "simulate_admixed_genomes_v6.pl"
## IMPORTANT; by default, the program will delete intermediate haplotype files that we need for ELAI) ##
cd /mixnmatch_ancestryinfer_docker/mixnmatch
# vim open "simulate_admixed_genomes_v6.pl", comment out line 561 `#print CLEANUP "rm macs_simulation_results_trees*"."\n";` 

### modify the perl script "generate_genomes_and_reads_v3.pl"
## IMPORTANT; to solve the problem of gzip keeps prompting for overlapped files especially when re-running ##
cd /mixnmatch_ancestryinfer_docker/mixnmatch
# vim open "generate_genomes_and_reads_v3.pl", add "-f" to line 113 after "gzip" so that it writes `system("gzip -f $r1 $r2")";` 

### add bash command files to corresponding folders
cp /workdir/Unphased-LAI/bash_command_for_mixnmatch.sh /mixnmatch_ancestryinfer_docker/mixnmatch
cp /workdir/Unphased-LAI/bash_command_for_ahmm.sh /mixnmatch_ancestryinfer_docker/ancestryinfer

### exit and commit the container to a new Docker image
# type exit
docker1 stop $CID
docker1 commit $CID lai_unphased # saved as biohpc_$NETID/lai_unphased

### save your image to a tar file
NETID=yc2644 # update this to your netid
docker1 save -o lai_unphased.tar biohpc_$NETID/lai_unphased
```
