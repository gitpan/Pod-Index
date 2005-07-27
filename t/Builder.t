use strict;
use warnings;
use Test::More;

#plan 'no_plan';
plan tests => 3;

use_ok("Pod::Index::Builder");

my $p = Pod::Index::Builder->new;

isa_ok($p, "Pod::Index::Builder");

$p->parse_from_file('t/test.pod');

open my $fh, ">", \(my $got) or die;
$p->print_index($fh);

open my $fh_exp, "<", "t/test.txt" or die;
my $expected = do { local $/; <$fh_exp> };

is($got, $expected, "index ok");
