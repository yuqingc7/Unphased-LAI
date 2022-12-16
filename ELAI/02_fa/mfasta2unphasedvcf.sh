#!/bin/bash

# this script converts aligned mfasta to diploid genotype vcf (unphased)
# usage: bash mfasta_to_unphasedvcf.sh combined_50.fa combined_50.vcf 50
# example: bash mfasta_to_unphasedvcf.sh FASTA_file OUTPUT_VCF_file NUM_IND

FA=$1
VCF=$2
NUMIND=$3

NETID=yc2644
FADIR=/workdir/Unphased-LAI/ELAI/02_fa

# run snp-sites
docker1 run --rm biohpc_$NETID/lai_unphased snp-sites -v -o $FADIR/$VCF $FADIR/$FA
# test command: 
# docker1 run --rm biohpc_yc2644/lai_unphased snp-sites -v -o /workdir/AHMM_ELAI_comparison/ELAI_test/02_fa/combined_100.vcf /workdir/AHMM_ELAI_comparison/ELAI_test/02_fa/combined_100.fa

# merge unphased 
MAXK=$(( 9+NUMIND ))

for k in $(eval echo "{10..$MAXK}")
do
        #echo "$k"
        sed -i "s=\t=\\/=$k" "$VCF"
done


for m in $(eval echo "{1..$NUMIND}")
do
        #echo "$m"
        sed -i "s=indiv${m}_hap1\\/indiv${m}_hap2=indiv${m}=g" "$VCF"
done

