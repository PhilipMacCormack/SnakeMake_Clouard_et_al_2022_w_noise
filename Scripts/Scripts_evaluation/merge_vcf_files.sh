#!/bin/bash

# Merge all individually imputed samples into an imputed study population

#indir= "../../Output/prophaser"
#outdir=/../../Output/prophaser

module load bioinfo-tools && module load bcftools/1.9


files=$( ls Output/prophaser/*.full.genos.vcf.gz )
echo $files

for file in $files
do
	bcftools index -f $file
done

#mkdir Output/for_evaluate_prophaser/

bcftools merge -Oz -o Output/for_evaluate_prophaser/IMP.chr20.pooled.imputed.vcf.gz $files
bcftools index Output/for_evaluate_prophaser/IMP.chr20.pooled.imputed.vcf.gz
