use v5.32.1;
use warnings;
use List::Util qw(max);

use constant {
    RIGHT => 0,
    DOWN  => 1,
    LEFT  => 2,
    UP    => 3,
};

open my $input, '<', "inputs/day_16.txt" or die "$!";

my ( $sum1,        $sum2 ) = ( 0, 0 );
my ( @contraption, @energized );
while ( my $line = <$input> ) {
    chomp $line;
    push @contraption, [ split //, $line ];
    push @energized, [
        map {
            { &RIGHT => 0, &DOWN => 0, &LEFT => 0, &UP => 0, }
        } 0 .. length($line) - 1
    ];
}

close $input;

my ( $h, $w ) = ( scalar @contraption, scalar @{ $contraption[0] } );

my %dir_mapping = (
    '/' => {
        &RIGHT => [UP],
        &LEFT  => [DOWN],
        &UP    => [RIGHT],
        &DOWN  => [LEFT],
    },
    '\\' => {
        &RIGHT => [DOWN],
        &LEFT  => [UP],
        &UP    => [LEFT],
        &DOWN  => [RIGHT],
    },
    '-' => {
        &RIGHT => [RIGHT],
        &LEFT  => [LEFT],
        &UP    => [ LEFT, RIGHT ],
        &DOWN  => [ LEFT, RIGHT ],
    },
    '|' => {
        &RIGHT => [ UP, DOWN ],
        &LEFT  => [ UP, DOWN ],
        &UP    => [UP],
        &DOWN  => [DOWN],
    },
    '.' => {
        &RIGHT => [RIGHT],
        &LEFT  => [LEFT],
        &UP    => [UP],
        &DOWN  => [DOWN],
    },
);

my %dir2move = (
    &RIGHT => [ 0,  1 ],
    &LEFT  => [ 0,  -1 ],
    &UP    => [ -1, 0 ],
    &DOWN  => [ 1,  0 ],
);

sub __initialize {
    my ( $h, $w ) = @_;
    my @energized;
    for ( 1 .. $h ) {
        push @energized, [
            map {
                { &RIGHT => 0, &DOWN => 0, &LEFT => 0, &UP => 0, }
            } 0 .. $w - 1
        ];
    }

    return \@energized;
}

sub __energize {
    my ($from) = @_;

    my @queue     = ( [ $from->[0], $from->[1], $from->[2] ] );
    my $energized = __initialize( $h, $w );

    while ( @queue > 0 ) {
        my $size = @queue;
        for ( 1 .. $size ) {
            my $cur = shift @queue;
            my ( $tile, $dir ) =
              ( $contraption[ $cur->[0] ]->[ $cur->[1] ], $cur->[2] );

            $energized->[ $cur->[0] ]->[ $cur->[1] ]->{$dir} = 1;

            my $next_dirs = $dir_mapping{$tile}->{$dir};

            for my $nd (@$next_dirs) {
                my $mv = $dir2move{$nd};
                my ( $x, $y ) = ( $cur->[0] + $mv->[0], $cur->[1] + $mv->[1] );
                if ( $x >= 0 && $x < $h && $y >= 0 && $y < $w ) {
                    if ( $energized->[$x]->[$y]->{$nd} == 0 ) {
                        push @queue, [ $x, $y, $nd ];
                    }
                }
            }
        }
    }

    my $sum = 0;
    for my $row (@$energized) {
        for my $col (@$row) {
            my @en = grep { $_ == 1 } values %$col;
            if ( @en > 0 ) {
                $sum++;
            }
        }
    }

    return $sum;
}

say __energize( [ 0, 0, RIGHT ] );

# part2
my $max_energized = -1;

# top
for ( 0 .. $w - 1 ) {
    $max_energized = max( $max_energized, __energize( [ 0, $_, DOWN ] ) );
}

# bottom
for ( 0 .. $w - 1 ) {
    $max_energized = max( $max_energized, __energize( [ $h - 1, $_, UP ] ) );
}

# left
for ( 0 .. $h - 1 ) {
    $max_energized = max( $max_energized, __energize( [ $_, 0, RIGHT ] ) );
}

# right
for ( 0 .. $h - 1 ) {
    $max_energized = max( $max_energized, __energize( [ $_, $w - 1, LEFT ] ) );
}

say $max_energized;

__DATA__
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
