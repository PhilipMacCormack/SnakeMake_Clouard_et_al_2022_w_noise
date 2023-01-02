#!/bin/bash

# Merge all individually imputed samples into an imputed study population

#indir=$( pwd )
#outdir=$( pwd )

module load bioinfo-tools && module load bcftools/1.9


files=$( ls ./Output/prophaser/*.full.postgenos.vcf.gz )

echo $files

for file in $files
do
        bcftools index -f $file
done

bcftools merge -Oz -o Output/prophaser/IMP.chr20.pooled.imputed.vcf.gz $files
bcftools index Output/prophaser/IMP.chr20.pooled.imputed.vcf.gz

