#Downloading all necessary packages
ml python/3.6.8
python3.6 -m venv venv3.6
source venv3.6/bin/activate
pip install --upgrade pip
pip install -r Data/requirements.txt
ml bioinfo-tools
ml bcftools/1.14
ml htslib/1.14
ml tabix/0.2.6
ml pysam


python3 -u Scripts/Scripts_evaluation/quantiles_plots.py @argsfile.txt
