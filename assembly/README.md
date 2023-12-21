# Assembly of the _B. velezensis_ EU07 genome from Illumina MiSeq reads

### Trim and filter the data using Trim Galore version: 0.6.7 and Cutadapt version: 3.5
```
trim_galore --paired -q 30 EU07_r1.fq.gz  EU07_r2.fq.gz
```

Trim Galore reports are provided here:
- [EU07_r1.fq.gz_trimming_report.txt](../qc/EU07_r1.fq.gz_trimming_report.txt) Read 1
- [EU07_r2.fq.gz_trimming_report.txt](../qc/EU07_r2.fq.gz_trimming_report.txt) Read 2

FASTQC results are provided here for reads before and after trimming:
- [EU07_r1_fastqc.html](../qc/EU07_r1_fastqc.html) Read 1 pre-trimming
- [EU07_r2_fastqc.html](../qc/EU07_r2_fastqc.html) Read 2 pre-trimming
- [EU07_r1_val_1_fastqc.html](../qc/EU07_r1_val_1_fastqc.html) Read 1 post-trimming
- [EU07_r2_val_2_fastqc.html](../qc/EU07_r2_val_2_fastqc.html) Read 2 post-trimming


### _De-novo_ assembly using SPAdes v3.13.1
```
spades.py --careful -1 EU07_r1_val_1.fq.gz -2 EU07_r2_val_2.fq.gz -o EU07.spades
```

### Rename the scaffolds
This uses script [split_velvet_supercontigs_into_contigs.pl](./split_velvet_supercontigs_into_contigs.pl) to generate a new file 'scaffolds.fasta.supercontigs.fna' in which the sequence IDs are updated and tiny contigs of less than 50 bp are removed.
```
./split_velvet_supercontigs_into_contigs.pl  scaffolds.fasta > scaffolds.agp
```
This generates re-ordered version of the assembly, ready for submission to NCBI: [scaffolds.fasta.supercontigs.fna](./scaffolds.fasta.supercontigs.fna).

### Re-order the scaffolds against the FZB42 reference genome using Mauve
```
java -Xmx500m -cp ./mauve_snapshot_2015-02-13/Mauve.jar org.gel.mauve.contigs.ContigOrderer -output scaffolds.fasta.supercontigs.fna.reordered -ref Bacillus_velezensis_FZB42.fasta -draft scaffolds.fasta.supercontigs.fna 
```
This generated the reordered version of the assembly: [reordered.scaffolds.fasta.supercontigs.fna](./reordered.scaffolds.fasta.supercontigs.fna).

After submission to NCBI, they removed several contaminated contigs to generate this file: [reordered_scaffolds_fasta_supercontigs00000000.fsa](./reordered_scaffolds_fasta_supercontigs00000000.fsa).
The list of contaminated contigs, detected and removed by NCBI, can be found here: [FixedForeignContaminations.txt](./FixedForeignContaminations.txt).


