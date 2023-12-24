use v5.32.1;
use warnings;

open my $input, '<', "inputs/day_10.txt" or die "$!";

my $map = [];
my $l   = 0;
my ( $x, $y );
while ( my $line = <$input> ) {
    chomp $line;
    my @row = split //, $line;
    my $idx = index( $line, 'S' );
    if ( $idx >= 0 ) {
        ( $x, $y ) = ( $l, $idx );
    }
    push @$map, \@row;
    $l++;
}

close $input;

my ( $h, $w ) = ( scalar @$map, scalar @{ $map->[0] } );
my $visited = [];
for ( 1 .. $h ) {
    push @$visited, [ ('.') x $w ];
}

my %dir = (
    0 => [ 0,  -1 ],    # left
    1 => [ -1, 0 ],     # up
    2 => [ 0,  1 ],     # right
    3 => [ 1,  0 ],     # down
);

my %opts = (
    0 => [ '-', 'F', 'L' ],    # left
    1 => [ '|', 'F', '7' ],    # up
    2 => [ '-', 'J', '7' ],    # right
    3 => [ '|', 'J', 'L' ],    # down
);

my %pipe = (
    '-' => [ 0, 2 ],
    '|' => [ 1, 3 ],
    'F' => [ 2, 3 ],
    'J' => [ 0, 1 ],
    'L' => [ 1, 2 ],
    '7' => [ 0, 3 ],
    'S' => [ 0, 1, 2, 3 ],
);

my %dir2pipe = (
    '02' => '-',
    '13' => '|',
    '23' => 'F',
    '01' => 'J',
    '12' => 'L',
    '03' => '7',
);

my @queue;
push @queue, [ $x, $y ];

my $step = 0;
my $end  = 0;
while ( @queue > 0 ) {
    my $size = @queue;
    for ( 1 .. $size ) {
        my $c = shift @queue;
        my ( $i, $j ) = ( $c->[0], $c->[1] );
        my ( $p, $vp ) = ( $map->[$i]->[$j], $visited->[$i]->[$j] );
        if ( $vp ne '.' ) {    # meet in loop
            $end = 1;
            last;
        }

        $visited->[$i]->[$j] = $p;    # mark
        my $dirs = $pipe{$p};

        my @available;
        for my $d (@$dirs) {
            my $opt = $opts{$d};
            my ( $ni, $nj ) = ( $i + $dir{$d}->[0], $j + $dir{$d}->[1] );

            if ( $ni >= 0 && $ni < $h && $nj >= 0 && $nj < $w ) {
                my ( $np, $nvp ) =
                  ( $map->[$ni]->[$nj], $visited->[$ni]->[$nj] );
                if ( $nvp eq '.' and grep { $_ eq $np } @$opt ) {
                    push @queue,     [ $ni, $nj ];
                    push @available, $d;
                }
            }
        }

        if ( $p eq 'S' ) {    # fill S
            my $pp = $dir2pipe{ join( '', @available ) };
            $visited->[$i]->[$j] = $pp;
        }
    }

    last if $end == 1;

    $step++;
}

say $step;

my $nest = 0;
for my $row (@$visited) {
    my $line = join '', @$row;
    my @stack;
    if ( $line =~ /^\.*(.*?)\.*$/ ) {
        my $trimed = $1;
        while ( $trimed =~ /(\||L-*J|L-*7|F-*J|F-*7)/g ) {
            my ( $cur, $start, $end ) = ( $1, $-[0], $+[0] );
            if ( $cur =~ /(\||L-*7|F-*J)/ ) {
                if ( @stack == 0 ) {
                    push @stack, $cur;
                }
                else {
                    pop @stack;
                }
            }

            my $p = $end;
            while ( $p < length $trimed && substr( $trimed, $p, 1 ) eq '.' ) {
                if ( @stack > 0 ) {
                    $nest++;
                }
                $p++;
            }
        }
    }

}

say $nest;

__DATA__
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJIF7FJ-
L---JF-JLJIIIIFJLJJ7
|F|F-JF---7IIIL7L|7|
|FFJF7L7F-JF7IIL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
