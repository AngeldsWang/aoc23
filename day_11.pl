use v5.32.1;
use warnings;

use constant { EXPAN => 1_000_000 };

open my $input, '<', "inputs/day_11.txt" or die "$!";

my @image;
my ( @rows, @cols );
my $row = 0;
while ( my $line = <$input> ) {
    chomp $line;
    push @image, [ split( //, $line ) ],;
    if ( $line !~ /#/ ) {
        push @rows, $row;
    }
    $row++;
}

close $input;

my @old_galaxies;
while ( my ( $i, $row ) = each(@image) ) {
    while ( my ( $j, $col ) = each(@$row) ) {
        if ( $col eq '#' ) {
            push @old_galaxies, [ $i, $j ];
        }
    }
}

for my $col ( 0 .. scalar @{ $image[0] } - 1 ) {
    my $expand = 1;
    for my $row (@image) {
        if ( $row->[$col] eq '#' ) {
            $expand = 0;
            last;
        }
    }

    if ( $expand == 1 ) {
        push @cols, $col;
    }
}

__expand_rows( \@image, \@rows );
__expand_cols( \@image, \@cols );

my @galaxies;
while ( my ( $i, $row ) = each(@image) ) {
    while ( my ( $j, $col ) = each(@$row) ) {
        if ( $col eq '#' ) {
            push @galaxies, [ $i, $j ];
        }
    }
}

my ( $sum1, $sum2 ) = ( 0, 0 );
my $num = scalar @galaxies;
for ( my $i = 0 ; $i < $num ; $i++ ) {
    for ( my $j = $i + 1 ; $j < $num ; $j++ ) {
        $sum1 += abs( $galaxies[$i]->[0] - $galaxies[$j]->[0] ) +
          abs( $galaxies[$i]->[1] - $galaxies[$j]->[1] );
    }
}

say $sum1;

for ( my $i = 0 ; $i < $num ; $i++ ) {
    for ( my $j = $i + 1 ; $j < $num ; $j++ ) {
        $sum2 +=
          __calc_expanded_dist( $old_galaxies[$i], $old_galaxies[$j], \@rows,
            \@cols );
    }
}

say $sum2;

sub __calc_expanded_dist {
    my ( $from, $to, $rows, $cols ) = @_;

    my $orig = abs( $from->[0] - $to->[0] ) + abs( $from->[1] - $to->[1] );

    my @row_range = sort { $a <=> $b } ( $from->[0], $to->[0] );
    my @col_range = sort { $a <=> $b } ( $from->[1], $to->[1] );

    my @r_exp = grep { $_ > $row_range[0] && $_ < $row_range[1] } @$rows;
    my @c_exp = grep { $_ > $col_range[0] && $_ < $col_range[1] } @$cols;

    return $orig + @r_exp * ( EXPAN - 1 ) + @c_exp * ( EXPAN - 1 );
}

sub __expand_rows {
    my ( $image, $rows ) = @_;

    my $w = scalar @{ $image[0] };
    while ( my ( $idx, $row ) = each(@$rows) ) {
        splice @$image, $row + $idx, 0, [ ('.') x $w ];
    }
}

sub __expand_cols {
    my ( $image, $cols ) = @_;

    while ( my ( $idx, $col ) = each(@$cols) ) {
        for ( 0 .. scalar @$image - 1 ) {
            splice @{ $image->[$_] }, $col + $idx, 0, '.';
        }
    }
}

__DATA__
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
