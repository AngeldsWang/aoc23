use v5.32.1;
use warnings;
use List::Util qw( min max );

open my $input, '<', "inputs/day_5.txt" or die "$!";

my @seeds;
my @maps = ( [], [], [], [], [], [], [] );

my $idx = -1;
while ( my $line = <$input> ) {
    if ( $line =~ /^seeds:\s+(.*)$/ ) {
        @seeds = $1 =~ /\d+/g;
    }

    if ( $line =~ /map/ ) {
        $idx++;
    }

    my @ranges = $line =~ /\d+/g;
    if ( scalar @ranges == 3 ) {
        push @{ $maps[$idx] }, \@ranges;
    }
}

while ( my ( $index, $map ) = each(@maps) ) {
    my @ranges = sort { $a->[1] <=> $b->[1] } @$map;
    $maps[$index] = \@ranges;
}

my $min1 = 2**63 - 1;

for my $seed (@seeds) {
    my $val = $seed;
    for my $map (@maps) {
        $val = __map_val( $map, $val );
    }

    $min1 = $val if $val < $min1;
}

say $min1;

sub __map_val {
    my ( $map, $seed ) = @_;

    my @sources = map { $_->[1] } @$map;
    my $lb      = __lower_bound( \@sources, $seed );

    if ( $lb == 0 ) {
        return $seed;
    }

    if ( $lb < scalar @sources && $sources[$lb] == $seed ) {
        return $map->[$lb]->[0];
    }

    if ( $sources[ $lb - 1 ] + $map->[ $lb - 1 ]->[2] >= $seed ) {
        return $map->[ $lb - 1 ]->[0] + $seed - $sources[ $lb - 1 ];
    }

    return $seed;
}

sub __lower_bound {
    my ( $arr, $val ) = @_;

    my ( $l, $r ) = ( 0, scalar @$arr );
    while ( $l < $r ) {
        my $m = int( ( $l + $r ) / 2 );
        if ( $arr->[$m] < $val ) {
            $l = $m + 1;
        }
        else {
            $r = $m;
        }
    }

    return $l;
}

# part2

my @ranges = ( [], [], [], [], [], [], [] );

while ( my ( $index, $map ) = each(@maps) ) {
    for my $part (@$map) {
        push @{ $ranges[$index] }, ( $part->[1], $part->[1] + $part->[2] - 1 );
    }
    if ( $ranges[$index]->[0] > 0 ) {
        my $s = $ranges[$index]->[0];
        unshift @{ $ranges[$index] }, ( 0, $s - 1 );
        unshift @$map, [ 0, 0, $s ];
    }
}

my $min2 = 2**63 - 1;
for ( my $i = 0 ; $i < @seeds ; $i += 2 ) {
    my $start = $seeds[$i];
    my $end   = $start + $seeds[ $i + 1 ] - 1;

    my @inputs = ( $start, $end );

    while ( my ( $index, $map ) = each(@maps) ) {
        my @outputs;
        for ( my $idx = 0 ; $idx < scalar @inputs ; $idx += 2 ) {
            my $out = __map_range( $map, $ranges[$index], $inputs[$idx],
                $inputs[ $idx + 1 ] );
            push @outputs, @$out;

        }

        @inputs = @outputs;

    }

    my $min_loc = min @inputs;

    if ( $min_loc < $min2 ) {
        $min2 = $min_loc;
    }
}

say $min2;

sub __map_range {
    my ( $map, $range, $start, $end ) = @_;

    my $lb_s = __lower_bound( $range, $start );

    if ( $lb_s == scalar @$range ) {
        return [ $start, $end ];
    }

    my @out;

    for ( my $i = 0 ; $i < int( scalar @$range / 2 ) ; $i++ ) {
        my ( $from, $to ) = ( $range->[ $i * 2 ], $range->[ $i * 2 + 1 ] );

        next if $to < $start;
        last if $from > $end;

        if ( $start >= $from ) {
            push @out, $map->[$i]->[0] + $start - $from;
        }
        else {
            push @out, $map->[$i]->[0];
        }

        if ( $end <= $to ) {
            push @out, $map->[$i]->[0] + $end - $from;
        }
        else {
            push @out, $map->[$i]->[0] + $map->[$i]->[2] - 1;
        }

    }

    if ( $end > $range->[ @$range - 1 ] ) {
        push @out, ( $range->[ @$range - 1 ] + 1, $end );
    }

    return \@out;
}

close $input;
