# Project Applied Bioinformatics 2022 - SnakeMake pipeline
**Elias Ekstedt, Philip MacCormack & Klara Solander**

This project is based on the work by Clouard *et al.* 2022, their proposed simulation can be found in the following [GitHub repository](https://github.com/camcl/genotypooler), and their imputation algorithm *Prophaser* can be found in the following [GitHub repository](https://github.com/kausmees/prophaser).

## Scripts
This folder contains the scripts written by Clouard *et al.* 2022, with the addition of noise simulation code as well as neccessary SnakeMake adaptation. 

#### Scripts_data_splitting

##### data_splitting.py
This script takes the genotype dataset as input, and splits the samples within the dataset into a reference population and a study population. Each of these subsets contains the entire set of markers, but individual subsets of samples. The script used here is essentially unchanged from the original version given by Clouard et. al 2022, with the exception of creating compatibility with SnakeMake.

#### Scripts_pooling

##### files.py
This script contains personal tools for files management.

##### pooling-ex.py
This script is the first one called when using the pooling rule. The input of the script is the study population created, as well as the flags *--noise* and *--noise_intensity. The flags are utilized to add noise to the simulation and adjust the intensity of the noise by stating the intensity value [0-1]. In this script, the  the terminal outputs are created, and the inputs are forwarded to *poolvcf.py*.

##### poolvcf.py
This scripts takes the input provided by *pooling-ex.py* and can be viewed as the superficial layer of pooling, where one can control different parameters within the pooling. In this script text file containing the SNPs that are altered in each run, in addition to individual files containing the same information are created. The reasoning for this is to facilitate comprehensive analysis for multiple runs, and for the current run. Further, code to enable printing of the original genotype, the genotype after noise is added and the pooling matrix if an incompatible decoding result arises to a txt file. This to enable analysis of issues that the Clouard et al. 2022 algorithm may adjust for. 

The class method add_noise has been implemented within the class VariantFilePooler, within the poolvcf.py script. In this method the call rate value for each individual SNP is compared to a variable generated for random uniform sampling. If the call rate value is larger than the sampled value , noise is added to the SNP, otherwise it is not. Through the noise intensity flag, the user is able to adjust the lower limit of the uniform sampling, and can thus influence the probability with which noise is added to the simulation. As a result, one can add more noise to the simulation by increasing the value of the noise intensity parameter. Based on the initial genotype, the noise is added as follows:

* If the initial genotype is [0,0] - the genotype post-noise is [1,0]
* If the initial genotype is [1,0] - the genotype post-noise is either [0,0] or [1,1] with equal probabilities
* If the initial genotype is [1,1] - the genotype post-noise is [1,0]

The implications of this step are that the same SNP, which can be found in two different pools, can output two different genotype results, consistent with how noise affects results in real life. 


##### pooler.py
This script takes the input provided by *pooling-ex.py* and applies the algorithm for pooling, creating the foundation which *poolvcf.py* utilizes. As decoding relies on consistent results in the intersection between pools to be able to draw inferences about the individual genotypes, changing the genotype of a SNP in one pool and not in the other results in what is referred to as “inconsistent scenarios”. As the decoding was previously built assuming no genotype error, there was no infrastructure to support this scenario. The final segment in which noise implementation code is therefore added in pooler.py, within the class DictBlockDecoder in the function decode_genotypes_gp, where decoding takes place. The implementation gives inconsistent scenarios equal genotype probabilities for all genotypes, which is applied to all samples within the affected pool. 

##### pybcf.py
This scripts contains bash commands for bcftools manipulations written as Python-functions to increase readability.

##### utils.py
This script contains utilities for data sets processing.

#### Scripts_imputation

##### Beagle
This folder contains all scripts necessary to run Beagle, a software for imputation. A tutorial for Beagle can be found in the following [Github Repository](https://github.com/adrianodemarino/Imputation_beagle_tutorial)

##### Prophaser
This folder contains all scripts necessary to run Prophaser, an imputation software created by Clouard *et. al* 2022. A tutorial for Prophaser can be found in the following [Github Repository](https://github.com/kausmees/prophaser)

#### Scripts_evaluation

##### imputation_quality.py
This script computes the results with customized metrics from true vs. imputed data sets.

##### quality.py
This script creates metrics for assessing imputation quality.

##### test_qual.py & run_test_qual.sh
*test_qual.py* plots the metrics, and *run_test_qual.sh* is the script utilized to run *test_qual.py*.

##### chunkvcf.py
This script enables parallelization by creating "chunks" of data to forward into the relevant scripts.

##### dataframe.py
This script converts data into dataframes to allow downstream analysis. 

## References 
Clouard C, Ausmees K, Nettelblad C. A joint use of pooling and imputation for genotyping SNPs. BMC Bioinformatics. 2022 Oct 13;23(1):421. doi: 10.1186/s12859-022-04974-7. PMID: 36229780; PMCID: PMC9563787.
