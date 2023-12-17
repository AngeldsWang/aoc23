use v5.32.1;
use warnings;

# part1
open my $input, '<', "inputs/day_1.txt" or die "$!";

my $sum = 0;
while ( my $line = <$input> ) {
    my @left  = $line =~ /^\D*(\d)/;
    my @right = $line =~ /(\d)\D*$/;
    $sum += $left[0] * 10 + $right[0];
}

say $sum;

# part2
$sum = 0;
my $map = {
    one   => 1,
    two   => 2,
    three => 3,
    four  => 4,
    five  => 5,
    six   => 6,
    seven => 7,
    eight => 8,
    nine  => 9,
};

open $input, '<', "inputs/day_1.txt" or die "$!";
while ( my $line = <$input> ) {
    my @left = $line =~ /(one|two|three|four|five|six|seven|eight|nine|\d)/;
    my @right =
      $line =~ /\G.*(one|two|three|four|five|six|seven|eight|nine|\d)/;

    if ( $left[0] =~ /\d/ ) {
        $sum += $left[0] * 10;
    }
    else {
        $sum += $map->{ $left[0] } * 10;
    }

    if ( $right[0] =~ /\d/ ) {
        $sum += $right[0];
    }
    else {
        $sum += $map->{ $right[0] };
    }
}

say $sum;

close $input;
