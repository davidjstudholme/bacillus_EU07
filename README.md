# Genome sequence of the plant growth-promoting bacterium _Bacillus velezensis_ EU07
This repo accompanies our manuscript submitted to _Access Microbiology_: 

Genome sequence plant-growth-promoting bacterium Bacillus velezensis EU07.
Ömür Baysal, David J. Studholme, Catherine Jimenez-Quiros & Mahmut Tör.

Here you can find details of the command lines used to perform the analyses presented in that manuscript.

### First, get this repo:
```
git clone https://github.com/davidjstudholme/bacillus_EU07.git
```

### Download _datasets_ from NCBI command-line tools:
```
curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v1/linux-amd64/datasets'
chmod u+x datasets
```

### Create genomes directory and download genome assemblies:
```
mkdir all_genomes
cd all_genomes

ln -s ../bacillus_EU07/all_genomes_09_12_23.txt .
ln -s ../datasets .
./datasets download genome accession --inputfile all_genomes_09_12_23.txt --exclude-gff3 --exclude-protein --exclude-rna --exclude-genomic-cds --filename all_genomes_09_12_23.txt.zip

unzip all_genomes_09_12_23.txt.zip
ln -s ncbi_dataset/data/GCA_*/GCA_*.fna .
ls *.fna

cd ..
```

### Create a Conda environment for fastANI analysis:
```
conda  create -n fastani_env fastani
```

### Create directory and perform ANI analysis:
```
mkdir fastani
cd fastani/
ln -s ../bacillus_EU07/query_list.txt .
ln -s ../bacillus_EU07/ref_list.txt .
conda activate fastani_env
fastANI --ql query_list.txt --rl ref_list.txt -o all-versus-all.fastANI.out -t 6 --visualize --matrix
```

### In preparation for phylogenomics analysis, rename genome sequence files with strain names:
```
cd all_genomes/
ln -s ../bacillus_EU07/rename_files.pl .
ln -s ../bacillus_EU07/genomes_for_phame.txt .
```

### Set-up the ref/ directory:
```
mkdir ref
cd ref
ln -s ln -s ../all_genomes/DSM7.fasta .
cd ..
```

### Set-up the workdir/ directory:
```
mkdir workdir
cd workdir
ln -s ../all_genomes/*.contig .
rm DSM7.contig
cd ..
```

### Get config file for PhaME from the local copy of this repo:
```
ln -s ./bacillus_EU07/phame.ctl .
```

### Create a Conda environment in which to run PhaME:
```
conda create -n phame_env phame
```

### Run PhaME:
Shakya, M., Ahmed, S.A., Davenport, K.W. et al. Standardized phylogenetic and molecular evolutionary analysis applied to species across the microbial tree of life. 
_Sci Rep_ 10, 1723 (2020). https://doi.org/10.1038/s41598-020-58356-1.
```
screen
conda activate phame_env
ln -s .//bacillus_EU07/Bacillus_velezensis_EU07.phame.ctl .
phame ./Bacillus_velezensis_EU07.phame.ctl

```
### As an alternative to PhaME, we can also use REALPHY for phylogenomic analysis:

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

### Use MAUVE contig mover to re-order contigs against reference genome:
Assumes that we have installed mauve-aligner package with sudo apt-get install and downloaded Mauve.jar from https://darlinglab.org/mauve/download.html
Also assumes that we have the genomic DNA fasta files in the current working directory.
```
for i in *.fasta; do echo $i; java -Xmx500m -cp ./mauve_snapshot_2015-02-13/Mauve.jar org.gel.mauve.contigs.ContigOrderer -output $i.reordered -ref Bacillus_amyloliquefaciens_KNU-28_.fasta -draft $i ; done
```

### Perform MAUVE alignment:
```
progressiveMauve --output=Bacillus_EU07_clade.xmfa *.fasta

```

### Use Parsnp to compare genomes:
Assumes that we have already downloaded NCBI _datasets_ command-line tool.
```
./datasets download genome accession GCF_003073255.1 --include-gbff
unzip ncbi_dataset.zip
ln -s ncbi_dataset/data/GCF_003073255.1/genomic.gbff ./QST713.gbk

./parsnp -g ./QST713.gbk -d ./genomes -p 4
```
  


