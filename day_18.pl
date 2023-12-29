use v5.32.1;
use warnings;
use List::Util qw(min max sum);

open my $input, '<', "inputs/day_18.txt" or die "$!";

my @plan;
while ( my $line = <$input> ) {
    chomp $line;
    my ( $dir, $step, $RGB ) = $line =~ /(\w)\s(\d+)\s\((.*)\)/;
    push @plan, [ $dir, $step, $RGB ];
}

close $input;

my %dir_mapping = (
    R => [ 0,  1 ],
    L => [ 0,  -1 ],
    D => [ 1,  0 ],
    U => [ -1, 0 ],
);

my ( @trench, @map );
my ( $x, $y, $min_x, $min_y, $max_x, $max_y ) =
  ( 0, 0, 2**31 - 1, 2**31 - 1, -2**31 - 1, -2**31 - 1 );
for my $dig (@plan) {
    my ( $nx, $ny ) = ( $x, $y );
    for ( 1 .. $dig->[1] ) {
        ( $nx, $ny ) = (
            $x + ( $dir_mapping{ $dig->[0] }->[0] * $_ ),
            $y + ( $dir_mapping{ $dig->[0] }->[1] * $_ )
        );

        push @trench, [ $nx, $ny ];

        $min_x = min( $min_x, $nx );
        $min_y = min( $min_y, $ny );
        $max_x = max( $max_x, $nx );
        $max_y = max( $max_y, $ny );
    }
    ( $x, $y ) = ( $nx, $ny );
}

my ( $h, $w, $offset_x, $offset_y ) =
  ( $max_x - $min_x + 1, $max_y - $min_y + 1, $min_x - 0, $min_y - 0 );
for ( 1 .. $h ) {
    push @map, [ ('.') x $w ];
}

for my $dig (@trench) {
    $map[ $dig->[0] - $offset_x ]->[ $dig->[1] - $offset_y ] = '#';
}

my $filled = 0;

# __draw_map( \@map );

map { $filled += __fill( \@map, [ 0, $_ ] ); } 0 .. $w - 1;         # top
map { $filled += __fill( \@map, [ $_, 0 ] ); } 0 .. $h - 1;         # left
map { $filled += __fill( \@map, [ $_, $w - 1 ] ); } 0 .. $h - 1;    # right
map { $filled += __fill( \@map, [ $h - 1, $_ ] ); } 0 .. $w - 1;    # bottom

# __draw_map( \@map );

say $h * $w - $filled;

sub __draw_map {
    my ($map) = @_;

    map { say join( '', @$_ ) } @$map;
}

sub __fill {
    my ( $map, $from ) = @_;

    my @queue  = ($from);
    my $filled = 0;
    while ( @queue > 0 ) {
        my $cur = shift @queue;
        next if $map[ $cur->[0] ]->[ $cur->[1] ] ne '.';

        $map[ $cur->[0] ]->[ $cur->[1] ] = 'O';
        $filled++;
        for my $dir ( values %dir_mapping ) {
            my ( $i, $j ) = ( $cur->[0] + $dir->[0], $cur->[1] + $dir->[1] );
            if ( $i >= 0 && $i < $h && $j >= 0 && $j < $w ) {
                if ( $map[$i]->[$j] eq '.' ) {
                    push @queue, [ $i, $j ];
                }
            }
        }
    }
    return $filled;
}

# part2
my %pd = (
    0 => 'R',
    1 => 'D',
    2 => 'L',
    3 => 'U',
);

( $x, $y ) = ( 0, 0 );
my @digs;
my $trench = 0;
for my $dig (@plan) {
    my ( $hex, $dir ) = $dig->[2] =~ /#(\w{5})(\w)/;

    my ( $step, $delta ) = ( hex($hex), $dir_mapping{ $pd{$dir} } );
    my ( $nx, $ny ) = ( $x + $delta->[0] * $step, $y + $delta->[1] * $step );
    push @digs, [ $nx, $ny ];
    ( $x, $y ) = ( $nx, $ny );
    $trench += $step;
}

# https://11011110.github.io/blog/2021/04/17/picks-shoelaces.html
my $area = abs(
    sum map {
        $digs[$_]->[0] *
          ( $digs[ $_ - 1 ]->[1] - $digs[ ( $_ + 1 ) % @digs ]->[1] )
    } 0 .. @digs - 1
) / 2;

my $interior = $area - $trench / 2 + 1;

say $interior + $trench;

__DATA__
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
