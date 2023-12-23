use v5.32.1;
use warnings;

open my $input, '<', "inputs/day_7.txt" or die "$!";

my %order = (
    '2' => 2,
    '3' => 3,
    '4' => 4,
    '5' => 5,
    '6' => 6,
    '7' => 7,
    '8' => 8,
    '9' => 9,
    'T' => 10,
    'J' => 11,
    'Q' => 12,
    'K' => 13,
    'A' => 14,
);

my %new_order = (
    '2' => 2,
    '3' => 3,
    '4' => 4,
    '5' => 5,
    '6' => 6,
    '7' => 7,
    '8' => 8,
    '9' => 9,
    'T' => 10,
    'J' => 1,
    'Q' => 12,
    'K' => 13,
    'A' => 14,
);

my ( $win1, $win2 ) = ( 0, 0 );
my @hands;
while ( my $line = <$input> ) {
    my ( $hand, $bid ) = $line =~ /(.*)\s+(\d+)$/;
    push @hands, [ $hand, $bid ];
}

my @ranked_hands = sort { __order_cmp( $a->[0], $b->[0] ) } @hands;

while ( my ( $rank, $hand ) = each(@ranked_hands) ) {
    $win1 += ( $rank + 1 ) * $hand->[1];
}

say $win1;

# part2
my @new_ranked_hands = sort { __new_order_cmp( $a->[0], $b->[0] ) } @hands;

while ( my ( $rank, $hand ) = each(@new_ranked_hands) ) {
    say $rank + 1, ", ", $hand->[0], ", ", $hand->[1];
    $win2 += ( $rank + 1 ) * $hand->[1];
}

say $win2;

sub __order_cmp {
    my ( $a, $b ) = @_;

    return -1 if __hand_type($a) < __hand_type($b);
    return 1  if __hand_type($a) > __hand_type($b);

    my @ca = split //, $a;
    my @cb = split //, $b;
    for ( 0 .. 4 ) {
        return -1 if ( $order{ $ca[$_] } < $order{ $cb[$_] } );
        return 1  if ( $order{ $ca[$_] } > $order{ $cb[$_] } );
    }

    return 0;
}

sub __new_order_cmp {
    my ( $a, $b ) = @_;

    return -1 if __new_hand_type($a) < __new_hand_type($b);
    return 1  if __new_hand_type($a) > __new_hand_type($b);

    my @ca = split //, $a;
    my @cb = split //, $b;
    for ( 0 .. 4 ) {
        return -1 if ( $new_order{ $ca[$_] } < $new_order{ $cb[$_] } );
        return 1  if ( $new_order{ $ca[$_] } > $new_order{ $cb[$_] } );
    }

    return 0;
}

sub __hand_type {
    my ($hand) = @_;
    my @cards  = split //, $hand;

    my %types;
    for my $card (@cards) {
        if ( !exists $types{$card} ) {
            $types{$card} = 1;
        }
        else {
            $types{$card}++;
        }
    }

    if ( keys %types == 1 ) {
        return 7;
    }

    if ( grep { $_ == 4 } values %types ) {
        return 6;
    }

    if ( grep { $_ == 3 } values %types ) {
        if ( keys %types == 2 ) {
            return 5;
        }
        elsif ( keys %types == 3 ) {
            return 4;
        }
    }

    if ( grep { $_ == 2 } values %types ) {
        if ( keys %types == 3 ) {
            return 3;
        }
        elsif ( keys %types == 4 ) {
            return 2;
        }
    }

    return 1;
}

sub __new_hand_type {
    my ($hand) = @_;
    my @cards  = split //, $hand;

    my %types;
    for my $card (@cards) {
        if ( !exists $types{$card} ) {
            $types{$card} = 1;
        }
        else {
            $types{$card}++;
        }
    }

    return __hand_type($hand) if ( !exists $types{J} );

    my $num_j = $types{J};
    delete $types{J};
    my @sorted_card = sort { $types{$b} <=> $types{$a} } keys %types;

    return 7 if @sorted_card == 0;

    my $rest = $types{ $sorted_card[0] };

    if ( $num_j + $rest == 5 ) {
        return 7;
    }

    if ( $num_j + $rest == 4 ) {
        return 6;
    }

    if ( $num_j + $rest == 3 ) {
        my @pairs = grep { $_ == 2 } values %types;
        if ( @pairs == 2 ) {
            return 5;
        }
        else {
            return 4;
        }
    }

    return 2 if $rest == 1;

    return 1;
}

close $input;

__DATA__
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
