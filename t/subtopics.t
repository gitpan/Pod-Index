use strict;
use warnings;
use Test::More;
use File::Spec::Functions;

#plan 'no_plan';
plan tests => 4;

use_ok('Pod::Index::Search');

my $q = Pod::Index::Search->new(
    filename => catfile('t', 'test.txt'),
);

isa_ok($q, 'Pod::Index::Search');

my @subtopics = $q->subtopics('balloon');
is_deeply(
    \@subtopics, 
    ['balloon, floating', 'balloon, gas-filled', 'balloon, light'], 
    'topics'
);

@subtopics = $q->subtopics('balloon', deep => 1);
is_deeply(
    \@subtopics, 
    ['balloon, floating', 'balloon, gas-filled, helium', 'balloon, light'], 
    'topics'
);
