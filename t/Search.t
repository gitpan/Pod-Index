use strict;
use warnings;
use Test::More;

#plan 'no_plan';
plan tests => 27;

use_ok('Pod::Index::Search');

my $q = Pod::Index::Search->new(
    filename => 't/test.txt',
);

isa_ok($q, 'Pod::Index::Search');

my @results = $q->search('random');

is (scalar @results, 2, 'got 2 results for random');

push @results, $q->search('deuterium');
push @results, $q->search('head2');
push @results, $q->search('verbatim');
push @results, $q->search('synopsis');

my @expected = expected();

for my $res (@results) {
    isa_ok($res, 'Pod::Index::Entry');
    my $exp = shift @expected;
    is($res->line, $exp->{line}, "line=$exp->{line}");
    is($res->podname, $exp->{podname}, "podname=$exp->{podname}");
    is($res->pod, $exp->{pod}, "pod ok");
}


################## EXPECTED ################

sub expected {
    return (
        ###############################
        { line => 14, podname => 't/test.pod', pod => <<POD },
This is a random paragraph.
X<random>

POD

        ###############################
        { line => 50, podname => 't/test.pod', pod => <<POD },
=over

=item helium
X<helium>
X<ballon, floating>
X<random>

Helium is used for filling ballons.

=back

POD

        ###############################
        { line => 26, podname => 't/test.pod', pod => <<POD },
=over

=item hydrogen
X<hydrogen>
X<protium>
X<deuterium>
X<tritium>

=item deuterium

=item tritium

These are the isotopes of element 1. Let's add some nested items:

=over

=item H20

water

=item D2O

heavy water

=back

=back

POD

        ###############################
        { line => 59, podname => 't/test.pod', pod => <<POD },
=head2 HEAD2
X<head2>

This is to see if the head2 block is selected correctly.

    for example,

this paragraph should be included.

POD

        ###############################
        { line => 17, podname => 't/test.pod', pod => <<POD },
This is another paragraph, followed by a verbatim block or two:
X<verbatim>

    this is an example

    this is another example

POD

        ###############################
        { line => 5, podname => 't/test.pod', pod => <<POD },
=head1 SYNOPSIS
X<synopsis>

    blah blah blah

POD

    );
}

