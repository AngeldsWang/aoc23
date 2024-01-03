use v5.32.1;
use warnings;
use Carp;
use PDL;
use PDL::LinearAlgebra;

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

# part 2 newton method
my @cases = map { [ $_->{x}, $_->{y}, $_->{z}, $_->{dx}, $_->{dy}, $_->{dz} ] }
  @hailstones[ 0 .. 2 ];

my $epsilon = 1e-5;
my $x0      = pdl( 0, 0, 0, 1, 2, 3, 1, 2, 3 );
my $x       = $x0;
while (1) {
    my $j     = __jacobian( $x, \@cases );
    my $fn    = __fx( $x, \@cases );
    my $delta = msolve( $j, $fn )->slice('(0),:');
    $x += $delta;
    last if ( sqrt( inner( $delta, $delta ) ) < $epsilon );
}

say $x->slice("0:2")->sum;

sub __jacobian {
    my ( $x, $cases ) = @_;

    return pdl [
        [ 1, 0, 0, $x->at(6), 0, 0, $x->at(3) - $cases->[0]->[3], 0, 0 ],
        [ 0, 1, 0, 0, $x->at(6), 0, $x->at(4) - $cases->[0]->[4], 0, 0 ],
        [ 0, 0, 1, 0, 0, $x->at(6), $x->at(5) - $cases->[0]->[5], 0, 0 ],
        [ 1, 0, 0, $x->at(7), 0, 0, 0, $x->at(3) - $cases->[1]->[3], 0 ],
        [ 0, 1, 0, 0, $x->at(7), 0, 0, $x->at(4) - $cases->[1]->[4], 0 ],
        [ 0, 0, 1, 0, 0, $x->at(7), 0, $x->at(5) - $cases->[1]->[5], 0 ],
        [ 1, 0, 0, $x->at(8), 0, 0, 0, 0, $x->at(3) - $cases->[2]->[3] ],
        [ 0, 1, 0, 0, $x->at(8), 0, 0, 0, $x->at(4) - $cases->[2]->[4] ],
        [ 0, 0, 1, 0, 0, $x->at(8), 0, 0, $x->at(5) - $cases->[2]->[5] ],
    ];
}

sub __fx {
    my ( $x, $cases ) = @_;

    return pdl [
        [
            -1 * (
                $x->at(0) +
                  ( $x->at(3) - $cases->[0]->[3] ) * $x->at(6) -
                  $cases->[0]->[0]
            )
        ],
        [
            -1 * (
                $x->at(1) +
                  ( $x->at(4) - $cases->[0]->[4] ) * $x->at(6) -
                  $cases->[0]->[1]
            )
        ],
        [
            -1 * (
                $x->at(2) +
                  ( $x->at(5) - $cases->[0]->[5] ) * $x->at(6) -
                  $cases->[0]->[2]
            )
        ],
        [
            -1 * (
                $x->at(0) +
                  ( $x->at(3) - $cases->[1]->[3] ) * $x->at(7) -
                  $cases->[1]->[0]
            )
        ],
        [
            -1 * (
                $x->at(1) +
                  ( $x->at(4) - $cases->[1]->[4] ) * $x->at(7) -
                  $cases->[1]->[1]
            )
        ],
        [
            -1 * (
                $x->at(2) +
                  ( $x->at(5) - $cases->[1]->[5] ) * $x->at(7) -
                  $cases->[1]->[2]
            )
        ],
        [
            -1 * (
                $x->at(0) +
                  ( $x->at(3) - $cases->[2]->[3] ) * $x->at(8) -
                  $cases->[2]->[0]
            )
        ],
        [
            -1 * (
                $x->at(1) +
                  ( $x->at(4) - $cases->[2]->[4] ) * $x->at(8) -
                  $cases->[2]->[1]
            )
        ],
        [
            -1 * (
                $x->at(2) +
                  ( $x->at(5) - $cases->[2]->[5] ) * $x->at(8) -
                  $cases->[2]->[2]
            )
        ],
    ];
}

__END__

=pod
https://en.wikipedia.org/wiki/Newton%27s_method#Systems_of_equations

rx + drx * t1 = x1 + dx1 * t1
ry + dry * t1 = y1 + dy1 * t1
rz + drz * t1 = z1 + dz1 * t1

rx + drx * t2 = x2 + dx2 * t2
ry + dry * t2 = y2 + dy2 * t2
rz + drz * t2 = z2 + dz2 * t2

rx + drx * t3 = x3 + dx3 * t3
ry + dry * t3 = y3 + dy3 * t3
rz + drz * t3 = z3 + dz3 * t3

rx + (drx - dx1) * t1 - x1 = 0
ry + (dry - dy1) * t1 - y1 = 0
rz + (drz - dz1) * t1 - z1 = 0
rx + (drx - dx2) * t2 - x2 = 0
ry + (dry - dy2) * t2 - y2 = 0
rz + (drz - dz2) * t2 - z2 = 0
rx + (drx - dx3) * t3 - x3 = 0
ry + (dry - dy3) * t3 - y3 = 0
rz + (drz - dz3) * t3 - z3 = 0


Jacobian(Xn):
[1, 0, 0, t1, 0, 0, drx - dx1, 0, 0]
[0, 1, 0, 0, t1, 0, dry - dy1, 0, 0]
[0, 0, 1, 0, 0, t1, drz - dz1, 0, 0]
[1, 0, 0, t2, 0, 0, 0, drx - dx2, 0]
[0, 1, 0, 0, t2, 0, 0, dry - dy2, 0]
[0, 0, 1, 0, 0, t2, 0, drz - dz2, 0]
[1, 0, 0, t3, 0, 0, 0, 0, drx - dx3]
[0, 1, 0, 0, t3, 0, 0, 0, dry - dy3]
[0, 0, 1, 0, 0, t3, 0, 0, drz - dz3]

Jacobian(Xn)(Xn+1 - Xn) = -F(Xn)

=cut

# part2 brute force;

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
            my $fail    = 0;
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
                    say sprintf(
"rock starts on (%d, %d, %d), at the velocity of (%d, %d, %d), hailstone: (%d, %d, %d, %d, %d, %d),",
                        $rx,      $ry,       $rz,       $drx,
                        $dry,     $drz,      $hs->{x},  $hs->{y},
                        $hs->{z}, $hs->{dx}, $hs->{dy}, $hs->{dz}
                    );
                    last;
                    $fail = 1;
                }

                if (   ( $rx + $b * $drx != $hs->{x} + $b * $hs->{dx} )
                    || ( $ry + $b * $dry != $hs->{y} + $b * $hs->{dy} )
                    || ( $rz + $b * $drz != $hs->{z} + $b * $hs->{dz} ) )
                {
                    $all_hit = 0;
                }
            }
            next if ($fail);

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
