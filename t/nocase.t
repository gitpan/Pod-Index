use strict;
use warnings;
use Test::More;

plan 'no_plan';
#plan tests => 4;

use_ok('Pod::Index::Search');

my ($q, @results);

####### CASE-SENSITIVE ##########

$q = Pod::Index::Search->new(
    filename => 't/test.txt',
);

@results = $q->search('tritium');
is( scalar @results, 1, 'tritium (case)');

@results = $q->search('Tritium');
is( scalar @results, 1, 'Tritium (case)');

@results = $q->subtopics('tritium');
is( scalar @results, 1, 'tritium subtopics (case)');

@results = $q->subtopics('Tritium');
is( scalar @results, 1, 'Tritium subtopics (case)');



####### CASE-INSENSITIVE ##########

$q = Pod::Index::Search->new(
    filename => 't/test.txt',
    nocase   => 1,
);

@results = $q->search('tritium');
is( scalar @results, 2, 'tritium (nocase)');

@results = $q->search('Tritium');
is( scalar @results, 2, 'Tritium (nocase)');

@results = $q->subtopics('tritium');
is( scalar @results, 2, 'tritium subtopics (nocase)');

@results = $q->subtopics('Tritium');
is( scalar @results, 2, 'Tritium subtopics (nocase)');



