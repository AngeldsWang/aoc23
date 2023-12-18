use v5.32.1;
use warnings;

# part1
open my $input, '<', "inputs/day_3.txt" or die "$!";

my $mat = [];
my @lines;
while ( my $line = <$input> ) {
    chomp($line);
    push @$mat,  [ split //, $line ];
    push @lines, $line;
}

my $sum = 0;
my $row = 0;
for my $line (@lines) {
    while ( $line =~ /(\d+)/g ) {
        if ( _is_valid( $row, $-[0], $+[0] ) ) {
            $sum += $1;
        }
    }

    $row++;
}

sub _is_valid {
    my ( $row, $start, $end ) = @_;

    if ( $row > 0 ) {

        # up
        for ( my $i = $start ; $i < $end ; $i++ ) {
            return 1
              if $mat->[ $row - 1 ]->[$i] ne '.'
              && $mat->[ $row - 1 ]->[$i] !~ /\d/;
        }

        # up left
        return 1
          if $start > 0
          && $mat->[ $row - 1 ]->[ $start - 1 ] ne '.'
          && $mat->[ $row - 1 ]->[ $start - 1 ] !~ /\d/;

        # up right
        return 1
          if $end < scalar @{ $mat->[$row] }
          && $mat->[ $row - 1 ]->[$end] ne '.'
          && $mat->[ $row - 1 ]->[$end] !~ /\d/;
    }

    if ( $row < scalar @$mat - 1 ) {

        # down
        for ( my $i = $start ; $i < $end ; $i++ ) {
            return 1
              if $mat->[ $row + 1 ]->[$i] ne '.'
              && $mat->[ $row + 1 ]->[$i] !~ /\d/;
        }

        # down left
        return 1
          if $start > 0
          && $mat->[ $row + 1 ]->[ $start - 1 ] ne '.'
          && $mat->[ $row + 1 ]->[ $start - 1 ] !~ /\d/;

        # down right
        return 1
          if $end < scalar @{ $mat->[$row] }
          && $mat->[ $row + 1 ]->[$end] ne '.'
          && $mat->[ $row + 1 ]->[$end] !~ /\d/;
    }

    # left
    return 1 if $start > 0 && $mat->[$row]->[ $start - 1 ] ne '.';

    # right
    return 1
      if $end < scalar @{ $mat->[$row] }
      && $mat->[$row]->[$end] ne '.';

    return 0;
}

say $sum;

# part2

$sum = 0;
$row = 0;
my %gear_nums;
for my $line (@lines) {
    while ( $line =~ /(\d+)/g ) {
        my $gears = _find_gears( $row, $-[0], $+[0] );
        for my $gear (@$gears) {
            my $key = join( ",", @$gear );
            if ( !exists $gear_nums{$key} ) {
                $gear_nums{$key} = [];
            }
            push @{ $gear_nums{$key} }, $1;
        }
    }

    $row++;
}

for my $gear ( keys %gear_nums ) {
    if ( scalar @{ $gear_nums{$gear} } == 2 ) {
        $sum += $gear_nums{$gear}->[0] * $gear_nums{$gear}->[1];
    }
}

say $sum;

sub _find_gears {
    my ( $row, $start, $end ) = @_;

    my @gears;
    if ( $row > 0 ) {

        # up
        for ( my $i = $start ; $i < $end ; $i++ ) {
            push @gears, [ $row - 1, $i ] if $mat->[ $row - 1 ]->[$i] eq '*';
        }

        # up left
        push @gears, [ $row - 1, $start - 1 ]
          if $start > 0
          && $mat->[ $row - 1 ]->[ $start - 1 ] eq '*';

        # up right
        push @gears, [ $row - 1, $end ]
          if $end < scalar @{ $mat->[$row] }
          && $mat->[ $row - 1 ]->[$end] eq '*';
    }

    if ( $row < scalar @$mat - 1 ) {

        # down
        for ( my $i = $start ; $i < $end ; $i++ ) {
            push @gears, [ $row + 1, $i ]
              if $mat->[ $row + 1 ]->[$i] eq '*';
        }

        # down left
        push @gears, [ $row + 1, $start - 1 ]
          if $start > 0
          && $mat->[ $row + 1 ]->[ $start - 1 ] eq '*';

        # down right
        push @gears, [ $row + 1, $end ]
          if $end < scalar @{ $mat->[$row] }
          && $mat->[ $row + 1 ]->[$end] eq '*';
    }

    # left
    push @gears, [ $row, $start - 1 ]
      if $start > 0 && $mat->[$row]->[ $start - 1 ] eq '*';

    # right
    push @gears, [ $row, $end ]
      if $end < scalar @{ $mat->[$row] }
      && $mat->[$row]->[$end] eq '*';

    return \@gears;
}

close $input;
