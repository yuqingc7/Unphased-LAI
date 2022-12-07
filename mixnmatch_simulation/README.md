# Configuration file
Options in the configuration file can be found here: [mixnmatch github repo](https://github.com/Schumerlab/mixnmatch/blob/master/mixnmatch_usermanual.pdf). 

# MACS command
Refer to [macs github repo](https://github.com/gchen98/macs). 
```
macs_params=200 10000000 -I 2 100 100 0 -t 0.001 -h 1e2 -r 0.001 -ej 2 2 1
# sample size is 200 (100 haplotypes per population), region length of 10,000,000 bp = 10 Mb
# -I sets migration for 2 populations(each has a size of 100), migration rate is 0
# -t sets mutation rate per site per 4N generations to be 0.001
# -h sets number of previous base pairs to retain is 100
# -r sets recombination rate per site per 4N generations to be 0.001 (base line recombination rate)
# -ej sets at time 2, all chromosomes migrate from population 2 to population 1 (join two populations)
# -R sets recombination map (sets recombination for different positions with respect to base line recombination rate; not set here)
```



