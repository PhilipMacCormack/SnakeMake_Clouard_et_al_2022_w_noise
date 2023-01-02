#!/bin/bash


# all paths are relative Applied_Biounformatics_2022/   (assumed this script is executed from phaser/examples)

ne=11418
error=0.001
mapfile=Scripts/Scripts_imputation/Prophaser/5_snps_interpolated_HapMap2_map_20
indir=Output/
sample_file=IMP.chr20.pooled.snps.gl.vcf.gz
ref_file=REF.chr20.snps.gt.vcf.gz
results_directory=Output/

# parameters for the linear_state  branch
algo=integrated
algo=separate
algo=fixed
niter=3



Scripts/Scripts_imputation/Prophaser/create_template_vcf.sh $indir $sample_file
Scripts/Scripts_imputation/Prophaser/create_template_vcf_gtgp.sh $indir $sample_file

##### assuming the master branch has been compiled to this executable
Scripts/Scripts_imputation/Prophaser/phase --results_directory $results_directory  --directory $indir --sample_file $sample_file --reference_file $ref_file --ne $ne --map $mapfile --error $error

##### assuming the linear-state branch has been compiled to this executable
#./phase_linear_state --map $mapfile  --results_directory $results_directory  --directory $indir --sample_file $sample_file --reference_file $ref_file  --iterations  $niter --ne $ne --error $error --algorithm $algo





