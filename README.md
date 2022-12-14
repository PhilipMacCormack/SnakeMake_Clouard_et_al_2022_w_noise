# Project Applied Bioinformatics 2022 - SnakeMake pipeline
**Elias Ekstedt, Philip MacCormack & Klara Solander**

This project is based on the work by Clouard *et al.* 2022, their proposed simulation can be found in the following [GitHub repository](https://github.com/camcl/genotypooler), and their imputation algorithm *Prophaser* can be found in the following [GitHub repository](https://github.com/kausmees/prophaser).

## Scripts
This folder contains the scripts written by Clouard *et al.* 2022, with the addition of noise simulation code as well as neccessary SnakeMake adaptation. 

#### Scripts_data_splitting

##### data_splitting.py
This script takes the genotype dataset as input, and splits the samples within the dataset into a reference population and a study population. Each of these subsets contains the entire set of markers, but individual subsets of samples. The script used here is essentially unchanged from the original version given by Clouard et. al 2022, with the exception of creating compatibility with SnakeMake.

#### Scripts_pooling

#### Scripts_imputation

#### Scripts_evaluation


4.3.2 Pooling
The pooling step of the pipeline is the step in which pooling of samples and encoding and decoding of genotypes takes place. The overall structure of the code remains unchanged from the version given by Clouard et. al 2022, with the addition of the noise simulation code. This code also contains small changes for SnakeMake compatibility. 
4.3.3 Imputation
When performing imputation, two options of software are available: Beagle and Prophaser. Within the pipeline, the user may choose which of these is run. The scripts underlying these softwares remain unchanged from their original versions, with the exception of paths being changed. 
4.3.4 Evaluation 
The evaluation step outputs the quality of the imputation for each sample. The script utilized in this step remains largely unchanged from the version given by Clouard et. al 2022, with the exception of SnakeMake compatibility additions. 

## References 
Clouard C, Ausmees K, Nettelblad C. A joint use of pooling and imputation for genotyping SNPs. BMC Bioinformatics. 2022 Oct 13;23(1):421. doi: 10.1186/s12859-022-04974-7. PMID: 36229780; PMCID: PMC9563787.
