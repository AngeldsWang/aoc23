use v5.32.1;
use warnings;
use Array::Heap::PriorityQueue::Numeric;

use constant {
    STAY  => 0,
    RIGHT => 1,
    DOWN  => 2,
    LEFT  => 3,
    UP    => 4,
};

open my $input, '<', "inputs/day_17.txt" or die "$!";

my ( @map, @visited, @ultra );
while ( my $line = <$input> ) {
    chomp $line;
    push @map, [ split //, $line ];

    push @visited, [
        map {
            {
                &STAY    => [ (0) x 4 ],
                  &RIGHT => [ (0) x 4 ],
                  &DOWN  => [ (0) x 4 ],
                  &LEFT  => [ (0) x 4 ],
                  &UP    => [ (0) x 4 ],
            }
        } 0 .. length($line) - 1
    ];

    push @ultra, [
        map {
            {
                &STAY    => [ (0) x 11 ],
                  &RIGHT => [ (0) x 11 ],
                  &DOWN  => [ (0) x 11 ],
                  &LEFT  => [ (0) x 11 ],
                  &UP    => [ (0) x 11 ],
            }
        } 0 .. length($line) - 1
    ];
}

close $input;

my ( $h, $w ) = ( scalar @map, scalar @{ $map[0] } );

my %dir_mapping = (
    &STAY  => [ 0,  0 ],
    &RIGHT => [ 0,  1 ],
    &DOWN  => [ 1,  0 ],
    &LEFT  => [ 0,  -1 ],
    &UP    => [ -1, 0 ],
);

my $pq = Array::Heap::PriorityQueue::Numeric->new();
$pq->add( [ 0, 0, STAY, 0 ], 0 );

my $min_loss1;
while ( $pq->size() > 0 ) {
    my ( $loss, $cur ) = ( $pq->min_weight(), $pq->get() );

    my ( $i, $j, $dir, $step ) =
      ( $cur->[0], $cur->[1], $cur->[2], $cur->[3] );

    if ( $i == $h - 1 && $j == $w - 1 ) {
        $min_loss1 = $loss;
        last;
    }

    next if $visited[$i]->[$j]->{$dir}->[$step] > 0;

    $visited[$i]->[$j]->{$dir}->[$step] = 1;

    if ( $step < 3 && $dir != STAY ) {
        my ( $ni, $nj ) =
          ( $i + $dir_mapping{$dir}->[0], $j + $dir_mapping{$dir}->[1] );
        if ( $ni >= 0 && $ni < $h && $nj >= 0 && $nj < $w ) {
            $pq->add( [ $ni, $nj, $dir, $step + 1 ], $loss + $map[$ni]->[$nj] );
        }

    }

    for my $next ( RIGHT, DOWN, LEFT, UP ) {
        if ( $next != $dir
            && !__is_backward( $dir_mapping{$next}, $dir_mapping{$dir} ) )
        {
            my ( $ni, $nj ) =
              ( $i + $dir_mapping{$next}->[0], $j + $dir_mapping{$next}->[1] );

            if ( $ni >= 0 && $ni < $h && $nj >= 0 && $nj < $w ) {
                $pq->add( [ $ni, $nj, $next, 1 ], $loss + $map[$ni]->[$nj] );
            }
        }
    }
}

say $min_loss1;

sub __is_backward {
    my ( $x, $y ) = @_;

    -1 * $x->[0] == $y->[0] && -1 * $x->[1] == $y->[1];
}

# part2
$pq = Array::Heap::PriorityQueue::Numeric->new();
$pq->add( [ 0, 0, STAY, 0 ], 0 );

my $min_loss2;
while ( $pq->size() > 0 ) {
    my ( $loss, $cur ) = ( $pq->min_weight(), $pq->get() );

    my ( $i, $j, $dir, $step ) =
      ( $cur->[0], $cur->[1], $cur->[2], $cur->[3] );

    if ( $i == $h - 1 && $j == $w - 1 && $step >= 4 ) {
        $min_loss2 = $loss;
        last;
    }

    next if $ultra[$i]->[$j]->{$dir}->[$step] > 0;

    $ultra[$i]->[$j]->{$dir}->[$step] = 1;

    if ( $step < 10 && $dir != STAY ) {
        my ( $ni, $nj ) =
          ( $i + $dir_mapping{$dir}->[0], $j + $dir_mapping{$dir}->[1] );
        if ( $ni >= 0 && $ni < $h && $nj >= 0 && $nj < $w ) {
            $pq->add( [ $ni, $nj, $dir, $step + 1 ], $loss + $map[$ni]->[$nj] );
        }

    }

    if ( $step >= 4 || $dir == STAY ) {
        for my $next ( RIGHT, DOWN, LEFT, UP ) {
            if ( $next != $dir
                && !__is_backward( $dir_mapping{$next}, $dir_mapping{$dir} ) )
            {
                my ( $ni, $nj ) = (
                    $i + $dir_mapping{$next}->[0],
                    $j + $dir_mapping{$next}->[1]
                );

                if ( $ni >= 0 && $ni < $h && $nj >= 0 && $nj < $w ) {
                    $pq->add( [ $ni, $nj, $next, 1 ],
                        $loss + $map[$ni]->[$nj] );
                }
            }
        }
    }
}

say $min_loss2;

__DATA__
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
