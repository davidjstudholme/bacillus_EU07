# bacillus_EU07
Bioinformatics analysis to support manuscript submitted to Access Microbiology

```
conda  create -n fastani_env fastani

conda create -n phame_env phame

```

```
### Get this repo
git clone https://github.com/davidjstudholme/bacillus_EU07.git

### Download NCBI Datasets command line tools
curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v1/linux-amd64/datasets'
chmod u+x datasets 

### Create genomes directory and download genome assemblies 
mkdir all_genomes
cd all_genomes

ln -s ../bacillus_EU07/all_genomes_09_12_23.txt .
ln -s ../datasets .
./datasets download genome accession --inputfile all_genomes_09_12_23.txt --exclude-gff3 --exclude-protein --exclude-rna --exclude-genomic-cds --filename all_genomes_09_12_23.txt.zip

unzip all_genomes_09_12_23.txt.zip
ln -s ncbi_dataset/data/GCA_*/GCA_*.fna .
ls *.fna

cd ..


### Create directory and perform ANI analysis
mkdir fastani
cd fastani/
ln -s ../bacillus_EU07/query_list.txt .
ln -s ../bacillus_EU07/ref_list.txt .
conda activate fastani_env
fastANI --ql query_list.txt --rl ref_list.txt -o all-versus-all.fastANI.out -t 6 --visualize --matrix



### Rename genome sequence files with strain names
cd all_genomes/
ln -s ../bacillus_EU07/rename_files.pl .
ln -s ../bacillus_EU07/genomes_for_phame.txt .

### Set-up the ref/ directory
mkdir ref
cd ref
ln -s ln -s ../all_genomes/DSM7.fasta .
cd ..

### Set-up the workdir/ directory
mkdir workdir
cd workdir
ln -s ../all_genomes/*.contig .
rm DSM7.contig
cd ..

### Get config file for PhaME
ln -s ./bacillus_EU07/phame.ctl .


### Run PhaME
### Shakya, M., Ahmed, S.A., Davenport, K.W. et al. 
### Standardized phylogenetic and molecular evolutionary analysis applied to species across the microbial tree of life. 
### Sci Rep 10, 1723 (2020). 
### https://doi.org/10.1038/s41598-020-58356-1

screen
conda activate phame_env
cp phylogenomics-Xanthomonas-1/phame.ctl .
phame ./phame.ctl

```








```
mkdir realphy
cd realphy

mkdir genomes_for_realphy
cd genomes_for_realphy
ln -s ../../all_genomes/*.fasta .
cd ..

mkdir realphy_output
cd realphy_output/
ln -s ../../bacillus_EU07/config.txt .
cd ..


conda create -n realphy_env
conda activate realphy_env
conda install -c bioconda realphy
conda install phyml
conda install phylip
conda install raxml

conda activate realphy_env
realphy genomes_for_realphy realphy_output -ref Bacillus_amyloliquefaciens_DSM7 


```
