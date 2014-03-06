#!/usr/bin/perl

#######
# POD #
#######

=pod

=head1 NAME

blast_prot_finder.pl                                       03-09-2012

=head1 SYNOPSIS

C<perl blast_prot_finder.pl -s subject_prot.fasta -r blastp-report.out -b>

=head1 DESCRIPTION

This script is intended to search for homologous proteins in annotated
bacterial genomes. Therefore, a previous BLASTP
(L<http://blast.ncbi.nlm.nih.gov/Blast.cgi>) needs to be run with
known query protein sequences against a BLAST database of subject
proteins (e.g. all proteins from several E. coli genomes).

For this purpose the script I<cds_extractor.pl> (with option '-f')
can be used to create multi-fasta protein files of all non-pseudo
CDS from genome sequence files to create the needed BLAST database.

The BLASTP report file, the subject multi-fasta file, and optionally
the query protein fasta file are then given to I<blast_prot_finder.pl>.
Significant BLAST hits are filtered and the result is written to
a tab-separated file. The subject hits are also concatenated in a
multi-fasta file for each query sequence (optionally including the
query sequence).

Optionally, I<Clustal Omega> (L<http://www.clustal.org/omega/>) can
be called (has to be in the C<$PATH> or change variable C<$clustal_call>)
to create an alignment (fasta format) for each of the concatenated
multi-fasta files. The alignments can then be used to calculate
phylogenies. Use e.g. I<SeaView>
(L<http://pbil.univ-lyon1.fr/software/seaview.html>) or
I<aln_format-converter.pl> to convert the alignment format to
Phylip for I<RAxML> (L<http://sco.h-its.org/exelixis/software.html>).
MEGA (http://www.megasoftware.net/) can work directly with the Clustal
fasta format.

Run the script I<cds_extractor.pl> (with option '-f') and the BLASTPs
manually or use the shell scripts I<blast_prot_finder*.sh> (see below
examples) to execute the whole pipeline (including I<blast_prot_finder.pl>
with optional options '-q', '-b', and '-a') consecutively in one folder.
For this purpose the same folder has to contain the annotated bacterial
genome subject files (in RichSeq format, e.g. embl or genbank), the
query protein fasta, and the scripts I<cds_extractor.pl> and
I<blast_prot_finder.pl>! BLASTP is run without filtering of query
sequences ('-F F'), an evalue cutoff of '1e-10', local optimal
Smith-Waterman alignments (-s T), and increasing the number of database
sequences to show alignments to 500 ('-b 500', to adjust it to the
alignment summary for BioPerl).

Additionally, the result file 'blast_hits.txt' can be given to the
script I<prot_binary_matrix.pl> to create a presence/abscence binary
matrix of the results. This comma-separated file can e.g. be loaded
into iTOL (L<http://itol.embl.de/>) to associate the data with a
phylogenetic tree.

The Perl script runs on BioPerl (L<http://www.bioperl.org>).

=head1 OPTIONS

=head2 Mandatory options

=over 22

=item B<-r>=I<str>, B<-report>=I<str>

BLASTP report/output

=item B<-s>=I<str>, B<-subject>=I<str>

Subject sequence file [fasta format]

=back

=head2 Optional options

=over 20

=item B<-h>, B<-help>

Help (perldoc POD)

=item B<-q>=I<str>, B<-query>=I<str>

Query sequence file (to include each query protein sequence in the
respective 'query-acc_hits.fasta' result file) [fasta format]

=item B<-b>, B<-best>

Give only the best hit (i.e. highest identity) for each subject locus
tag, if a locus tag has several hits with different queries

=item B<-i>=I<int>, B<-ident>=I<int>

Query identity cutoff (not including gaps) [default 70]

=item B<-cov_q>=I<int>, B<-cov_query>=I<int>

Query coverage cutoff [default 70]

=item B<-cov_s>=I<int>, B<-cov_subject>=I<int>

Subject/hit coverage cutoff [default 0]

=item B<-a>, B<-align>

Call Clustal Omega for alignment

=back

=head1 OUTPUT

=over 17

=item F<blast_hits.txt>

Contains a list of the filtered BLASTP hits, tab-separated

=item F<query-acc_hits.fasta>

Multi-fasta protein files of subject hits for each query protein (with acc#),
optionally includes the respective query protein sequence

=item F< *.idx.dir> and F< *.idx.pag>

Index files of the subject protein file for fast sequence retrieval (can be
deleted if no further BLASTPs are needed with these subject sequences)

=item (F<query-acc_aln.fasta>)

Optional, Clustal Omega alignment of subject hits for each query [fasta format]

=item (F<query-acc_tree.nwk>)

Optional, Clustal Omega NJ-guide tree in Newick format

=back

=head1 EXAMPLES

=head2 I<cds_extractor.pl>

=over

=item C<for i in *.[gbk|embl]; do perl cds_extractor.pl -i $i -p -f; done>

=item C<cat *_cds_aa.fasta E<gt> subject_prot.fasta>

=item C<rm -f *_cds_aa.fasta>

=back

=head2 Legacy BLASTP

=over

=item C<formatdb -p T -i subject_prot.fasta -n blast_finder>

=item C<blastall -p blastp -d blast_finder -i query_prot.fasta -o blastp.out -e 1e-10 -F F -s T -b 500>

=back

=head2 BLASTP+

=over

=item C<makeblastdb -in subject_prot.fasta -input_type fasta -dbtype prot -out blast_finder>

=item C<blastp -db blast_finder -query query_prot.fasta -out blastp.out -evalue 1e-10 -use_sw_tback -num_alignments 500>

=back

=head2 I<blast_prot_finder.pl>

=over

=item C<perl blast_prot_finder.pl -q query_prot.fasta -s subject_prot.fasta -r blastp.out -i 50 -cov_q 50 -b -a>

=item C<perl blast_prot_finder.pl -s subject_prot.fasta -r blastp.out -cov_s 80>

=back

=head2 All-in-one with unix bash-shell wrapper scripts

=over

=item C<./blast_prot_finder_legacy.sh subject_file-extension query_prot.fasta ident_cutoff cov_q_cutoff>

=item C<./blast_prot_finder_plus.sh subject_file-extension query_prot.fasta ident_cutoff cov_q_cutoff>

=back

=head1 VERSION

0.6                                                update: 10-06-2013

=head1 AUTHOR

Andreas Leimbach                                aleimba[at]gmx[dot]de

=head1 LICENSE

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 (GPLv3) of the License,
or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see L<http://www.gnu.org/licenses/>.

=cut


########
# MAIN #
########

use strict;
use warnings;
use Getopt::Long; # module to get options from the command line
use Bio::SeqIO; # bioperl module to handle sequence input/output
use Bio::SearchIO; # bioperl module to handle blast reports
use Bio::Index::Fasta; # bioperl module to create an index for a multi-fasta file for faster retrieval of sequences


### Get the options with Getopt::Long, works also abbreviated and with two "--": -r, --r, -report ...
my $report = ''; # name of the blast report/output file
my $subject_file = ''; # multi-fasta protein file from 'cds_extractor.pl' (with option '-f) which was used to create the BLAST DB (the subjects)
my $query_file = ''; # optionally, needed to include the query proteins in the result/hit multi-fasta protein file for subsequent alignment
my $best_hit = ''; # optionally, give only the best hit (i.e. highest identity) for each subject locus_tag, even if a locus_tag has several hits with different queries; if option not given report all locus_tags for each query
my $ident_cutoff = 70; # query identity cutoff (without gaps), or use standard value 70%
my $cov_query_cutoff = 70; # query coverage cutoff, or use standard value 70%
my $cov_subject_cutoff = 0; # subject/hit coverage cutoff, or use standard value 0%
my $align = ''; # optionally, align the sequences with Clustal Omega
my $help = ''; # run perldoc on the POD
GetOptions ('report=s' => \$report,
            'subject=s' => \$subject_file,
            'query:s' => \$query_file,
            'best_hit' => \$best_hit,
            'ident_cutoff:i' => \$ident_cutoff,
            'cov_query_cutoff:i' => \$cov_query_cutoff,
            'cov_subject_cutoff:i' => \$cov_subject_cutoff,
            'align' => \$align,
            'help|?' => \$help);



### Run perldoc on POD
my $usage = "perldoc $0";
if (!$report || !$subject_file) {
    die system($usage);
} elsif ($help) {
    die system($usage);
}



### Parse the blast report/output file; store/print queries, subject locus_tag hits and stats
my $hit_outfile = "blast_hits.txt"; # tab-separated output file for significant blast hits
file_exist($hit_outfile); # subroutine to test for file existence and print overwrite warning
open (HIT, ">$hit_outfile") or die "Failed to create file \'$hit_outfile\': $!\n";
print HIT "Subject_organism\tSubject_gene\tSubject locus_tag\tSubject protein_function\tQuery_accession\tQuery_description\tQuery_coverage [%]\tQuery_identities [%]\tHit_coverage [%]\tE-value\tBit-score of best HSP\n";
my %blast_hits; # stores significant blast hits with the query_acc (key) and an array reference on subject locus_tag hits (values; several queries can have the same subject locus tag as hit) for retrieval afterwards
my %best_locus_hit; # for option 'best_hit', stores only the best hit for each locus_tag (key)
my @no_blasthit; # stores queries that don't have a blast hit to print to STDOUT
my $searchio = new Bio::SearchIO(-file => "<$report", -format => 'blast'); # Bio::SearchIO object
while (my $result = $searchio ->next_result) { # Bio::Search::Result::GenericResult object; several query sequences possible (result = entire analysis for a single query seq)
    my $no_hit = 0; # report if no significant blast hit was found for a query
    my @locus_tags; # array to store ALL the subject locus_tag hits for each query, fed into %blast_hits via reference; only used if 'best_hit' option not given
    my $query_acc = $result->query_accession;
    $query_acc =~ s/\.$//; # rm a '.' if present at the end of the string (for non-NCBI fasta headers)
    my $query_desc = $result->query_description;
    while (my $hit = $result->next_hit) { # Bio::Search::Hit::GenericHit object; several subject sequences in the database might have hits
        my $hit_locus_tag = $hit->name;
        my ($gene, $product, $organism) = split_ID($hit->description); # subroutine to split the subject fasta ID lines (see cds_extractor.pl with option '-f')
        if ($gene !~ /.+/) { # print/store empty string if gene tag doesn't exist
            $gene = '';
        }
        my $perc_identity = $hit->frac_identical('query'); # ignores gaps, method will call/requires BioPerls hsp tiling [tile_hsps()] to get value
        $perc_identity *= 100;
        my $query_cov = $hit->frac_aligned_query; # method requires hsp tiling
        $query_cov *= 100;
        my $hit_cov = $hit->frac_aligned_hit; # = subject coverage; method requires hsp tiling
        $hit_cov *= 100;
        if ($perc_identity >= $ident_cutoff && $query_cov >= $cov_query_cutoff && $hit_cov >= $cov_subject_cutoff) {
            $no_hit++;
            my $evalue = $hit->significance;
            $evalue =~ s/\,$//; # rm ',' from the end of the evalue
            if (!$best_hit) { # option 'best_hit' not given, print all locus_tag hits directly
                print HIT "$organism\t$gene\t$hit_locus_tag\t$product\t$query_acc\t$query_desc\t$query_cov\t$perc_identity\t$hit_cov\t$evalue\t", $hit->bits, "\n";
                push(@locus_tags, $hit_locus_tag); # store significant subject hit in @locus_tags
            } elsif ($best_hit) { # store only the best hit for each locus_tag, print to HIT is below
                if (!$best_locus_hit{$hit_locus_tag} || $best_locus_hit{$hit_locus_tag}->{'perc_identity'} < $perc_identity) { # if the locus_tag doesn't exist yet or the identity of the previous hit is lower
                    $best_locus_hit{$hit_locus_tag} = {'organism' => $organism,
                                                       'gene' => $gene,
                                                       'product' => $product,
                                                       'query_acc' => $query_acc,
                                                       'query_desc' => $query_desc,
                                                       'query_cov' => $query_cov,
                                                       'perc_identity' => $perc_identity,
                                                       'hit_cov' => $hit_cov,
                                                       'evalue' => $evalue,
                                                       'bit_score' => $hit->bits}; # anonymous hash (with blast stats as values) in %best_locus_hit (key locus_tags are unique with best_hit)
                } elsif ($best_locus_hit{$hit_locus_tag}->{'perc_identity'} > $perc_identity) { # locus_tag has a previous hit to a query with a higher identity
                    next;
                }
            }
        }
    }
    if (!$best_hit) {
        $blast_hits{$query_acc} = \@locus_tags; # the same locus_tag can be a hit for different queries (without option 'best_hit'), thus locus_tags are not unique and an array reference data structure is suitable
    }
    if ($no_hit == 0) { # no hit for a query, store in @no_blasthit for later print to STDOUT
        push(@no_blasthit, $query_acc);
    }
}



### Option 'best_hit' given; print out only the best hit for each locus_tag and store respective locus_tags in %blast_hits
if ($best_hit) {
    my $skip = ''; # skip queries that have already been processed
    foreach my $locus_tag (sort{lc $best_locus_hit{$a}->{'query_acc'} cmp lc $best_locus_hit{$b}->{'query_acc'}} keys %best_locus_hit) { # sort locus_tags (keys of %best_locus_hit) by 'query_acc' to get each query_acc only once and $skip the others
        if ($best_locus_hit{$locus_tag}->{'query_acc'} eq $skip) {
            next; # skip to next locus_tag and check again $skip
        }
        $skip = $best_locus_hit{$locus_tag}->{'query_acc'};
        my @locus_tags = sort{lc $best_locus_hit{$a}->{'organism'} cmp lc $best_locus_hit{$b}->{'organism'}} grep($best_locus_hit{$_}->{'query_acc'} eq $best_locus_hit{$locus_tag}->{'query_acc'}, keys %best_locus_hit); # get all locus_tags for the current 'query_acc', sorted by 'organism'
        $blast_hits{$skip} = \@locus_tags; # array reference compatible to above without 'best_hit'
        foreach my $tag (@locus_tags) {
            print HIT "$best_locus_hit{$tag}->{'organism'}\t".
                      "$best_locus_hit{$tag}->{'gene'}\t".
                      "$tag\t".
                      "$best_locus_hit{$tag}->{'product'}\t".
                      "$best_locus_hit{$tag}->{'query_acc'}\t".
                      "$best_locus_hit{$tag}->{'query_desc'}\t".
                      "$best_locus_hit{$tag}->{'query_cov'}\t".
                      "$best_locus_hit{$tag}->{'perc_identity'}\t".
                      "$best_locus_hit{$tag}->{'hit_cov'}\t".
                      "$best_locus_hit{$tag}->{'evalue'}\t".
                      "$best_locus_hit{$tag}->{'bit_score'}\n";
        }
    }
}
close HIT;



### Create index for multi-fasta subject protein file for faster retrieval of protein sequences; indeces have to be unique (which works fine for locus tags)
my $inx = Bio::Index::Fasta->new(-filename => $subject_file . ".idx", -write_flag => 1);
$inx->make_index($subject_file); # by default the fasta indexing code will use the string following the > character as a key, in this case the locus tags



### Get the significant BLAST hits from the indexed multi-fasta protein subject file and the query protein file (w/o index)
my $query_seqioobj; # declare Bio::SeqIO object outside foreach loop below (only needs to be opened once)
if ($query_file) { # query multi-fasta file given with option 'query'
    $query_seqioobj = Bio::SeqIO->new(-file => "<$query_file", -format => 'fasta'); # Bio::SeqIO object to retrieve current query seq and write it as first seq into the hit multi-fasta file '*query*_hits.fasta'
}
my @fasta_files; # store all created fasta files
foreach my $query_acc (sort keys %blast_hits) {
    if (!scalar @{$blast_hits{$query_acc}}) { # skip a query if it has no subject hits
        next;
    }
    my $fasta_outfile = "$query_acc\_hits.fasta";
    file_exist($fasta_outfile);
    push (@fasta_files, $fasta_outfile);
    my $seqio_outobj = Bio::SeqIO->new(-file => ">$fasta_outfile"); # write a multi-fasta file of hits for each query; format not needed, as everything is and should be fasta anyway
    if ($query_file) { # query multi-fasta file given with option 'query'
        while (my $seq_inobj = $query_seqioobj->next_seq) { # Bio::Seq object; index not needed should be small file
            if ($seq_inobj->display_id =~ /$query_acc/) {
                $seqio_outobj->write_seq($seq_inobj);
            }
        }
    }
    foreach my $locus_tag (@{$blast_hits{$query_acc}}) { # hit locus_tags for each query stored as array reference
        my $seq_obj = $inx->fetch($locus_tag); # a Bio::Seq object; fetch subject seq from index
        my ($gene, $product, $organism) = split_ID($seq_obj->desc);
        if ($gene =~ /.+/) {
            $seq_obj->desc("$organism $gene"); # set the description of the fasta ID line to a new one, if a gene name exists
        } else {
            $seq_obj->desc("$organism"); # w/o gene name
        }
        $seqio_outobj->write_seq($seq_obj);
    }
}



### OPTIONAL method to extract the BLAST hit protein sequences without bioperl and without an index
# open (SUBJECT, "<$subject_file") or die "Failed to open file \'$subject_file\': $!\n";
# if ($query_file) { # query multi-fasta file given with option 'query'
    # open (QUERY, "<$query_file") or die "Failed to open file \'$query_file\': $!\n"; # include the query protein seq in each respective '*_hits.fasta' result file
# }
# my @fasta_files; # store all created fasta files
# foreach my $query_acc (sort keys %blast_hits) {
    # if (!scalar @{$blast_hits{$query_acc}}) { # skip a query if it has no subject hits
        # next;
    # }
    # my $fasta_outfile = "$query_acc\_hits.fasta";
    # file_exist($fasta_outfile);
    # push (@fasta_files, $fasta_outfile);
    # open (OUT, ">$fasta_outfile") or die "Failed to create file \'$fasta_outfile\': $!\n";
    # if ($query_file) { # query multi-fasta file given with option 'query'
        # while (my $line = <QUERY>) { # retrieve current query seq and write it as first seq into the hit multi-fasta file '*query*_hits.fasta'
            # if ($line =~ /$query_acc/) {
                # chomp $line;
                # print OUT "$line\n";
                # $line = <QUERY>;
                # while ($line !~ /^>/ && $line !~ /^$/) { # read in sequence until the next fasta header, empty line, or EOF
                    # chomp $line;
                    # print OUT "$line\n";
                    # $line = <QUERY>;
                    # if (eof) { # get out of the loop if the next $line is the end of the file
                        # print OUT "$line\n" if ($line); # print the last line, as it might still have sequence
                        # last;
                    # }
                # }
                # last; # jump out of the loop if locus tag is found (the rest of the file doesn't need to be parsed)
            # }
        # }
    # }
    # foreach my $locus_tag (@{$blast_hits{$query_acc}}) { # hit locus_tags for each query stored as array reference
        # while (my $line = <SUBJECT>) {
            # if ($line =~ /^>$locus_tag /) { # use '^' and ' ' to force complete locus_tag match (e.g. problem with ABU83972 'ECABU_c27750' and CFT073 'c2775')
                # chomp $line;
                # $line =~ s/>.+\s(g=.+)$/$1/; # get rid of the locus tag for the subroutine split_ID below (actually here should 'my @desc = split (' ', $line);' work [omitting the split_ID sub] as all the spaces are replaced by '_' in 'cds_extractor.pl'
                # my ($gene, $product, $organism) = split_ID($line);
                # print OUT ">$locus_tag $organism ";
                # if ($gene =~ /.+/) {
                    # print OUT "$gene\n";
                # } else {
                    # print OUT "\n";
                # }
                # $line = <SUBJECT>;
                # while ($line !~ /^>/ && $line !~ /^$/) {
                    # chomp $line;
                    # print OUT "$line\n";
                    # $line = <SUBJECT>;
                    # if (eof) { # get out of the loop if the next $line is the end of the file
                        # print OUT "$line\n" if ($line); # print the last line, as it might still have sequence
                        # last;
                    # }
                # }
                # seek SUBJECT, 0, 0; # set filepointer for the filehandle SUBJECT back to zero for the next locus_tag
                # last;
            # }
        # }
    # }
    # close OUT;
# }
# close SUBJECT;
# if ($query_file) {
    # close QUERY;
# }



### State which files were created or warn if no BLAST hits were found at all
if (-s $hit_outfile < 150) { # smaller than just the header, which should be 133 bytes
    print "No significant BLASTP hits could be found!\n";
    unlink $hit_outfile;
    exit;
} else {
    print "\n###########################################################################\n";
    print "The following files were created:\n";
    print "\tA summary of the BLASTP results were written to \'$hit_outfile\'!\n";
}
print "\tThe protein sequences of the BLASTP hits were written to:\n";
foreach my $fasta (@fasta_files) {
    print "\t\t\t\t$fasta\n";
}
if (scalar @no_blasthit) { # only print if array has elements, i.e. there is a query with no subject hits
    print "No significant BLASTP hit was found for query/queries:\n";
    foreach my $query (@no_blasthit) {
        print "\t$query";
    }
    print "\n\n";
}
print "If no further BLASTPs with these subject sequences are needed the index\nfiles \'$subject_file.idx.dir\' and\n\'$subject_file.idx.pag\' can be deleted!\n";
print "###########################################################################\n";



### Align with Clustal Omega if option '--align' (-a|--a) is given
if ($align) {
    print "\nStarting Clustal Omega alignment with ...\n";
    foreach my $fasta (@fasta_files) {
        print "\t## file \'$fasta\'\n";
        my $out = $fasta;
        $out =~ s/\_hits.fasta//;
        my $clustal_call = "clustalo -i $fasta -o $out\_aln.fasta --verbose --guidetree-out=$out\_tree.nwk";
        system ($clustal_call);
    }
}


exit;



###############
# Subroutines #
###############

### Subroutine to split the header of the protein multi-fasta files from 'cds_extractor.pl' and its '-f' option
sub split_ID {
    my $hit_desc = shift;
    my ($gene, $product, $organism) = '';
    if ($hit_desc =~ /^(g=.*)(p=.*)(o=.*)$/) { # if a product tag is too long, BLAST will introduce a space in the report, thus cannot split "@desc = split (' ', $hit_desc);" and have to use regex instead
        $gene = $1;
        $product = $2;
        $organism = $3;
        $gene =~ s/^g=//;
        $gene =~ s/\s//g; # get rid of all optionally introduced spaces
        $product =~ s/^p=//;
        $product =~ s/\s//g;
        $product =~ tr/_/ /; # replace the '_' back to spaces, as this was changed in the script 'cds_extractor.pl'
        $organism =~ s/^o=//; # don't replace the '_' back, no spaces might be better for phylogenetic programs
        $organism =~ s/\s//g;
    }
    return ($gene, $product, $organism);
}


### Subroutine to test for file existence and give warning to STDOUT
sub file_exist {
    my $file = shift;
    if (-e $file) {
        print "\nThe result file \'$file\' exists already and will be overwritten!\n";
    }
}
