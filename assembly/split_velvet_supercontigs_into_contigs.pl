#!/usr/bin/perl

### Generates contigs (in FastA) and scaffolding information (in AGP) from Velvet 'contigs.fa' supercontigs file

### Use entirely at you own risk!! There may be bugs!

use strict;
use warnings ;
use Bio::SeqIO ;

my $min_contig_length = 50;
my $min_supercontig_length = 200;
#my $min_contig_length = 100;
#my $min_supercontig_length = 1000;

my $sequence_file = shift or die "Usage: $0 <sequence file>\n" ;
print "# Generated from Velvet assembly file $sequence_file using script $0\n";

my $strain = $sequence_file;
$strain =~ s/\..*$//;

my $comment = '';

#my $comment = "[Organism=Pseudomonas syringae pv. syringae str. $strain][strain=$strain][pathovar=syringae]";
#my $comment = "[Organism=Pseudomonas syringae pv. tabaci str. $strain][strain=$strain][pathovar=tabaci]";
#my $comment = "[Organism=Pseudomonas syringae pv. actinidiae str. $strain][strain=$strain][pathovar=actinidiae]";
#my $comment = "[Organism=Thauera selenatis AX][strain=ATCC]";
#my $comment = "[Organism=Campylobacter jejuni][strain=$strain]";
#my $comment = "[Organism=Phytophthora ramorum][strain=$strain]";
#my $comment = '[Organism=Pseudomonas fuscovaginae][strain=UPB0736]';
#my $comment = '[Organism=Puccinia striiformis][strain=rathjen]';
#my $comment = '[Organism=Ensete ventricosum]';

#my $comment = '[Organism=Phytophthora sp.]';

#my $comment = '[Organism=Phytophthora taxon agathis]';
#my $comment = '[Organism=Phytophthora kernoviae]';
#my $comment = '[Organism=Phytophthora pluvialis]'; 
#my $comment = '[Organism=Salmonella enterica servovar Gallinarum][strain=SG9]';
#my $comment = "[Organism=Phytophthora lateralis]";
#my $comment = "[Organism=Phytophthora ramorum]";
#my $comment = "[Organism=Ralstonia solanacearum]"; 
#my $comment = "[Organism=Escherichia coli][strain=$strain]";
#my $comment = "[Organism=Erwinia toletana][strain=$strain]";                                                                    
#my $comment = "[Organism=Pseudomonas syringae pv. phaseolicola str. $strain][strain=$strain][pathovar=phaseolicola]";
#my $comment = "[Organism=Pseudomonas syringae pv. phaseolicola][pathovar=phaseolicola]";
#my $comment = "[Organism=Hyaloperonospora arabidopsidis][strain=$strain]";

#my $comment = "[Organism=Trichoderma hamatum]";

#my $comment = "[Organism=Xanthomonas vasicola]";
#my $comment = "[Organism=Xanthomonas sp.][strain=Nyagatare]";
#my $comment = "";
#my $comment = "[Organism=Xanthomonas arboricola pv. celebensis][strain=NCPPB 1630]";
#my $comment = "[Organism=Xanthomonas arboricola pv. celebensis][strain=NCPPB 1832]";
#my $comment = "[Organism=Xanthomonas axonopodis]";
#my $comment = "[Organism=Xanthomonas vasicola]";
#my $comment = "[Organism=Streptomyces europeaiscabiei][strain=NCPPB 4064]";
#my $comment = "[Organism=Streptomyces acidiscabies][strain=NCPPB 4445]";
#my $comment = "[Organism=Streptomyces scabiei][strain=NCPPB 4066]";
#my $comment = "[Organism=Streptomyces scabiei][strain=NCPPB 4086]";
#my $comment = "[Organism=Streptomyces stelliscabiei][strain=P3825]";
#my $comment = "[Organism=Xanthomonas sp.][strain=$strain]";
#my $comment = "[Organism=Pseudomonas syringae][strain=$strain]";
#my $comment = "[Organism=Pseudomonas fluorescens][strain=$strain]";
#my $comment = "[Organism=Pseudomonas fluorescens]";
#my $comment = "[Organism=Citrobacter werkmanii]";
#my $comment = "[Organism=Pseudomonas viridiflava]";
#my $comment = "[Organism=Pseudomonas poae]";
#my $comment = "[Organism=Pseudomonas gingerii][strain=$strain]";
#my $comment = "[Organism=Pseudomonas sp.][strain=$strain]";
#my $comment = "[Organism=Chryseobacterium taeanense][strain=ARB2]";
#my $comment = "[Organism=Xanthomonas campestris pv. musacearum str. $strain][pathovar=musacearum]";
#my $comment = "[Organism=Xanthomonas vasicola pv. vasculorum str. $strain][strain=$strain][pathovar=vasculorum]";

