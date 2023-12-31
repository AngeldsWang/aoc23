use v5.32.1;
use warnings;
use List::Util qw(min max all);

open my $input, '<', "inputs/day_22.txt" or die "$!";

my @bricks;
while ( my $line = <$input> ) {
    chomp $line;

    my ( $from, $to ) = split /~/, $line;
    push @bricks, { from => [ split /,/, $from ], to => [ split /,/, $to ] };
}

close $input;

@bricks = sort { __cmp( $a, $b ) } @bricks;

sub __cmp {
    my ( $a, $b ) = @_;

    return -1 if $a->{from}->[2] < $b->{from}->[2];
    return 1  if $a->{from}->[2] > $b->{from}->[2];

    return -1 if $a->{to}->[2] < $b->{to}->[2];
    return 1  if $a->{to}->[2] > $b->{to}->[2];

    return 0;
}

sub __is_overlapped {
    my ( $a, $b ) = @_;

    max( $a->{from}->[0], $b->{from}->[0] ) <=
      min( $a->{to}->[0], $b->{to}->[0] )
      && max( $a->{from}->[1], $b->{from}->[1] ) <=
      min( $a->{to}->[1], $b->{to}->[1] );
}

while ( my ( $i, $brick ) = each @bricks ) {
    my $cur_z = 1;
    for my $j ( 0 .. $i - 1 ) {
        my $prev = $bricks[$j];
        if ( __is_overlapped( $brick, $prev ) ) {  # find max z from prev bricks
            $cur_z = max( $cur_z, $prev->{to}->[2] + 1 );
        }
    }
    my $falling = $brick->{from}->[2] - $cur_z;
    $brick->{to}->[2]   -= $falling;
    $brick->{from}->[2] -= $falling;
}

@bricks = sort { __cmp( $a, $b ) } @bricks;

my ( %support, %supported );
map { $support{$_}   = [] } 0 .. @bricks - 1;
map { $supported{$_} = [] } 0 .. @bricks - 1;

while ( my ( $i, $brick ) = each @bricks ) {
    for my $j ( 0 .. $i - 1 ) {
        my $prev = $bricks[$j];
        if ( __is_overlapped( $brick, $prev )
            && $prev->{to}->[2] + 1 == $brick->{from}->[2] )
        {
            push @{ $support{$j} },   $i;
            push @{ $supported{$i} }, $j;
        }
    }
}

my $disintegrate = 0;
while ( my ( $i, $supports ) = each %support ) {

    # all $i supports are supported by others;
    if ( all { scalar @{ $supported{$_} } >= 2 } @$supports ) {
        $disintegrate++;
    }
}

say $disintegrate;

# part2

my $falling = 0;
while ( my ( $i, $supports ) = each %support ) {
    my @solely_i = grep { scalar @{ $supported{$_} } == 1 } @$supports;

    my @queue  = @solely_i;
    my %falled = map { ( $_ => 1 ) } @solely_i;

    while (@queue) {
        my $cur = shift @queue;
        for my $j ( @{ $support{$cur} } ) {
            my $deps = $supported{$j};
            if ( all { exists $falled{$_} } @$deps ) {
                push @queue, $j;
                $falled{$j} = 1;
            }
        }
    }

    $falling += scalar( keys %falled );
}

say $falling;

__DATA__
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
