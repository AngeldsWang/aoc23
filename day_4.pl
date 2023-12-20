use v5.32.1;
use warnings;

open my $input, '<', "inputs/day_4.txt" or die "$!";

my $sum1 = 0;
my $sum2 = 0;
my @matches;
my $lines = 0;
while ( my $line = <$input> ) {
    my ( $id, $winning, $having ) = $line =~ /Card\s+(\d+): (.*)\s+\|\s+(.*)$/;
    my @win  = $winning =~ /\d+/g;
    my @have = $having  =~ /\d+/g;

    my %map = map { $_ => 1 } @have;

    my $match = 0;
    for my $w (@win) {
        if ( exists $map{$w} ) {
            $match++;
        }
    }
    push @matches, $match;
    $lines++;
    $sum1 += 2**( $match - 1 ) if $match > 0;
}

my %counter = map { $_ => 1 } 1 .. $lines;
for my $card ( 1 .. $lines ) {
    my $copy  = $counter{$card};
    my $match = $matches[ $card - 1 ];
    for ( 1 .. $copy ) {
        for ( 1 .. $match ) {
            $counter{ $card + $_ }++;
        }
    }
}

map { $sum2 += $counter{$_} } keys %counter;

say $sum1;
say $sum2;

close $input;
