use v5.32.1;
use warnings;
use Carp;

open my $input, '<', "inputs/day_21.txt" or die "$!";

my @map;
my ( $x, $y );
while ( my $line = <$input> ) {
    chomp $line;
    if ( index( $line, 'S' ) >= 0 ) {
        ( $x, $y ) = ( scalar @map, index( $line, 'S' ) );
    }
    push @map, [ split //, $line ];
}

close $input;

my ( $h, $w ) = ( scalar @map, scalar @{ $map[0] } );

croak "crap" if $h != $w;

my %visited;

__walk( \@map, \%visited );

my @reached = grep { $_ <= 64 && $_ % 2 == 0 } values %visited;
say scalar @reached;

sub __walk {
    my ( $map, $visited ) = @_;

    my @queue = ( [ $x, $y, 0 ] );
    while ( @queue > 0 ) {
        my $size = @queue;
        for ( 1 .. $size ) {
            my $cur = shift @queue;
            my ( $i, $j, $dist ) = ( $cur->[0], $cur->[1], $cur->[2] );
            for my $dir ( [ 0, 1 ], [ 0, -1 ], [ 1, 0 ], [ -1, 0 ] ) {
                my ( $ni, $nj ) = ( $i + $dir->[0], $j + $dir->[1] );
                if ( $ni >= 0 && $ni < $h && $nj >= 0 && $nj < $w ) {
                    if ( $map->[$ni]->[$nj] ne '#'
                        && !exists $visited->{"$ni,$nj"} )
                    {
                        push @queue, [ $ni, $nj, $dist + 1 ];
                        $visited->{"$ni,$nj"} = $dist + 1;
                    }
                }
            }
        }
    }
}

# part2
# ...wth
# https://github.com/villuna/aoc23/wiki/A-Geometric-solution-to-advent-of-code-2023,-day-21

my $even_reached = grep { $_ % 2 == 0 } values %visited;
my $odd_reached  = grep { $_ % 2 == 1 } values %visited;
my $even_corners = grep { $_ % 2 == 0 && $_ > 65 } values %visited;
my $odd_corners  = grep { $_ % 2 == 1 && $_ > 65 } values %visited;

my $steps  = 26501365;
my $n      = ( $steps - int( $h / 2 ) ) / $h;
my $odd_a  = ( $n + 1 )**2;
my $even_b = $n**2;

say $odd_a * $odd_reached + $even_b * $even_reached -
  ( $n + 1 ) * $odd_corners + $n * $even_corners;

__DATA__
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
