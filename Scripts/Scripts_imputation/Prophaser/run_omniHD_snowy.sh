#!/bin/bash


# all paths are relative phaser-multilevel/   (assumed this script is executed from phaser-multilevel/20210621)

ne=11418
error=1e-12


# ---------------------------
indir=$1
mapfile=$2
sample=$SLURM_ARRAY_TASK_ID
samples_file=$3
ref_file=$4
results_directory=$5
# ---------------------------


# parameters for the linear_state  branch
algo=integrated
algo=separate
algo=fixed
niter=3

# write 1 file for every sample
sampleId=$( bcftools query -l $indir$samples_file | head -$sample | tail -1 )
sample_file=$sampleId.$samples_file
bcftools view -Oz -s $sampleId -o $indir$sample_file $indir$samples_file

Scripts/Scripts_imputation/Prophaser/create_template_vcf.sh $indir $sample_file
Scripts/Scripts_imputation/Prophaser/create_template_vcf_gtgp.sh $indir $sample_file


export OMP_NUM_THREADS=16 # 16 cores on Snowy nodes

##### assuming the master branch has been compiled to this executable
echo "# --------------------------------"
echo "indir             : "$indir
echo "mapfile           : "$mapfile
echo "sample            : "$sample
echo "sample_file       : "$samples_file
echo "ref_file          : "$ref_file
echo "results_directory : "$results_directory
echo "# --------------------------------"
#Scripts/Scripts_imputation/Prophaser/phase --results_directory $results_directory  --directory "./" --sample_file "Output/pooling/"$sample_file --reference_file $ref_file --ne $ne --map $mapfile --error $error
Scripts/Scripts_imputation/Prophaser/phase --results_directory $results_directory  --directory $indir --sample_file $sample_file --reference_file $ref_file --ne $ne --map $mapfile --error $error 

echo "creating prophaser_output.txt"
echo "pipeline assumes that if this file exists, the output has been created as expected" > "$results_directory""prophaser_output.txt"

# clean file
echo "cleaning in "$indir$sample_file
rm $indir$sample_file
