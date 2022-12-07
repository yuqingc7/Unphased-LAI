#!/bin/bash -l

# this script runs ELAI
# usage: bash 01_run_elai.sh 

## start date
start=`date +%s`

cd /workdir/yc2644/Unphased-LAI/ELAI

POP1=par1
POP2=par2
POP3=admixed
NUMREP=10
NUMGEN=50

echo "$POP1" "$POP2" "$POP3" "$NUMGEN"

# loop over replicates
for replicate in $(seq -w "$NUMREP")
do
    echo "$replicate"
    ./elai-lin -g 04_bimbam/$POP1".recode.geno.txt" -p 10 \
        -g 04_bimbam/$POP2".recode.geno.txt" -p 11 \
        -g 04_bimbam/$POP3".recode.geno.txt" -p 1 \
        -pos 04_bimbam/$POP3".recode.pos.txt" \
        -o $POP1"_"$POP2"_"$POP3".numgen"$NUMGEN".replicate"$replicate \
        -C 2 -c 10 -mg $NUMGEN -s 30
done

# end date
end=`date +%s`
runtime=$((end-start))
hours=$((runtime / 3600))
minutes=$(( (runtime % 3600) / 60 ))
seconds=$(( (runtime % 3600) % 60 ))
echo "01_run_elai.sh Runtime: $hours:$minutes:$seconds (hh:mm:ss)"
