#!/bin/bash

# Merge all individually imputed samples into an imputed study population

indir=$1
suffix=$2
outdir=$( pwd )

module load bioinfo-tools && module load bcftools/1.9

files=$( ls $indir/$suffix )

for file in $files
do
	bcftools index -f $file
done

bcftools merge -Oz -o $outdir/IMP.chr20.pooled.imputed.vcf.gz $files
bcftools index $outdir/IMP.chr20.pooled.imputed.vcf.gz
