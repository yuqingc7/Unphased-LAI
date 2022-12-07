#!/bin/bash

# this script runs mixnmatch with corresponding configuration file from working directory and copy the outputs to working directory
# usage: bash bash_command_for_mixnmatch.sh configuration_file.cfg working_directory (local)

## start date
start=`date +%s`

CONF=$1
WORKDIR=$2

# run the simulation
cp $WORKDIR"/"$CONF /mixnmatch_ancestryinfer_docker/mixnmatch
perl simulate_admixed_genomes_v6.pl $CONF

# prepare for ELAI
cp -r macs_simulated_parent*.fa macs_simulation_results_trees* simulated_AIMs_for_AncestryHMM* simulated_hybrids_* simulated_parental_* simulation_ancestry_informative_sites_* $WORKDIR

# prepare for Ancestry_HMM (implemented in ancestryinfer)
mkdir /mixnmatch_ancestryinfer_docker/ancestryinfer/simulatedata
cp -r macs_simulated_parent1.fa  macs_simulated_parent2.fa  simulated_AIMs_for_AncestryHMM  simulated_hybrids_reads_*  simulated_parental_counts_for_AncestryHMM /mixnmatch_ancestryinfer_docker/ancestryinfer/simulatedata
cp simulated_hybrids_readlist_* /mixnmatch_ancestryinfer_docker/ancestryinfer/

## modify readlist file to contain full path from the program
cd /mixnmatch_ancestryinfer_docker/ancestryinfer
sed -i 's/^/.\/simulatedata\//' simulated_hybrids_readlist_*
sed -i 's/\t/\t.\/simulatedata\//' simulated_hybrids_readlist_*
sed -i '$ d' simulated_hybrids_readlist_* # remove the last line

# end date
end=`date +%s`
runtime=$((end-start))
hours=$((runtime / 3600))
minutes=$(( (runtime % 3600) / 60 ))
seconds=$(( (runtime % 3600) % 60 ))
echo "bash_command_for_mixnmatch.sh Runtime: $hours:$minutes:$seconds (hh:mm:ss)"
