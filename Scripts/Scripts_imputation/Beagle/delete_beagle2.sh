#!/bin/bash

beaglejar=Scripts/Scripts_imputation/Beagle/bin/beagle.11Mar19.69c.jar
cfgtjar=Scripts/Scripts_imputation/Beagle/bin/conform-gt.jar

#path="bashtest/"
#file="subset_Clouard_2022.vcf.gz"
#complete_path="$path$file"
#echo "$complete_path"
#echo "$path"subset""


splitting_path="Output/splitting/"
pooling_path="Output/pooling/"
output_path="Output/beagle/"

out_ref_phased_dedup_vcfgz="$output_path"REF.chr20.phased.dedup.vcf.gz""                #REF.chr20.phased.dedup.vcf.gz
in_ref_snps_gt_vcfgz="$splitting_path"REF.chr20.snps.gt.vcf.gz""                        #REF.chr20.snps.gt.vcf.gz
out_ref_phased_vcfgz="$output_path"REF.chr20.phased.vcf.gz""                            #REF.chr20.phased.vcf.gz
out_ref_phased="$output_path"REF.chr20.phased""                                         #REF.chr20.phased

in_imp_pooled_snps_gl_vcfgz="$pooling_path"IMP.chr20.pooled.snps.gl.vcf.gz""            #IMP.chr20.pooled.snps.gl.vcf.gz
out_imp_pooled_unphased_vcfgz="$output_path"IMP.chr20.pooled.unphased.vcf.gz""          #IMP.chr20.pooled.unphased.vcf.gz
out_imp_pooled_phased_vcfgz="$output_path"IMP.chr20.pooled.phased.vcf.gz""              #IMP.chr20.pooled.phased.vcf.gz
out_imp_pooled_phased_dedup_vcfgz="$output_path"IMP.chr20.pooled.phased.dedup.vcf.gz""  #IMP.chr20.pooled.phased.dedup.vcf.gz
out_imp_pooled_cfgt_vcfgz="$output_path"IMP.chr20.pooled.cfgt.vcf.gz""                  #IMP.chr20.pooled.cfgt.vcf.gz

out_imp_pooled_unphased="$output_path"IMP.chr20.pooled.unphased""                       #IMP.chr20.pooled.unphased
out_imp_pooled_phased="$output_path"IMP.chr20.pooled.phased""                           #IMP.chr20.pooled.phased
out_imp_pooled_cfgt="$output_path"IMP.chr20.pooled.cfgt""                               #IMP.chr20.pooled.cfgt
out_imp_pooled_imputed="$output_path"IMP.chr20.pooled.imputed""                         #IMP.chr20.pooled.imputed
out_imp_pooled_imputed_vcfgz="$output_path"IMP.chr20.pooled.imputed.vcf.gz""            #IMP.chr20.pooled.imputed.vcf.gz





chrom=$( bcftools query -f '%CHROM\n' $in_ref_snps_gt_vcfgz | head -1 )
startpos=$( bcftools query -f '%POS\n' $in_ref_snps_gt_vcfgz | head -1 )
endpos=$( bcftools query -f '%POS\n' $in_ref_snps_gt_vcfgz | tail -1 )

echo 'Contigs in the reference file'
echo '.................................................................................'
echo 'Chromosome ' $chrom '   Startpos =' $startpos '   Endpos =' $endpos 
echo ''

echo ''
echo 'Check FORMAT field in files for imputation'
echo '.................................................................................'
reftruefmt=$( bcftools query -f '%LINE\n' $in_ref_snps_gt_vcfgz | head -1 | cut -f9 )
echo 'FORMAT in reference panel: ' $reftruefmt
imppoolfmt=$( bcftools query -f '%LINE\n' $in_imp_pooled_snps_gl_vcfgz | head -1 | cut -f9 )
echo 'FORMAT in target: ' $imppoolfmt
echo ''

