import sys, os


# force PYTHONPATH to look into the project directory for modules
rootdir = os.path.dirname(os.getcwd())
sys.path.insert(0, os.getcwd())
print('Shuffle split into file for REF and IMP populations')

from Scripts.Scripts_pooling import poolvcf
from Scripts.Scripts_pooling.pooler import Design

ds = Design()
dm = ds.matrix

sfsp = poolvcf.ShuffleSplitVCF(dm, snakemake.input[0], stu_size=0.1, wd=os.getcwd())
sfsp.split_file('chr20.snps.gt.vcf.gz')

