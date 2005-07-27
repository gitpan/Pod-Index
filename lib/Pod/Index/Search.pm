package Pod::Index::Search;

use 5.008;
$VERSION = '0.10';

use strict;
use warnings;
use Search::Dict qw(look);
use Pod::Index::Entry;
use Carp qw(croak);

sub new {
    my ($class, %args) = @_;

    my $self = bless {
        %args,
    }, $class;

    if ($self->{filename}) {
        open my $fh, "<", $self->{filename} 
            or die "couldn't open $self->{filename}: $!\n";
        $self->{fh} = $fh;
    }

    unless ($self->{fh}) {
        require perlindex;
        $self->{fh} = *perlindex::DATA;
    }

    $self->{start} = tell $self->{fh};
    $self->{filemap} ||= sub { $_[0] };

    return $self;
}

sub search {
    my ($self, $keyword) = @_;

    croak "need a keyword " unless defined $keyword;
    my $fh      = $self->{fh};

    # hack to make 'look' skip everything before __DATA__:
    # everything before start always compares negatively
    my $start = $self->{start};
    look($fh, $keyword, {
        comp => sub { 
            tell($fh) <= $start ? -1 : $_[0] cmp $_[1];
        },
    });

    local $_;
    my @ret;
    while (<$fh>) {
        chomp;
        my ($entry, $pos) = split /\t/;
        last unless $entry eq $keyword;
        my ($file, $line) = split /:/, $pos;
        push @ret, Pod::Index::Entry->new(
            podname  => $file, 
            line     => $line,
            filename => $self->{filemap}($file),
        );
    }
    return @ret;
}


1;

__END__

=head1 NAME

Pod::Index::Search - Search for keywords in an indexed pod

=head1 SYNOPSYS

    use Pod::Index::Search;

    my $q = Pod::Index::Search->new;

    $q->search('getprotobyname');

    for my $e ($q->entries) {
        printf "%s\t%s\n", $e->podname, $e->line;
        print $e->pod;
    }

=head1 DESCRIPTION

=head1 METHODS

=over

=item new

    my $q = Pod::Index::Search->new(%args);

Create a new search object. Possible arguments are:

=over

=item fh

The filehandle of the index to use. If omitted, C<perlindex::DATA> is used.

=item filename

The filename of the index to use. Note that you can specify either fh or
filename, but not both.

=item filemap

A subroutine reference that takes a podname and returns a filename. A simple
example might be:

    sub {
        my $podname = shift;
        return "/usr/lib/perl5/5.8.7/pod/$podname";
    }

The podname is a relative pathname to an @INC directory, such as
F<Data/Dumper.pm>. The slashes are used as delimiters regardless of the
platform (see L<perlfunc/require>).

=back

=item search($keyword)

Do the actual search in the index.  Returns a list of search results, as
L<Pod::Index::Entry> objects.

=back

=head1 SEE ALSO

L<Pod::Index::Entry>

=head1 AUTHOR

Ivan Tubert-Brohman E<lt>itub@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (c) 2005 Ivan Tubert-Brohman. All rights reserved. This program is
free software; you can redistribute it and/or modify it under the same terms as
Perl itself.

=cut