warn "Will be adding comment:\n\t$comment\n\n";

### Output file for contigs in Fasta format
my $fasta_outfile = "$sequence_file.contigs.fsa";
open (CONTIGS_FILE, ">$fasta_outfile") and 
    warn "Will write contigs to file '$fasta_outfile' and AGP to STDOUT\n" or
    die "Failed to write to file '$fasta_outfile'\n";

### Output file for corrected supercontigs in Fasta format
my $supercontigs_outfile = "$sequence_file.supercontigs.fna";
open (SUPERCONTIGS_FILE, ">$supercontigs_outfile") and 
    warn "Will write supercontigs to file '$supercontigs_outfile' and AGP to STDOUT\n" or
    die "Failed to write to file '$supercontigs_outfile'\n";

### We need to expand the single N gaps into runs of 10 Ns to fit with the convention followed by both NCBI 
### (see http://www.ebi.ac.uk/embl/Documentation/detailed_wgs.html)
my $n10='';
foreach my $i ( 1 .. 10) {
    $n10 .= 'N';
}

#my %supercontig_ids;
my $scaffold_number = 1;
my $inseq = Bio::SeqIO->new('-file' => "<$sequence_file",
			    '-format' => 'fasta' ) ;
while (my $seq_obj = $inseq->next_seq ) {
   
    my $supercontig_id = $seq_obj->id ;
    my $supercontig_seq = $seq_obj->seq ;
    my $supercontig_desc = $seq_obj->description ;
    
    $supercontig_seq =~ s/[RYSWKMBDHV]/N/gi;
    $supercontig_seq =~ s/^N+//i; # remove any Ns from beginning of sequence
    $supercontig_seq =~ s/N+$//i; # remove any Ns from beginning of sequence
    

    ### NCBI do not allow coverage and length information in the FastA identifier
    ### e.g. NODE_1160_length_397673_cov_14.469489 is an illegal FastA ID
    ### So we will replace these with simple numbers
    
    $supercontig_id = "scf_$$\_$scaffold_number";
    $scaffold_number++;
        
    if ($supercontig_seq =~ m/a{1000}/i or
	$supercontig_seq =~ m/t{1000}/i ) {
	warn "$supercontig_id is polyA!\n";
    } elsif (length($supercontig_seq) < $min_supercontig_length) {
	#warn "$supercontig_id is too short!\n";
    } else {

	#$supercontig_seq =~ s/([ACGT])N{1,10}([ACGT])/$1$n10$2/g;
	$supercontig_seq =~ s/([ACGTN]{80})/$1\n/gi;
	print SUPERCONTIGS_FILE ">$supercontig_id\n$supercontig_seq\n";
    }
}
close SUPERCONTIGS_FILE;



my $inseq2 = Bio::SeqIO->new('-file' => "<$supercontigs_outfile",
			    '-format' => 'fasta' ) ;
