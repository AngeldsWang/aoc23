use v5.32.1;
use warnings;
use List::Util qw(min max sum);

open my $input, '<', "inputs/day_19.txt" or die "$!";

my ( %workflows, @parts, %to_workflow );
while ( my $line = <$input> ) {
    chomp $line;
    if ( $line =~ /^(\w+)\{(.*)\}$/ ) {
        my $name = $1;
        my ( $rules, $maps ) = __parse_rules( $1, $2 );
        $workflows{$name} = $rules;
        %to_workflow = ( %to_workflow, %$maps );
    }

    if ( $line =~ /^\{x=(\d+)\,m=(\d+)\,a=(\d+)\,s=(\d+)\}$/ ) {
        push @parts, { x => $1, m => $2, a => $3, s => $4 };
    }
}

close $input;

my $sum1 = 0;
for my $part (@parts) {
    my $res = __exec($part);
    if ( $res eq 'A' ) {
        $sum1 += sum map { $_ } values %$part;
    }
}

say $sum1;

# part2
my $sum2 = 0;
while ( my ( $name, $rules ) = each %workflows ) {
    $sum2 += __compute_rule( $name, $rules );
}

say $sum2;

sub __exec {
    my ($part) = @_;

    my $cur = 'in';
    do {
        for my $rule ( @{ $workflows{$cur} } ) {
            if ( @$rule == 4 ) {
                if ( $rule->[1] eq '<' ) {
                    if ( $part->{ $rule->[0] } < $rule->[2] ) {
                        if ( $rule->[3] eq 'A' ) {
                            $cur = 'A';
                        }
                        elsif ( $rule->[3] eq 'R' ) {
                            $cur = 'R';
                        }
                        else {
                            $cur = $rule->[3];
                        }
                        last;
                    }
                }
                else {
                    if ( $part->{ $rule->[0] } > $rule->[2] ) {
                        if ( $rule->[3] eq 'A' ) {
                            $cur = 'A';
                        }
                        elsif ( $rule->[3] eq 'R' ) {
                            $cur = 'R';
                        }
                        else {
                            $cur = $rule->[3];
                        }
                        last;
                    }
                }
            }
            else {
                if ( $rule->[0] eq 'A' ) {
                    $cur = 'A';
                }
                elsif ( $rule->[0] eq 'R' ) {
                    $cur = 'R';
                }
                else {
                    $cur = $rule->[0];
                }

                last;
            }
        }
    } while ( $cur ne 'A' and $cur ne 'R' );

    return $cur;
}

sub __parse_rules {
    my ( $name, $rules ) = @_;

    my ( @clauses, %map );
    my @sr = split /\,/, $rules;
    while ( my ( $idx, $rule ) = each(@sr) ) {
        if ( $rule =~ /([xams])([<>])(\d+):(\w+)/ ) {
            push @clauses, [ $1, $2, $3, $4 ];
        }
        else {
            push @clauses, [$rule];
        }

        if ( $clauses[-1]->[-1] ne 'A' and $clauses[-1]->[-1] ne 'R' ) {
            $map{ $clauses[-1]->[-1] } = {
                name => $name,
                idx  => $idx,
            };
        }
    }

    return \@clauses, \%map;
}

sub __compute_rule {
    my ( $name, $rules ) = @_;

    my @accepts = grep { __is_acceptable( $rules->[$_] ) } 0 .. @$rules - 1;

    return 0 if @accepts == 0;

    my $orig         = $rules;
    my $combinations = 0;
    for my $idx (@accepts) {
        my @queue;
        $rules = $orig;
        my ( $cur, $rule ) = ( $name, $rules->[$idx] );
        do {
            if ( @$rule == 4 ) {
                if ( $rule->[1] eq '>' ) {
                    push @queue, [ $rule->[0], ">=", $rule->[2] + 1 ];
                }
                else {
                    push @queue, [ $rule->[0], "<=", $rule->[2] - 1 ];
                }
            }
            while ( $idx-- > 0 ) {
                $rule = $rules->[$idx];
                push @queue, [ $rule->[0], __not( $rule->[1] ), $rule->[2] ];
            }

            if ( $cur ne 'in' ) {
                ( $cur, $idx ) =
                  ( $to_workflow{$cur}->{name}, $to_workflow{$cur}->{idx} );
                ( $rules, $rule ) =
                  ( $workflows{$cur}, $workflows{$cur}->[$idx] );
            }

        } while ( $cur ne 'in' or $idx >= 0 );

        $combinations += __compute_combination( \@queue );
    }

    return $combinations;
}

sub __compute_combination {
    my ($rules) = @_;

    my %intervals;
    for my $rule (@$rules) {
        if ( !exists $intervals{ $rule->[0] } ) {
            $intervals{ $rule->[0] } = {};
        }

        if ( !exists $intervals{ $rule->[0] }->{ $rule->[1] } ) {
            $intervals{ $rule->[0] }->{ $rule->[1] } = [];
        }

        push @{ $intervals{ $rule->[0] }->{ $rule->[1] } }, $rule->[2];
    }

    my ( $cnt, $comb ) = ( 0, 1 );
    for my $v ( keys %intervals ) {
        my ( @bottoms, @ups );
        if ( exists $intervals{$v}->{">="} ) {
            @bottoms = sort { $b <=> $a } @{ $intervals{$v}->{">="} };
        }
        if ( exists $intervals{$v}->{"<="} ) {
            @ups = sort { $a <=> $b } @{ $intervals{$v}->{"<="} };
        }
        $cnt++;
        my $bottom = @bottoms > 0 ? $bottoms[0] : 1;
        my $up     = @ups > 0     ? $ups[0]     : 4000;

        $comb *= ( $up - $bottom + 1 );
    }

    while ( $cnt < 4 ) {
        $comb *= 4000;
        $cnt++;
    }

    return $comb;
}

sub __is_acceptable {
    my ($rule) = @_;

    return $rule->[0] eq 'A' if @$rule == 1;

    return $rule->[3] eq 'A';
}

sub __not {
    my ($op) = @_;

    return '>=' if $op eq '<';    # op only can be <>
    return '<=' if $op eq '>';
}

__DATA__
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
