use v5.32.1;
use warnings;

open my $input, '<', "inputs/day_12.txt" or die "$!";

my %cache;

my ( $sum1, $sum2 ) = ( 0, 0 );
while ( my $line = <$input> ) {
    chomp $line;
    my ( $record, $damaged ) = $line =~ /^(.*)\s(.*)$/;

    my @damages = split ',', $damaged;

    $sum1 += __arrange_v2( $record, \@damages );

    my $unfolded_record  = join '?', ($record) x 5;
    my @unfolded_damages = (@damages) x 5;

    $sum2 += __arrange_v2( $unfolded_record, \@unfolded_damages );
}

say $sum1;
say $sum2;

close $input;

sub __is_valid {
    my ( $record, $damages ) = @_;

    my @records = $record =~ /#+/g;

    return 0 unless @records == @$damages;

    my @matched =
      grep { length $records[$_] == $damages->[$_] } 0 .. @records - 1;

    return scalar @matched == scalar @$damages ? 1 : 0;
}

sub __arrange {
    my ( $record, $damages, $idx ) = @_;

    if ( $idx == length $record ) {
        return __is_valid( $record, $damages ) ? 1 : 0;
    }

    if ( '?' eq substr( $record, $idx, 1 ) ) {
        return __arrange(
            substr( $record, 0, $idx ) . "#" . substr( $record, $idx + 1 ),
            $damages, $idx + 1 ) +
          __arrange(
            substr( $record, 0, $idx ) . "." . substr( $record, $idx + 1 ),
            $damages, $idx + 1 );
    }

    return __arrange( $record, $damages, $idx + 1 );
}

sub __request_key {
    my ( $record, $damages ) = @_;

    return $record . join( ',', @$damages );
}

sub __arrange_v2 {
    my ( $record, $damages ) = @_;

    if ( length $record == 0 ) {
        return @$damages == 0 ? 1 : 0;
    }

    if ( @$damages == 0 ) {
        return $record =~ /#/ ? 0 : 1;
    }

    my $key = __request_key( $record, $damages );
    return $cache{$key} if exists $cache{$key};

    my $way  = 0;
    my $r    = substr $record, 0, 1;
    my @rest = @$damages;

    if ( $r eq '.' or $r eq '?' ) {
        $way += __arrange_v2( substr( $record, 1 ), \@rest );
    }

    if ( $r eq '#' or $r eq '?' ) {
        my $next   = $rest[0];
        my $lookup = substr $record, 0, $next;
        if (
                $next <= length $record
            and $lookup !~ /\./
            and ( $next == length $record
                or substr( $record, $next, 1 ) ne '#' )
          )
        {
            shift @rest;
            $record =
              length $record >= $next + 1 ? substr( $record, $next + 1 ) : "";

            $way += __arrange_v2( $record, \@rest );
        }
    }

    $cache{$key} = $way;

    return $way;
}

__DATA__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
