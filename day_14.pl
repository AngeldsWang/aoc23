use v5.32.1;
use warnings;
use JSON;

open my $input, '<', "inputs/day_14.txt" or die "$!";

my ( $sum1,      $sum2 ) = ( 0, 0 );
my ( @platform,  @load );
my ( @row_rocks, @col_rocks );

while ( my $line = <$input> ) {
    chomp $line;
    my @row = split //, $line;
    push @platform, \@row;
}

close $input;

my ( $h, $w ) = ( scalar @platform, scalar @{ $platform[0] } );
while ( my ( $i, $row ) = each(@platform) ) {
    push @load, [ ('.') x $w ];
    for my $col ( grep { $row->[$_] eq 'O' } 0 .. $w - 1 ) {
        $load[$i]->[$col] = 'O';
    }
}

map { push @col_rocks, {} } 0 .. $w - 1;
map { push @row_rocks, {} } 0 .. $h - 1;

while ( my ( $i, $row ) = each(@platform) ) {
    map { $row_rocks[$i]->{$_} = 1; } grep { $row->[$_] eq '#' } 0 .. $w - 1;
    map { $col_rocks[$_]->{$i} = 1; } grep { $row->[$_] eq '#' } 0 .. $w - 1;
}

my %iter = (
    NORTH => [ [ 0 .. $w - 1 ], [ reverse( 0 .. $h - 1 ) ] ],
    WEST  => [ [ 0 .. $h - 1 ], [ reverse( 0 .. $w - 1 ) ] ],
    SOUTH => [ [ 0 .. $w - 1 ], [ 0 .. $h - 1 ] ],
    EAST  => [ [ 0 .. $h - 1 ], [ 0 .. $w - 1 ] ],
);

sub __tilt {
    my ( $platform, $dir ) = @_;

    my $iters = $iter{$dir};
    my @loaded;
    map { push @loaded, [ ('.') x $w ] } 0 .. $h - 1;

    for my $i ( @{ $iters->[0] } ) {
        my $cnt = 0;
        for my $j ( @{ $iters->[1] } ) {
            if ( __lookup_rock( $dir, $i, $j ) ) {    # hit cube rock
                __set_load( \@loaded, $dir, $i, $j, $cnt );
                $cnt = 0;
            }
            else {
                $cnt++ if __lookup_load( $platform, $dir, $i, $j );
            }
        }

        __set_load( \@loaded, $dir, $i, -1, $cnt );
    }

    return \@loaded;
}

sub __lookup_rock {
    my ( $dir, $i, $j ) = @_;
    if ( $dir eq 'NORTH' or $dir eq 'SOUTH' ) {
        return exists $col_rocks[$i]->{$j};
    }

    return exists $row_rocks[$i]->{$j};
}

sub __lookup_load {
    my ( $loaded, $dir, $i, $j ) = @_;

    if ( $dir eq 'NORTH' or $dir eq 'SOUTH' ) {
        return $loaded->[$j]->[$i] eq 'O';
    }

    return $loaded->[$i]->[$j] eq 'O';
}

sub __set_load {
    my ( $loaded, $dir, $i, $j, $cnt ) = @_;

    my ( $h, $w ) = ( scalar @$loaded, scalar @{ $loaded->[0] } );

    if ( $dir eq 'NORTH' ) {
        while ( $cnt > 0 ) {
            $loaded->[ $j + $cnt ][$i] = 'O';
            $cnt--;
        }
    }
    elsif ( $dir eq 'SOUTH' ) {
        $j = $h if $j == -1;
        while ( $cnt > 0 ) {
            $loaded->[ $j - $cnt ][$i] = 'O';
            $cnt--;
        }
    }
    elsif ( $dir eq 'WEST' ) {
        while ( $cnt > 0 ) {
            $loaded->[$i][ $j + $cnt ] = 'O';
            $cnt--;
        }
    }
    else {
        $j = $w if $j == -1;
        while ( $cnt > 0 ) {
            $loaded->[$i][ $j - $cnt ] = 'O';
            $cnt--;
        }
    }
}

sub __calc_total_load {
    my ($loaded) = @_;

    my $total = 0;
    my $h     = scalar @$loaded;
    while ( my ( $i, $row ) = each(@$loaded) ) {
        my @load = grep { $_ eq 'O' } @$row;
        $total += ( $h - $i ) * @load;
    }

    return $total;
}

# part1
my $loaded = __tilt( \@platform, 'NORTH' );
say __calc_total_load($loaded);

# part2
$loaded = \@load;
my $iter         = 0;
my @all_patterns = ($loaded);
my %seen         = ( encode_json($loaded) => 0 );
my $last_seen    = -1;
for ( ; ; ) {
    for my $dir ( 'NORTH', 'WEST', 'SOUTH', 'EAST' ) {
        $loaded = __tilt( $loaded, $dir );
    }
    $iter++;
    my $key = encode_json($loaded);
    if ( exists $seen{$key} ) {
        $last_seen = $seen{$key};
        last;
    }

    $seen{$key} = scalar @all_patterns;
    push @all_patterns, $loaded;
}

my $idx =
  $last_seen + ( ( 1_000_000_000 - $last_seen ) % ( $iter - $last_seen ) );

my $final_loaded = $all_patterns[$idx];

say __calc_total_load($final_loaded);

__DATA__
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
