#!/bin/bash -l
#SBATCH -A snic2022-22-697 
#SBATCH -p node
#SBATCH -C mem128GB
#SBATCH -n 8
#SBATCH -t 10:00:00
#SBATCH -J prophaser_sample_noise
### assumes current directory is /crex/proj/snic2019-8-216/private/phaser-multilevel/20210621
module load bioinfo-tools
module load bcftools/1.9
module load tabix/0.2.6

bash Scripts/Scripts_imputation/Prophaser/run_omniHD_snowy.sh $1 $2 $3 $4 $5 # should use 16 OMP threads


#{params.indir} {params.mapfile} {params.samples_file} {params.ref_file} {params.results_directory}
