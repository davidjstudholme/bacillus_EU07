
### Trim Galore version: 0.6.7
### Cutadapt version: 3.5

```
trim_galore --paired -q 30 EU07_r1.fq.gz  EU07_r2.fq.gz
```


### SPAdes v3.13.1
```
spades.py --careful -1 EU07_r1_val_1.fq.gz -2 EU07_r2_val_2.fq.gz -o EU07.spades
```

### Rename the scaffolds
### This generates new file 'scaffolds.fasta.supercontigs.fna'
```
./split_velvet_supercontigs_into_contigs.pl  scaffolds.fasta > scaffolds.agp
```

### Re-order the scaffolds against the FZB42 reference genome
### This generates re-ordered version of the assembly, ready for submission to NCBI
### ./scaffolds.fasta.supercontigs.fna.reordered/alignment9/scaffolds.fasta.supercontigs.fna
```
java -Xmx500m -cp ./mauve_snapshot_2015-02-13/Mauve.jar org.gel.mauve.contigs.ContigOrderer -output scaffolds.fasta.supercontigs.fna.reordered -ref Bacillus_velezensis_FZB42.fasta -draft scaffolds.fasta.supercontigs.fna 
```



