import sys, os
#import argparse
import timeit
from datetime import datetime

# force PYTHONPATH to look into the project directory for modules
sys.path.insert(0, os.getcwd())
from Scripts.Scripts_pooling import poolvcf
from Scripts.Scripts_pooling import pybcf

'''
Applies pooling simulation to a VCF file

* the input VCF file contains variants of type SNP only, with genotype formatted as GT,
* the output VCF file contains the same variants, formatted as GL,
* the number of samples is a multiple of 16 (block's size in the DNA Sudoku design implemented).
The decoding step of pooling is adaptive with respect to the pooling pattern observed (see README.md)
* the samples are assumed to be sorted in row-order flattened blocks order e.g. the 16 first columns in the VCF file
correspond  to the samples assigned to the first block. 
Samples 1-4 form the first pool in the block, samples 5-8 the second pool, and so on.
* the output file has to be written to unbgzipped format (.vcf) and then compressed to 
bgzipped format (.vcf.gz) with bcftools.

For VCF-file bigger than some dozen of thousands of variants, pooling can be parallelized.

Command line usage (assuming the current directory is genotypooler/examples)
$ python3 -u pooling-ex.py <path-to-file-in> <path-to-file-out> <decoding-format> <noise>

Examples for GP and GT decoding formats (assuming current directory is /examples):
python3 -u pooling-ex.py TEST.chr20.snps.gt.vcf.gz TEST.chr20.pooled.snps.gp.vcf.gz GP False
python3 -u pooling-ex.py TEST.chr20.snps.gt.vcf.gz TEST.chr20.pooled.snps.gt.vcf.gz GT True
'''

adaptivegls_path = snakemake.params['adaptivegls_path']
filin = snakemake.input[0]
filout = snakemake.output[0]
noise = snakemake.params['noise']
noise_intensity = snakemake.params['noise_intensity']
fmt = snakemake.params['fmt']
call_freq_v = snakemake.params['call_freq_v']
plookup = os.path.join(adaptivegls_path, 'adaptive_gls.csv')  # look-up table for converting pooled GT to GL

# make sure to write to .vcf
if filout.endswith('.gz'):
    vcfout = filout[:-3]
if filout.endswith('.vcf'):
    vcfout = filout

### CREATING METADATA FILES FOR NOISE
if noise:
    date = datetime.now()
    date_str = str(date)
    year = str(date.year)
    month = str(date.month)
    day = str(date.day)
    hour = str(date.hour)
    minute = str(date.minute)
    second = str(date.second)
    formated_date = f"{year}-{month}-{day} {hour}:{minute}:{second}"
    noise_SNPs = open("noise_SNPs.txt", "a")
    noise_SNPs.write("\n" + '\n'.rjust(80, '-'))
    noise_SNPs.write("\n" + formated_date)
    noise_SNPs.write("\n" + "POS" + "\t"+ "PREVIOUS_GENOTYPE" + "\t" + "NEW_GENOTYPE")
    noise_SNPs.close()

    incompatible_genotypes = open("incompatible_genotypes.txt", "a")
    incompatible_genotypes.write("\n"+'\n'.ljust(30, '-')+ "\t" + formated_date + "\t" + '\$')
    incompatible_genotypes.write("CHROM" + "\t" + "POS" + "\t" + "ID")
    incompatible_genotypes.close()
else:
    pass

### SIMULATE POOLING
start = timeit.default_timer()
if fmt == 'GP':
    poolvcf.pysam_pooler_gp(noise=noise, noise_intensity=noise_intensity, file_in=filin, file_out=vcfout, path_to_lookup=plookup, wd=os.getcwd(), call_freq_v = call_freq_v)
if fmt == 'GT':
    poolvcf.pysam_pooler_gt(noise=noise, noise_intensity=noise_intensity, file_in=filin, file_out=vcfout, path_to_lookup=plookup, wd=os.getcwd(), call_freq_v = call_freq_v)

print('\r\nTime elapsed --> ', timeit.default_timer() - start)

### PRINT NUMBER OF SNPS WITH ADDED NOISE AND CREATE FILE PER RUN
if noise:
    SNP_file = open(f"{year}-{month}-{day}_{hour}.{minute}.{second}_noise_SNPs.txt", "a")
    SNP_file.write("POS" + "\t"+ "PREVIOUS_GENOTYPE" + "\t" + "NEW_GENOTYPE" + "\n")
    with open("noise_SNPs.txt", "r") as noise_SNPs:
        count = 0
        lines = noise_SNPs.readlines()
        for line in lines:
            if line.find(formated_date) != -1:
                start_count = lines.index(line)
                for SNP in lines[start_count+2:]:
                    count += 1
                    SNP_file.write(SNP)
        print('\n'.ljust(55, '-'))
        print('Total quantity of SNPs with added noise:',int(count))
        print('\n'.rjust(55, '-'))
    noise_SNPs.close()
else:
    pass

