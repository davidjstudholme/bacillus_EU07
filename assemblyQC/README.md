We examined the quality of the genome assembly using two tools:
- QUAST (to check contiguity)
- Qualimap (to check coverage by sequencing reads)

### Download the genome sequence from GenBank
```
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/023/337/195/GCA_023337195.1_ASM2333719v1/GCA_023337195.1_ASM2333719v1_genomic.fna.gz
gunzip GCA_023337195.1_ASM2333719v1_genomic.fna.gz
```

### Aligned genomic sequence reads against the genome assembly using BWA-mem 0.7.17 and SAMtools 1.13
```
bwa mem GCA_019997305.2_ASM1999730v2_genomic.fna EU07.1.fq.gz EU07.2.fq.gz > EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.sam.3490300~ && mv EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.sam.3490300~ EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.sam

samtools view -bS -q 1 -T GCA_019997305.2_ASM1999730v2_genomic.fna EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.sam > EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.bam.3490300~ && mv EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.bam.3490300~ EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.bam

samtools sort EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.bam > EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.bam.sorted.bam

samtools rmdup -s EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.bam.sorted.bam  EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.sorted.rmdup.bam.3490300~ && mv EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.sorted.rmdup.bam.3490300~ EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.sorted.rmdup.bam

samtools index EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.sorted.rmdup.bam
```

### Run Qualimap 2.3
Assumes that we already:
- downloaded Qualimap from https://bitbucket.org/kokonech/qualimap/downloads/qualimap_v2.3.zip
- unzipped it
- made a symbolic link to the executable in the current working directory 
```
./qualimap bamqc -bam EU07.versus.GCA_019997305.2_ASM1999730v2_genomic.aln.sorted.rmdup.bam
```

### Run QUAST v5.2.0
Assumes we have already installed QUAST into a Conda environment and activated the environment.
```
quast.py -s GCA_019997305.2_ASM1999730v2_genomic.fna
```
