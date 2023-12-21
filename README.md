# Genome sequence of the plant growth-promoting bacterium _Bacillus velezensis_ EU07
This repo accompanies our manuscript submitted to _Access Microbiology_: 


### Genome sequence assembly
Genome sequence plant-growth-promoting bacterium Bacillus velezensis EU07.
Ömür Baysal, David J. Studholme, Catherine Jimenez-Quiros & Mahmut Tör.

Here you can find details of the command lines used to perform the analyses presented in that manuscript.

The genome sequence was previously assembled from Illumina MiSeq reads using SPAdes, as described here: [README_assembly.md](./assembly/README_assembly.md) and submitted to GenBank, via NCBI.
It is accessible here: https://www.ncbi.nlm.nih.gov/nuccore/JAIFZJ000000000.

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
Assumes that we have a list of the required genomes in this file: [all_genomes_09_12_23.txt](./phame/all_genomes_09_12_23.txt)
```
mkdir all_genomes
cd all_genomes

ln -s ../bacillus_EU07/phame/all_genomes_09_12_23.txt .
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
This requires files [query_list.txt](./fastani/query_list.txt) and [ref_list.txt](./fastani/ref_list.txt).
```
mkdir fastani
cd fastani/
ln -s ../bacillus_EU07/query_list.txt .
ln -s ../bacillus_EU07/ref_list.txt .
conda activate fastani_env
fastANI --ql query_list.txt --rl ref_list.txt -o all-versus-all.fastANI.out -t 6 --visualize --matrix
```
This generates the following fastANI output files:
- [all-versus-all.fastANI.out](./fastani/all-versus-all.fastANI.out)
- [all-versus-all.fastANI.out.matrix](./fastani/all-versus-all.fastANI.out.matrix)



### In preparation for phylogenomics analysis, rename genome sequence files with strain names:
This requires [genomes_for_phame.txt](./phame/genomes_for_phame.txt) file that maps accession numbers to strain names.
```
cd all_genomes/
ln -s ../bacillus_EU07/phame/rename_files.pl .
ln -s ../bacillus_EU07/phame/genomes_for_phame.txt .
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

### Get [config file](./phame/Bacillus_velezensis_EU07.phame.ctl) for PhaME from the local copy of this repo:
```
ln -s ./bacillus_EU07/phame/phame.ctl .
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
PhaME creates the following output tree files:
- FastTree:
  - [Bacillus_velezensis_EU07_all.fasttree](./Bacillus_velezensis_EU07_all.fasttree)
- IQtree:
  - [Bacillus_velezensis_EU07_all_snp_alignment.fna.treefile](./Bacillus_velezensis_EU07_all_snp_alignment.fna.treefile)
  - [Bacillus_velezensis_EU07_all_snp_alignment.fna.boottrees](./Bacillus_velezensis_EU07_all_snp_alignment.fna.boottrees)
  - [Bacillus_velezensis_EU07_all_snp_alignment.fna.contree](./Bacillus_velezensis_EU07_all_snp_alignment.fna.contree)
- RAxML:
  - [RAxML_bestTree.Bacillus_velezensis_EU07_all](./RAxML_bestTree.Bacillus_velezensis_EU07_all)
  - [RAxML_bootstrap.Bacillus_velezensis_EU07_all_b](./RAxML_bootstrap.Bacillus_velezensis_EU07_all_b)
  - [RAxML_parsimonyTree.Bacillus_velezensis_EU07_all](./RAxML_parsimonyTree.Bacillus_velezensis_EU07_all)
  - [RAxML_result.Bacillus_velezensis_EU07_all](./RAxML_result.Bacillus_velezensis_EU07_all)
  
### As an alternative to PhaME, we can also use REALPHY for phylogenomic analysis:
REALPHY requires a [config.txt](./realphy/config.txt) file.

```
mkdir realphy
cd realphy

mkdir genomes_for_realphy
cd genomes_for_realphy
ln -s ../../all_genomes/*.fasta .
cd ..

mkdir realphy_output
cd realphy_output/
ln -s ../../bacillus_EU07/realphy/config.txt .
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
A gzipped output file Bacillus_EU07_clade.xmfa can be found here: [Bacillus_EU07_clade.xmfa.gz](./mauve/Bacillus_EU07_clade.xmfa.gz).


### Use Parsnp to compare genomes:
Assumes that we have already downloaded NCBI _datasets_ command-line tool.
```
./datasets download genome accession GCF_003073255.1 --include-gbff
unzip ncbi_dataset.zip
ln -s ncbi_dataset/data/GCF_003073255.1/genomic.gbff ./QST713.gbk

./parsnp -g ./QST713.gbk -d ./genomes -p 4
```

The resulting Parsnp output file [parsnp.ggr](./harvest/parsnp.ggr) can then be opened in Gingr and the variants exported in VCF format:
- [variants.vcf](./harvest/variants.vcf)

  


