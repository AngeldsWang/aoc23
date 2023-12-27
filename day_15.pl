use v5.32.1;
use warnings;

open my $input, '<', "inputs/day_15.txt" or die "$!";

my $line = <$input>;
chomp $line;

close $input;

my @strs = split /\,/, $line;

my ( $sum1, $sum2 ) = ( 0, 0 );

for my $str (@strs) {
    $sum1 += __calc_hash($str);
}

say $sum1;

# part2
my @boxes;
map { push @boxes, [] } 0 .. 255;
my %labels;
map { $labels{$_} => {} } 0 .. 255;

for my $str (@strs) {
    my ( $label, $op, $len ) = $str =~ /(\w+)([=-])(\d?)/;

    my $idx = __calc_hash($label);

    if ( $op eq '=' ) {
        if ( exists $labels{$idx}->{$label} ) {
            my $slot = $labels{$idx}->{$label};
            $boxes[$idx]->[$slot]->[1] = $len;
        }
        else {
            $labels{$idx}->{$label} = scalar @{ $boxes[$idx] };
            push @{ $boxes[$idx] }, [ $label, $len ],;
        }
    }
    else {
        if ( exists $labels{$idx}->{$label} ) {
            my $slot = $labels{$idx}->{$label};
            splice @{ $boxes[$idx] }, $slot, 1;
            delete $labels{$idx}->{$label};
            for my $lb ( keys %{ $labels{$idx} } ) {
                if ( $labels{$idx}->{$lb} > $slot ) {
                    $labels{$idx}->{$lb}--;
                }
            }
        }
    }
}

say __calc_power( \@boxes );

sub __calc_power {
    my ($boxes) = @_;

    my $power = 0;
    while ( my ( $i, $box ) = each(@boxes) ) {
        if ( @$box > 0 ) {
            for my $slot ( 1 .. @$box ) {
                my $lens = $box->[ $slot - 1 ];
                $power += ( $i + 1 ) * $slot * $lens->[1];
            }
        }
    }

    return $power;
}

sub __calc_hash {
    my ($str) = @_;

    my $hash  = 0;
    my @chars = split //, $str;
    for my $c (@chars) {
        $hash = ( ( $hash + ord($c) ) * 17 ) % 256;
    }

    return $hash;
}

__DATA__
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
