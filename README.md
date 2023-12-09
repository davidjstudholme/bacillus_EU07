# bacillus_EU07
Bioinformatics analysis to support manuscript submitted to Access Microbiology

```
conda  create -n fastani_env fastani
conda activate fastani_env
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


### Create directory for ANI analysis
mkdir fastani
cd fastani/



```
