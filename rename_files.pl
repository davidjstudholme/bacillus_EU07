#!/usr/bin/perl -w

use strict;
use warnings ;

my $usage ="Usage: $0 <genomes list file>";

### Read list of genomes to be included
my $genomes_list_file = shift or die "$usage\n";
my %genomes_list;
open(GENOMES_LIST, "<$genomes_list_file") or die $!;
while (my $line = <GENOMES_LIST>) {
    chomp $line;
    unless ($line=~m/^\#/) {
	if ($line =~ m/^(\S+)\s+(.*)/) {
	    my ($filename, $genome) = ($1, $2);
	    if (-s "$filename") {
		#warn "$filename exists\n";
		$genome =~ s/\s+/_/g;
		$genomes_list{$filename} = $genome;
	    } else {
		warn "Can't find a file $filename";
	    }	    
	}
    }
}
close GENOMES_LIST;

foreach my $filename (keys %genomes_list) {
    my $genome = $genomes_list{$filename};
    my $cmd = "ln -s $filename \"$genome.contig\"  && ln -s $filename \"$genome.fasta\"";
    #warn "$cmd\n";
    system($cmd);
}
