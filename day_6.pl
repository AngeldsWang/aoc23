use v5.32.1;
use warnings;
use DDP;

open my $input, '<', "inputs/day_6.txt" or die "$!";

my $moe = 1;
my @times;
my @distances;
while ( my $line = <$input> ) {
    if ( $line =~ /Time:\s+(.*)$/ ) {
        @times = $1 =~ /\d+/g;
    }

    if ( $line =~ /Distance:\s+(.*)$/ ) {
        @distances = $1 =~ /\d+/g;
    }
}

while ( my ( $race, $time ) = each(@times) ) {
    my $cnt = 0;
    for ( my $x = 0 ; $x <= int( $time / 2 ) ; $x++ ) {
        if ( $x * ( $time - $x ) > $distances[$race] ) {
            $cnt++;
        }
    }

    if ( $time % 2 == 0 ) {
        $cnt = $cnt * 2 - 1;
    }
    else {
        $cnt = $cnt * 2;
    }

    $moe *= $cnt;
}

say $moe;

# part2
my $time     = ( join '', @times ) + 0;
my $distance = ( join '', @distances ) + 0;

my ( $l, $r ) = ( 0, int( $time / 2 ) );
while ( $l < $r ) {
    my $m = int( ( $l + $r ) / 2 );
    if ( $m * ( $time - $m ) >= $distance ) {
        $r = $m;
    }
    else {
        $l = $m + 1;
    }
}

say $time - 2 * $l + 1;

close $input;
