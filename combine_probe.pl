use v5.32;
use warnings;
use Getopt::Long qw/:config auto_help auto_version/;

my @files  = ();
my $output = '';
my $record = '';

GetOptions(
    'files|f=s{1,}' => \@files,
    'out|o=s'       => \$output,
    'record|r=s'    => \$record,
);

open my $o, '>', $output or die $!;
open my $r, '>', $record or die $!;
my $new_id = 0;
for my $file (@files) {
    my %uniq_loci = ();
    open my $fh, '<', $file or die $!;
    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ /^>/) {
            my ($locus) =  $line =~ m/uce-([0-9]+)_/; 
            if (not exists $uniq_loci{$locus}) {
                $new_id += 1;
                $uniq_loci{$locus} = $new_id;
            }
            my $id = $uniq_loci{$locus};
            my $new_header = $line =~ s/uce-[0-9]+_/uce-${id}_/r;
            print $o $new_header,"\n";
        } else {
            print $o $line, "\n";
        }
    }
    for my $old (sort {$a <=> $b} keys %uniq_loci) {
        print $r $file, "\to", $old, "e\tn", $uniq_loci{$old}, "e\n";
    }
}