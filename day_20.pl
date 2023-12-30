use v5.32.1;
use warnings;
use List::Util qw(reduce);

use constant {
    OFF => 0,
    ON  => 1,
};

use constant LOW_PULSE  => 0x11;
use constant HIGH_PULSE => 0xff;

open my $input, '<', "inputs/day_20.txt" or die "$!";

my ( %flipflops, %conjunctions, @broadcasted, %connections );
while ( my $line = <$input> ) {
    chomp $line;
    if ( $line =~ /^broadcaster\s->\s(.*)$/ ) {
        @broadcasted = $1 =~ /\w+/g;
    }
    if ( $line =~ /^%(\w+)\s->\s(.*)$/ ) {
        my $ff = $1;
        $flipflops{$ff} = OFF;
        my @conns = $2 =~ /\w+/g;
        $connections{$ff} = \@conns;
    }

    if ( $line =~ /^&(\w+)\s->\s(.*)$/ ) {
        my $conj = $1;
        $conjunctions{$conj} = {};
        my @conns = $2 =~ /\w+/g;
        $connections{$conj} = \@conns;
    }
}

close $input;

__initialize_conjunctions( \%conjunctions, \%connections );

my ( $loop, $low, $high ) = ( 0, 0, 0 );
do {
    my ( $l, $h ) = __broadcast(LOW_PULSE);
    $loop++;
    $low  += $l;
    $high += $h;
} while (
    $loop < 1000

    # && !__is_reset( \%flipflops, \%conjunctions )
);

say $low * $high;

# part2
__reset_filpflops( \%flipflops );
__initialize_conjunctions( \%conjunctions, \%connections );
my %watch;
while ( my ( $from, $to ) = each(%connections) ) {
    if ( grep { $_ eq 'rx' } @$to ) {
        $watch{target} = $from;
    }
}
$watch{inputs} = {};
while ( my ( $from, $to ) = each(%connections) ) {
    if ( grep { $_ eq $watch{target} } @$to ) {
        $watch{inputs}->{$from} = 0;
    }
}

my $count = 0;
my @watched;
for ( ; ; ) {
    $count++;
    __broadcast( LOW_PULSE, \%watch, $count );
    @watched = grep { $_ > 0 } values %{ $watch{inputs} };
    last if @watched == keys %{ $watch{inputs} };
}

say reduce { lcm( $a, $b ) } @watched;

sub __initialize_conjunctions {
    my ( $conjs, $conns ) = @_;

    while ( my ( $from, $to ) = each(%$conns) ) {
        for my $conj ( grep { exists $conjs->{$_} } @$to ) {
            $conjs->{$conj}->{$from} = LOW_PULSE;
        }
    }
}

sub __reset_filpflops {
    my ($flipflops) = @_;
    for my $ff ( keys %$flipflops ) {
        $flipflops{$ff} = OFF;
    }
}

sub __is_reset {
    my ( $flipflops, $conjunctions ) = @_;

    for my $status ( values %$flipflops ) {
        return 0 if $status == ON;
    }

    while ( my ( $conj, $input ) = each %$conjunctions ) {
        if ( $conj ne 'output' ) {
            for my $p ( values %$input ) {
                return 0 if $p == HIGH_PULSE;
            }
        }
    }

    return 1;
}

sub __broadcast {
    my ( $pulse, $watch, $counter ) = @_;

    my @queue;
    for my $ff (@broadcasted) {
        push @queue, [ $ff, 'broadcaster', $pulse ];
    }

    my ( $low, $high ) = ( 1, 0 );
    while ( @queue > 0 ) {

        my $cur = shift @queue;
        my ( $mod, $input, $pulse ) = ( $cur->[0], $cur->[1], $cur->[2] );

        if (   defined $watch
            && defined $counter
            && exists $watch->{inputs}->{$input}
            && $watch->{target} eq $mod
            && $pulse == HIGH_PULSE )
        {
            $watch->{inputs}->{$input} = $counter;
        }

        if ( $pulse == LOW_PULSE ) {
            $low++;
        }
        else {
            $high++;
        }

        my $out;
        if ( exists $flipflops{$mod} ) {
            $out = __trigger_ff( $mod, $pulse );
        }
        else {
            $out = __trigger_conj( $mod, $input, $pulse );
        }

        if ($out) {
            my $conns = $connections{$mod};
            for my $conn (@$conns) {
                push @queue, [ $conn, $mod, $out ];
            }
        }
    }

    return $low, $high;
}

sub __trigger_ff {
    my ( $ff, $pulse ) = @_;

    return if ( $pulse == HIGH_PULSE );

    if ( $flipflops{$ff} == OFF ) {
        $flipflops{$ff} = ON;
        return HIGH_PULSE;
    }

    $flipflops{$ff} = OFF;
    return LOW_PULSE;
}

sub __trigger_conj {
    my ( $conj, $input, $pulse ) = @_;

    $conjunctions{$conj}->{$input} = $pulse;

    for my $mem ( values %{ $conjunctions{$conj} } ) {
        if ( $mem == LOW_PULSE ) {
            return HIGH_PULSE;
        }
    }

    return LOW_PULSE;
}

sub gcd {
    my ( $x, $y ) = @_;
    while ($x) { ( $x, $y ) = ( $y % $x, $x ) }
    $y;
}

sub lcm {
    my ( $x, $y ) = @_;
    ( $x && $y ) and $x / gcd( $x, $y ) * $y or 0;
}

__DATA__
# broadcaster -> a, b, c
# %a -> b
# %b -> c
# %c -> inv
# &inv -> a
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
