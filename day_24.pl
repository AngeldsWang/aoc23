use v5.32.1;
use warnings;
use List::Util qw(min max first);
use Carp;

use constant {
    LOWER => 200000000000000,
    UPPER => 400000000000000,
};

open my $input, '<', "inputs/day_24.txt" or die "$!";

my @hailstones;
while ( my $line = <$input> ) {
    chomp $line;
    my ( $x, $y, $z, $dx, $dy, $dz ) = $line =~ /(-?\d+)/g;
    push @hailstones,
      { x => $x, y => $y, z => $z, dx => $dx, dy => $dy, dz => $dz };
}

close $input;

sub __compute_intersection {
    my ( $A, $B ) = @_;

    my $d = $A->{dx} * $B->{dy} - $B->{dx} * $A->{dy};

    # parallel
    return if $d == 0;

    my $a =
      ( $B->{dy} * ( $B->{x} - $A->{x} ) - $B->{dx} * ( $B->{y} - $A->{y} ) ) /
      $d;

    my $b =
      ( $A->{dy} * ( $B->{x} - $A->{x} ) - $A->{dx} * ( $B->{y} - $A->{y} ) ) /
      $d;

    return {
        x           => $A->{x} + $A->{dx} * $a,
        y           => $A->{y} + $A->{dy} * $a,
        timestamp_a => $a,
        timestamp_b => $b,
    };
}

my $sum = 0;
while ( my ( $i, $hs ) = each @hailstones ) {
    for my $j ( 0 .. $i - 1 ) {
        my $is = __compute_intersection( $hs, $hailstones[$j] );
        if ( defined $is ) {
            if (   $is->{x} >= LOWER
                && $is->{x} <= UPPER
                && $is->{y} >= LOWER
                && $is->{y} <= UPPER
                && $is->{timestamp_a} >= 0
                && $is->{timestamp_b} >= 0 )
            {
                $sum++;
            }
        }
    }
}

say $sum;

# part2;

my ( $A, $B ) = ( $hailstones[0], $hailstones[1] );
my $range = 300;

for my $drx ( -$range .. $range ) {
    for my $dry ( -$range .. $range ) {
        for my $drz ( -$range .. $range ) {
            next if $drx == 0 || $dry == 0 || $drz == 0;

            my $d = ( $B->{dy} - $dry ) * ( $drx - $A->{dx} ) -
              ( $drx - $B->{dx} ) * ( $A->{dy} - $dry );

            next if $d == 0;

         # rock probably can hit A and B at timestamp a if only cacluate x and y
            my $a =
              ( ( $drx - $B->{dx} ) * ( $A->{y} - $B->{y} ) +
                  ( $B->{dy} - $dry ) * ( $A->{x} - $B->{x} ) ) /
              $d;

            # calculate rock's position based on $a;
            my $rx = $A->{x} + $A->{dx} * $a - $drx * $a;
            my $ry = $A->{y} + $A->{dy} * $a - $dry * $a;
            my $rz = $A->{z} + $A->{dz} * $a - $drz * $a;

            my $all_hit = 1;
            for my $hs (@hailstones) {
                my $b;
                if ( $hs->{dx} - $drx != 0 ) {
                    $b = ( $rx - $hs->{x} ) / ( $hs->{dx} - $drx );
                }
                elsif ( $hs->{dy} - $dry != 0 ) {
                    $b = ( $ry - $hs->{y} ) / ( $hs->{dy} - $dry );
                }
                elsif ( $hs->{dz} - $drz != 0 ) {
                    $b = ( $rz - $hs->{z} ) / ( $hs->{dz} - $drz );
                }
                else {
                    croak("impossible!");
                }

                if (   ( $rx + $b * $drx != $hs->{x} + $b * $hs->{dx} )
                    || ( $ry + $b * $dry != $hs->{y} + $b * $hs->{dy} )
                    || ( $rz + $b * $drz != $hs->{z} + $b * $hs->{dz} ) )
                {
                    $all_hit = 0;
                }
            }

            if ($all_hit) {
                say sprintf(
"rock starts on (%d, %d, %d), at the velocity of (%d, %d, %d)",
                    $rx, $ry, $rz, $drx, $dry, $drz );
                say $rx + $ry + $rz;
                exit(0);
            }
        }
    }
}

=pod
part1
A: (x + dx * a, y + dy * a)
B: (x + dx * b, y + dy * b)

A intersect with B at time (a, b)
x1 + dx1 * a = x2 + dx2 * b
y1 + dy1 * a = y2 + dy2 * b

dx1*a - dx2*b = x2 - x1
dy1*a - dy2*b = y2 - y1

dx1*dy2*a - dx2*dy2*b = dy2(x2 - x1)
dx2*dy1*a - dx2*dy2*b = dx2(y2 - y1)

a = (dy2(x2 - x1) - dx2(y2 - y1)) / (dx1*dy2 - dx2*dy1)

dx1*dy1*a - dx2*dy1*b = dy1(x2 - x1)
dx1*dy1*a - dx1*dy2*b = dx1(y2 - y1)

b = (dy1(x2 - x1) - dx1(y2 - y1)) / (dx1*dy2 - dx2*dy1)
=cut

=pod
part2
A: [x1 + dx1 * a, y1 + dy1 * a]
R: [rx + drx * a, ry + dry * a]

B: [x2 + dx2 * b, y2 + dy2 * b]
R: [rx + drx * b, ry + dry * b]


1: x1 + dx1 * a = rx + drx * a
2: y1 + dy1 * a = ry + dry * a

3: x2 + dx2 * b = rx + drx * b
4: y2 + dy2 * b = ry + dry * b

1-3: x1 - x2 + dx1*a - dx2*b = drx*a - drx*b -> b = ((drx - dx1)a - (x1 - x2)) / (drx - dx2)
2-4: y1 - y2 + dy1*a - dy2*b = dry*a - dry*b -> y1 - y2 + (dy1 - dry)a = (dy2 - dry)b = (dy2 - dry) * ((drx - dx1)a - (x1 - x2)) / (drx - dx2)


a = ((drx - dx2)(y1 - y2) + (dy2 - dry)(x1 - x2)) / ((dy2 - dry)(drx - dx1) - (drx - dx2)(dy1 - dry))

=cut

__DATA__
19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3
