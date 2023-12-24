use v5.32.1;
use warnings;
use List::Util qw(sum);

open my $input, '<', "inputs/day_9.txt" or die "$!";

my $sum1 = 0;
my $sum2 = 0;

while ( my $line = <$input> ) {

    my @hist = $line =~ /-?\d+/g;

    my $curr  = \@hist;
    my @first = $hist[0];
    my @last  = $hist[$#hist];
    until ( __is_all_zero($curr) ) {
        my $next = __compute_diff($curr);
        $curr = $next;
        if ( scalar @$curr > 0 ) {
            push @last, $curr->[ scalar @$curr - 1 ];
            unshift @first, $curr->[0];
        }
    }

    my $prev = 0;
    for my $p (@first) {
        $prev = $p - $prev;
    }

    $sum1 += sum @last;
    $sum2 += $prev;
}

say $sum1;
say $sum2;

sub __compute_diff {
    my ($arr) = @_;

    my @diff;
    for ( my $i = 0 ; $i < scalar @$arr - 1 ; $i++ ) {
        push @diff, $arr->[ $i + 1 ] - $arr->[$i];
    }

    return \@diff;
}

sub __is_all_zero {
    my ($arr) = @_;

    my @zeros = grep { $_ == 0 } @$arr;

    return @zeros == @$arr;
}

close $input;

__DATA__
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