echo ''
echo 'Check number of samples and number of markers in files for imputation'
echo '.................................................................................'
echo 'reference:'
bcftools query -l $in_ref_snps_gt_vcfgz | wc -l
#bcftools view -H $in_ref_snps_gt_vcfgz | wc -l
echo ''
echo 'target:'
bcftools query -l $in_imp_pooled_snps_gl_vcfgz | wc -l
#bcftools view -H $in_imp_pooled_snps_gl_vcfgz | wc -l
echo ''

echo ''
echo 'Phase reference and target with BEAGLE'
echo '.................................................................................'
echo 'Beagle .jar file used at:' $beaglejar
echo ''
#java -Xss5m -jar $beaglejar impute=false gtgl=$in_ref_snps_gt_vcfgz out=$out_ref_phased
cp $in_ref_snps_gt_vcfgz $out_ref_phased_vcfgz
bcftools index -f $out_ref_phased_vcfgz
refphasfmt=$( bcftools query -f '%LINE\n' $out_ref_phased_vcfgz | head -1 | cut -f9 )
echo 'FORMAT in the phased ref file:' $refphasfmt 

### two runs for phasing from GL: 1st run from GL to GT:DP:GP (unphased GT)
java -Xss5m -jar $beaglejar impute=false gtgl=$in_imp_pooled_snps_gl_vcfgz out=$out_imp_pooled_unphased
### two runs for phasing from GL: 2nd run from GT:DP:GP to phased GT
### with gt argument, all genotypes in the output file will be phased and non-missing  (Beagle4.1 documentation)
echo ''
java -Xss5m -jar $beaglejar impute=false gt=$out_imp_pooled_unphased_vcfgz out=$out_imp_pooled_phased
bcftools index -f $out_imp_pooled_phased_vcfgz
impphasfmt=$( bcftools query -f '%LINE\n' $out_imp_pooled_phased_vcfgz | head -1 | cut -f9 )
echo 'FORMAT in the phased target file:' $impphasfmt
echo ''

echo ''
echo 'Deduplicate possibly duplicated markers'
echo '.................................................................................'
bcftools norm --rm-dup all -Oz -o $out_imp_pooled_phased_dedup_vcfgz $out_imp_pooled_phased_vcfgz
bcftools index -f $out_imp_pooled_phased_dedup_vcfgz
bcftools norm --rm-dup all -Oz -o $out_ref_phased_dedup_vcfgz $out_ref_phased_vcfgz
bcftools index -f $out_ref_phased_dedup_vcfgz
echo ''

echo ''
echo 'Unify reference and target markers with CONFORM-GT'
echo '.................................................................................'
echo 'conform-gt .jar file used at:' $cfgtjar
### necessary to get proper imputation results and GT:DS:GP fields with gprobs=true
echo ''
java -jar $cfgtjar ref=$out_ref_phased_dedup_vcfgz gt=$out_imp_pooled_phased_dedup_vcfgz chrom=$chrom:$startpos-$endpos out=$out_imp_pooled_cfgt
bcftools index -f $out_imp_pooled_cfgt_vcfgz
echo ''

echo ''
echo 'Impute target from reference with BEAGLE'
echo '.................................................................................'
echo 'Beagle .jar file used at:' $beaglejar
### impute=true must be used with gt= and ref= (Beagle4.1 documentation)
echo ''
java -Xss5m -jar $beaglejar gt=$out_imp_pooled_cfgt_vcfgz ref=$out_ref_phased_vcfgz impute=true gprobs=true out=$out_imp_pooled_imputed
bcftools index -f $out_imp_pooled_imputed_vcfgz
impimpfmt=$( bcftools query -f '%LINE\n' $out_imp_pooled_imputed_vcfgz | head -1 | cut -f9 )
echo 'FORMAT in the imputed target file:' $impimpfmt
echo''

echo ''
echo 'Cleaning directory from log files'
echo '.................................................................................'
rm "$output_path"./*.log""
rm "$output_path"./*cfgt.vcf.gz*"" # files from conform-gt cannot be overwritten
echo 'Done.'
echo ''
