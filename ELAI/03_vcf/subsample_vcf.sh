#!/bin/bash -l

# this script subsamples vcf files by given sample list
# usage: bash subsample_vcf.sh VCF_PREFIX SAMPLE_LIST POP_NAME
# example: bash subsample_vcf.sh combined_100_annotated samples_id_admixed_n50.txt admixed

PREFIX=$1
SAMPLE=$2
POP=$3


if [[ ! -f $PREFIX.vcf.gz ]]; then
    /programs/htslib-1.16/bin/bgzip $PREFIX.vcf
    /programs/htslib-1.16/bin/tabix -f -p vcf $PREFIX.vcf.gz
fi

bcftools view -Oz -S $SAMPLE $PREFIX.vcf.gz > $POP.vcf.gz

gunzip -c $POP.vcf.gz > $POP.vcf
