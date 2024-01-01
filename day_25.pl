use v5.32.1;
use warnings;
use List::Util      qw(head);
use List::MoreUtils qw(slide minmaxstr);
use Graph::Undirected;
use Carp;

open my $input, '<', "inputs/day_25.txt" or die "$!";

my $g = Graph::Undirected->new;
while ( my $line = <$input> ) {
    chomp $line;
    my ( $from, $to_nodes ) = $line =~ /(\w+):\s(.*)$/g;
    for my $to ( split /\s/, $to_nodes ) {
        $g->add_edge( $from, $to );
    }
}

close $input;

my %edge_counter;
my $seen_top3 = '';
my $stable    = 0;
my @top3;

while ( $stable < 500 ) {
    my $from = $g->random_vertex;
    my $to   = $g->random_vertex;
    next if $from eq $to;

    my @path = $g->SP_Dijkstra( $from, $to );
    slide { $edge_counter{ join( "=", minmaxstr( $a, $b ) ) }++ } @path;
    @top3 = head 3,
      sort { $edge_counter{$b} <=> $edge_counter{$a} } keys %edge_counter;

    my $cur_top3 = join ',', @top3;
    $stable    = 0 if $cur_top3 ne $seen_top3;
    $seen_top3 = $cur_top3;
    $stable++;
}

for my $edge (@top3) {
    my ( $from, $to ) = split "=", $edge;
    $g->delete_edge( $from, $to );
}

my @cc = $g->connected_components();
croak("oh no..") if @cc != 2;

say scalar @{ $cc[0] } * scalar @{ $cc[1] };

__DATA__
jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr
