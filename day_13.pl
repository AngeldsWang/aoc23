use v5.32.1;
use warnings;
use experimental 'smartmatch';

open my $input, '<', "inputs/day_13.txt" or die "$!";

my ( $sum1, $sum2 ) = ( 0, 0 );
my @pattern;
while ( my $line = <$input> ) {
    chomp $line;
    if ( length $line == 0 ) {
        $sum1 += __calc_reflection( \@pattern );
        $sum2 += __calc_reflection( \@pattern, 1 );
        @pattern = ();
    }

    push @pattern, $line if length $line > 0;
}

$sum1 += __calc_reflection( \@pattern )    if @pattern > 0;
$sum2 += __calc_reflection( \@pattern, 1 ) if @pattern > 0;

sub __calc_reflection {
    my ( $pattern, $with_smudge ) = @_;

    my $r = __calc_rows( $pattern, $with_smudge );
    my $c = __calc_cols( $pattern, $with_smudge );

    return $r * 100 + $c;
}

sub __calc_rows {
    my ( $pattern, $with_smudge ) = @_;
    return $with_smudge ? __do_calc_smudge($pattern) : __do_calc($pattern);
}

sub __calc_cols {
    my ( $pattern, $with_smudge ) = @_;

    my @cols;
    my $w = length $pattern->[0];
    for ( 0 .. $w - 1 ) {
        my @col;
        for my $r (@$pattern) {
            push @col, substr( $r, $_, 1 );
        }
        push @cols, join( '', @col );
    }

    return $with_smudge ? __do_calc_smudge( \@cols ) : __do_calc( \@cols );
}

sub __do_calc {
    my ($pattern) = @_;

    my $res = 0;
    for ( 1 .. @$pattern - 1 ) {
        my @top    = reverse @$pattern[ 0 .. $_ - 1 ];
        my @bottom = @$pattern[ $_ .. @$pattern - 1 ];

        my $len = @top > @bottom ? @bottom : @top;
        @top    = @top[ 0 .. $len - 1 ];
        @bottom = @bottom[ 0 .. $len - 1 ];

        return $_ if ( @top ~~ @bottom );
    }

    return 0;
}

sub __do_calc_smudge {
    my ($pattern) = @_;

    my $res = 0;
    for ( 1 .. @$pattern - 1 ) {
        my @top    = reverse @$pattern[ 0 .. $_ - 1 ];
        my @bottom = @$pattern[ $_ .. @$pattern - 1 ];

        my $len = @top > @bottom ? @bottom : @top;
        @top    = @top[ 0 .. $len - 1 ];
        @bottom = @bottom[ 0 .. $len - 1 ];

        return $_ if __compare( \@top, \@bottom ) == 1;
    }

    return 0;
}

sub __compare {
    my ( $a, $b ) = @_;

    my $diff = 0;
    while ( my ( $i, $r ) = each(@$a) ) {
        next if $r eq $b->[$i];
        my @rc = split //, $r;
        my @cc = split //, $b->[$i];
        for ( 0 .. @rc - 1 ) {
            $diff++ if $rc[$_] ne $cc[$_];
        }
    }

    return $diff;
}

say $sum1;
say $sum2;

close $input;

__DATA__
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