while (my $seq_obj = $inseq2->next_seq ) {
  
    my $supercontig_id = $seq_obj->id ;
    my $supercontig_seq = $seq_obj->seq ;
    my $supercontig_length = length($supercontig_seq);
    
    my $contig_number = 0;
    my $i = 0;# a counter, used for generating unique part number
    my $start_pos = 1; # keep track of whereabouts in this supercontig we are
    

    ### Need to avoid very short contigs. Turn them into gaps instead.
    while( $supercontig_seq =~ m/(N{10}[ACGT]{1,$min_contig_length}N{10})/i or
	   $supercontig_seq =~ m/(N{10}[ACGT]{1,$min_contig_length})$/i or
	   $supercontig_seq =~ m/^([ACGT]{1,$min_contig_length}N{10})/i 
	) { 
	my $replacement = 'N' x length($1);
	#warn "replacing:\n\t$1 in $supercontig_id\n\twith\n\t$replacement\n";
	$supercontig_seq =~ s/$1/$replacement/i;
    }
    $supercontig_seq =~ s/^N+//i; # remove any Ns from beginning of sequence
    $supercontig_seq =~ s/N+$//i; # remove any Ns from beginning of sequence
            
    foreach my $substring_sequence ( split /(N{10,})/i, $supercontig_seq ) {
	### NB that NCBI do not allow gaps of fewer than 10 nucleotides between contigs.
	### Gaps of fewer than 10 nucleotides are treated as ambiguities rather than gaps.
	### So this split is a bit of a fudge.
	
	#warn "\n$substring_sequence\n" if $supercontig_id =~m/3047/; #for debugging only
	
	$i++; # part number
	

	### Define the AGP column contents
	my $object1 = $supercontig_id;
	my $object_beg2 = $start_pos;
	my $object_end3 = $start_pos + length($substring_sequence) - 1;
	my $part_number4 = $i;
	my $component_type5;
	my $component_id6a;
	my $gap_length6b;
	my $component_beg7a;
	my $gap_type7b;
	my $component_end8a;
	my $linkage8b;
	my $orientation9a;
	my $filler9b;
		
	### Do a sanity check on the sub-sequence
	if ($substring_sequence eq substr($supercontig_seq, ($start_pos-1), length($substring_sequence)) ) {
	    ### OK
	} else {
	    die "fatal: $substring_sequence\nis different to\n".substr($supercontig_seq, ($start_pos-1), length($substring_sequence))."\n";
	}
	
	if (  $substring_sequence =~ m/^N{100}$/i ) {
	    ### This is a 100-N gap between contigs
	    $component_type5 = 'U';
	    $gap_length6b = length($substring_sequence);
	    $gap_type7b = 'scaffold';
	    $linkage8b = "yes\tpaired-ends";
	    $filler9b = '';
	} elsif (  $substring_sequence =~ m/^N+$/i ) {
	    ### This is poly-N gap between contigs
	    $component_type5 = 'N';
	    $gap_length6b = length($substring_sequence);
	    $gap_type7b = 'scaffold';
	    $linkage8b = "yes\tpaired-ends";
	    $filler9b = '';
	} elsif ( $substring_sequence =~ m/^[ACGTN]+$/i ) {
	    ### This is a contig
	    $contig_number++;
	    $component_type5 = 'W';
	    $component_id6a = "$supercontig_id.contig_$contig_number";
	    $component_beg7a = 1;
	    $component_end8a = length($substring_sequence);
	    $orientation9a = '+';
	    
	    ### Print FastA formatted contig
	    warn "$component_id6a is polyA!\n" if $substring_sequence =~ m/a{1000}/i;
	    my $print_seq = $substring_sequence;
	    $print_seq =~ s/([ACGTN]{80})/$1\n/gi;
	    print CONTIGS_FILE ">$component_id6a $comment\n$print_seq\n";

	} elsif ($substring_sequence eq '') {
	    warn "$supercontig_id\_contig_$i is empty\n";
       	    
	    
	} else {
	    die "Illegal characters in sequence\n$supercontig_id\_contig_$i: '$substring_sequence'\n";
	}
	
	$start_pos += length($substring_sequence);
	
	if ($component_type5 eq 'N' or 
	    $component_type5 eq 'U') {
	    ### print AGP line for gap
	    print "$object1\t$object_beg2\t$object_end3\t$part_number4\t$component_type5\t$gap_length6b\t$gap_type7b\t$linkage8b\t$filler9b\n";
	} else {
	    ### print AGP line for contig
	    print "$object1\t$object_beg2\t$object_end3\t$part_number4\t$component_type5\t$component_id6a\t$component_beg7a\t$component_end8a\t$orientation9a\n";
	    
	}
    }
    
}
close CONTIGS_FILE;


my $cmd = "~djs217/scripts/fasta2fasta.pl $fasta_outfile >  $fasta_outfile.$$ && mv $fasta_outfile.$$ $fasta_outfile";
warn "$cmd\n";
my $execute = `$cmd`;
warn "$execute\n";
