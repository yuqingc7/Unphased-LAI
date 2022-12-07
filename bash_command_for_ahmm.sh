#!/bin/bash

# this script runs ancestryinfer (Ancestry_HMM) with corresponding configuration file from working directory and copy the outputs to working directory
# usage: bash bash_command_for_ahmm.sh configuration_file.cfg working_directory (local)
# example usage: bash bash_command_for_ahmm.sh ahmm_configuration_file.cfg /workdir/Unphased-LAI/AHMM

## start date
start=`date +%s`

CONF=$1
WORKDIR=$2

# run the simulation
cp $WORKDIR"/"$CONF /mixnmatch_ancestryinfer_docker/ancestryinfer
perl Ancestry_HMM_parallel_v5.pl $CONF

# save the files to working directory
cp -r *tsv ancestry-probs_allchrs.tsv_rec.txt_ancestrytransitions_allchrs $WORKDIR/output

# end date
end=`date +%s`
runtime=$((end-start))
hours=$((runtime / 3600))
minutes=$(( (runtime % 3600) / 60 ))
seconds=$(( (runtime % 3600) % 60 ))
echo "bash_command_for_ahmm.sh Runtime: $hours:$minutes:$seconds (hh:mm:ss)"
