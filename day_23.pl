use v5.32.1;
use warnings;
use List::Util qw(min max first);

open my $input, '<', "inputs/day_23.txt" or die "$!";

my @map;
while ( my $line = <$input> ) {
    chomp $line;

    push @map, [ split //, $line ];
}

close $input;

my ( $h, $w ) = ( scalar @map, scalar @{ $map[0] } );

my $start = [ 0, first { $map[0]->[$_] eq '.' } 0 .. $w - 1 ];
my $end   = [ $h - 1, first { $map[ $h - 1 ]->[$_] eq '.' } 0 .. $w - 1 ];

my %dirs_mapping = (
    '.' => [ [ 0,  1 ], [ 0, -1 ], [ 1, 0 ], [ -1, 0 ] ],
    '>' => [ [ 0,  1 ] ],
    '<' => [ [ 0,  -1 ] ],
    'v' => [ [ 1,  0 ] ],
    '^' => [ [ -1, 0 ] ],
);

sub __key {
    my ($a) = @_;

    $a->[0] . "," . $a->[1];
}

sub __from_key {
    my ($key) = @_;

    return [ split /,/, $key ];
}

# edge contraction
my %minors = (
    __key($start) => { from => $start, to => {} },
    __key($end)   => { from => $end,   to => {} }
);
while ( my ( $i, $row ) = each @map ) {
    while ( my ( $j, $col ) = each @$row ) {
        if ( $col ne '#' ) {
            my $conn = 0;
            for my $dir ( @{ $dirs_mapping{"."} } ) {
                my ( $ni, $nj ) = ( $i + $dir->[0], $j + $dir->[1] );
                if (   $ni >= 0
                    && $ni < $h
                    && $nj >= 0
                    && $nj < $w
                    && $map[$ni]->[$nj] ne '#' )
                {
                    $conn++;
                }
            }

            $minors{ __key( [ $i, $j ] ) } = {
                from => [ $i, $j ],
                to   => {},
              }
              if ( $conn >= 3 );
        }
    }
}

while ( my ( $key, $minor ) = each %minors ) {
    my $from  = $minor->{from};
    my @stack = ( [ $from, 0 ] );
    my %seen  = ( __key($from) => 1 );
    while ( @stack > 0 ) {
        my $cur = pop @stack;
        if ( $cur->[1] != 0 && exists $minors{ __key( $cur->[0] ) } ) {
            $minors{$key}->{to}->{ __key( $cur->[0] ) } = $cur->[1];
            next;
        }

        my ( $i, $j ) = ( $cur->[0]->[0], $cur->[0]->[1] );
        for my $dir ( @{ $dirs_mapping{'.'} } ) {
            my ( $ni, $nj ) = ( $i + $dir->[0], $j + $dir->[1] );
            if (   $ni >= 0
                && $ni < $h
                && $nj >= 0
                && $nj < $w
                && $map[$ni]->[$nj] ne '#'
                && !exists $seen{ __key( [ $ni, $nj ] ) } )
            {
                $seen{ __key( [ $ni, $nj ] ) } = 1;
                push @stack, [ [ $ni, $nj ], $cur->[1] + 1 ];
            }
        }
    }
}

my %visited;

sub __dfs {
    my ($from) = @_;

    return 0 if ( $from->[0] == $end->[0] && $from->[1] == $end->[1] );

    my $longest = -2**63 - 1;
    $visited{ __key($from) } = 1;
    while ( my ( $key, $dist ) = each %{ $minors{ __key($from) }->{to} } ) {
        if ( !exists $visited{$key} ) {
            $longest = max( $longest, __dfs( __from_key($key) ) + $dist );
        }
    }
    delete $visited{ __key($from) };

    return $longest;
}

say __dfs($start);

__DATA__
#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#
