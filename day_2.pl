use v5.32.1;
use warnings;

# part1
open my $input, '<', "inputs/day_2.txt" or die "$!";

my $sum       = 0;
my $red_cap   = 12;
my $green_cap = 13;
my $blue_cap  = 14;

while ( my $line = <$input> ) {

    my $valid = 1;
    my ( $id, $sets ) = $line =~ /Game (\d+): (.*)$/;
    my @sets = split /;\s/, $sets;

    for my $set (@sets) {
        my @red   = $set =~ /(\d+)\sred/;
        my @green = $set =~ /(\d+)\sgreen/;
        my @blue  = $set =~ /(\d+)\sblue/;
        if ( scalar @red > 0 && $red[0] > $red_cap ) {
            $valid = 0;
            last;
        }
        if ( scalar @green > 0 && $green[0] > $green_cap ) {
            $valid = 0;
            last;
        }
        if ( scalar @blue > 0 && $blue[0] > $blue_cap ) {
            $valid = 0;
            last;
        }

    }

    $sum += $id if $valid == 1;
}

say $sum;

# part2
$sum = 0;
open $input, '<', "inputs/day_2.txt" or die "$!";

while ( my $line = <$input> ) {

    my ( $min_red, $min_green, $min_blue ) = ( 0, 0, 0 );
    my ( $id, $sets ) = $line =~ /Game (\d+): (.*)$/;
    my @sets = split /;\s/, $sets;

    for my $set (@sets) {
        my @red   = $set =~ /(\d+)\sred/;
        my @green = $set =~ /(\d+)\sgreen/;
        my @blue  = $set =~ /(\d+)\sblue/;

        if ( scalar @red > 0 && $red[0] > $min_red ) {
            $min_red = $red[0];
        }
        if ( scalar @green > 0 && $green[0] > $min_green ) {
            $min_green = $green[0];
        }
        if ( scalar @blue > 0 && $blue[0] > $min_blue ) {
            $min_blue = $blue[0];
        }
    }

    $sum += $min_red * $min_green * $min_blue;
}

say $sum;

close $input;
