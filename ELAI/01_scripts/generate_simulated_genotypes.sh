#!/bin/bash

# this script generates unphased diploid genotypes from mixnmatch output
# usage: bash generate_simulated_genotypes.sh 

## start date
start=`date +%s`

NETID=yc2644 # update this to your netid
WORKDIR=/workdir/$NETID/Unphased-LAI

INDIR=$WORKDIR/mixnmatch_simulation
FADIR=$WORKDIR/ELAI/02_fa
VCFDIR=$WORKDIR/ELAI/03_vcf

# collect fasta files
cd $INDIR/simulated_hybrids_reads_*
cat *.fa > $FADIR/admixed_n50.fa # 100 hapltypes for 50 individuals
cp $INDIR/macs_simulation_results_trees.par1.fa $FADIR/par1_n25.fa # 50 haplotypes for 25 individuals
cp $INDIR/macs_simulation_results_trees.par2.fa $FADIR/par2_n25.fa # 50 hapltoypes for 25 individuals

cd $FADIR
# create haplotype lists for two source populations
less par1_n25.fa | grep ">" | sed 's/>//g' > par1_hap.list
less par2_n25.fa | grep ">" | sed 's/>//g' > par2_hap.list

# need to use snp-sites on all fasta files for 
# both source populations and admixed populations at the same time
cat *fa > combined_100.fa
# run snp-sites & merge phased haplotypes into unphased diploid genotypes
bash mfasta2unphasedvcf.sh combined_100.fa combined_100.vcf 100

# set ID in vcf files (needed by ELAI)
bcftools annotate --set-id '%CHROM:%POS' combined_100.vcf > combined_100_annotated.vcf

# get sample ids for each population
mv combined_100_annotated.vcf $VCFDIR
cd $VCFDIR

grep "^#CHROM" combined_100_annotated.vcf | tr '\t' '\n' | grep -v -E '#CHROM|POS|ID|REF|ALT|QUAL|FILTER|INFO|FORMAT' > samples_id_n100.txt
split -dl 50 samples_id_n100.txt samples_id_
mv samples_id_00 $VCFDIR/samples_id_admixed_n50.txt
split -dl 25 samples_id_01 samples_id_2
rm samples_id_01
mv samples_id_200 samples_id_par1_n25.txt
mv samples_id_201 samples_id_par2_n25.txt

# subsample vcf files for each population
bash subsample_vcf.sh combined_100_annotated samples_id_admixed_n50.txt admixed
bash subsample_vcf.sh combined_100_annotated samples_id_par1_n25.txt par1
bash subsample_vcf.sh combined_100_annotated samples_id_par2_n25.txt par2

# end date
end=`date +%s`
runtime=$((end-start))
hours=$((runtime / 3600))
minutes=$(( (runtime % 3600) / 60 ))
seconds=$(( (runtime % 3600) % 60 ))
echo "generate_simulated_genotypes.sh Runtime: $hours:$minutes:$seconds (hh:mm:ss)"
