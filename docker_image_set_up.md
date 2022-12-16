# How the Docker image was set up for this project

## Already done for you, the Docker image can be loaded from docker hub "yuqingchen/unphased-lai")

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
# vim open "simulate_admixed_genomes_v6.pl", comment out line 560 `#print CLEANUP "rm macs_simulation_results_trees*"."\n";` 

### modify the perl script "generate_genomes_and_reads_v3.pl"
## IMPORTANT; to solve the problem of gzip keeps prompting for overlapped files especially when re-running ##
# vim open "generate_genomes_and_reads_v3.pl", add "-f" to line 113 after "gzip" so that it writes `system("gzip -f $r1 $r2")";` 

### modify the perl script "post_hmm_accuracy_shell.pl"
## IMPORTANT; to keep the hard call files based on ahmm results ##
# vim open "post_hmm_accuracy_shell.pl", comment out line 34 `system("rm accuracy_indiv*");` 

### add bash command files to corresponding folders
cp /workdir/Unphased-LAI/bash_command_for_mixnmatch.sh /mixnmatch_ancestryinfer_docker/mixnmatch
cp /workdir/Unphased-LAI/bash_command_for_ahmm.sh /mixnmatch_ancestryinfer_docker/ancestryinfer

### exit and commit the container to a new Docker image
# type exit
docker1 stop $CID
docker1 commit $CID unphased_lai # saved as biohpc_$NETID/unphased_lai

### save your image to a tar file
NETID=yc2644 # update this to your netid
docker1 save -o unphased_lai.tar biohpc_yc2644/unphased_lai
# or docker1 save biohpc_$NETID/unphased_lai | gzip > unphased_lai.tar.gz

### download the tar file to local machine
## load the image from tar file
docker load -i unphased_lai.tar
## tag private images with newly created Docker ID
docker tag biohpc_yc2644/unphased_lai yuqingchen/unphased-lai
## push the image to docker hub
docker push yuqingchen/unphased-lai
# latest: digest: sha256:284cb2887fdf62ffbe2fc5ea3d414fd7c20fe5433499a6918cfb10576a648748 size: 6419
```