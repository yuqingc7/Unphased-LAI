#!/bin/bash

# this script converts vcf files to bimbam formats for ELAI input
# usage: bash vcf2bimbam.sh

for pop in "admixed" "par1" "par2"
do
    /programs/plink-1.9-x86_20210606/plink --vcf ../03_vcf/$pop".vcf" --chr-set 1 --chr 1 --recode bimbam --out $pop
done

# output includes:
# log, nosex, geno.txt, pheno.txt, pos.txt
