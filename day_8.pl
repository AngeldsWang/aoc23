use v5.32.1;
use warnings;

open my $input, '<', "inputs/day_8.txt" or die "$!";

my $instructions = <$input>;
chomp $instructions;
my %map;
while ( my $line = <$input> ) {
    if ( $line =~ /^\w/ ) {
        my ( $from, $left, $right ) = $line =~ /(\w+) = \((\w+), (\w+)\)/;
        $map{$from} = {
            L => $left,
            R => $right
        };
    }
}

close $input;

my $step1 = 0;
my $end   = 0;
my $curr  = 'AAA';
for ( ; ; ) {
    my @insts = split //, $instructions;
    for my $inst (@insts) {
        my $next = $map{$curr}->{$inst};
        $step1++;
        if ( $next eq 'ZZZ' ) {
            $end = 1;
            last;
        }
        $curr = $next;
    }

    last if $end == 1;
}

say $step1;

# part2
my $step2 = 1;
my @currs = grep { $_ =~ /A$/ } keys %map;

for my $curr (@currs) {
    my ( $step, $end ) = ( 0, 0 );
    for ( ; ; ) {
        my @insts = split //, $instructions;
        for my $inst (@insts) {
            my $next = $map{$curr}->{$inst};
            $step++;
            if ( $next =~ /Z$/ ) {
                $end = 1;
                last;
            }
            $curr = $next;
        }

        last if $end == 1;
    }
    $step2 = lcm( $step2, $step );
}

say $step2;

sub gcd {
    my ( $x, $y ) = @_;
    while ($x) { ( $x, $y ) = ( $y % $x, $x ) }
    $y;
}

sub lcm {
    my ( $x, $y ) = @_;
    ( $x && $y ) and $x / gcd( $x, $y ) * $y or 0;
}

__DATA__
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
