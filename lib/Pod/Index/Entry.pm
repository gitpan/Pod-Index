package Pod::Index::Entry;

use 5.008;
$VERSION = '0.10';

use strict;
use warnings;
use Pod::Index::Extract;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        %args, 
    }, $class;
    return $self;
}

sub podname  { shift->{podname}  }
sub line     { shift->{line}     }
sub filename { shift->{filename} }

sub pod {
    my ($self) = @_;

    return $self->{pod} if defined $self->{pod};

    my $filename = $self->filename;

    open my $in, "<", $filename or die "couldn't open $filename $!\n";
    open my $out, ">", \(my $pod) or die "couldn't open output fh: $!\n";

    my $parser  = Pod::Index::Extract->new(
        ppi_entry => $self,
    );

    <$in> for (1 .. $self->{line} - 1); # skip lines
    $parser->parse_from_filehandle($in, $out);

    return $self->{pod} = $pod;
}

1;


=head1 NAME

Pod::Index::Entry - Represents Pod search result

=head1 SYNOPSYS

    use Pod::Index::Entry;

    my $entry =  Pod::Index::Entry->new(
        podname  => 'perlobj.pod'
        line     => 42,
        filename => '/usr/lib/perl5/5.8.7/pod/perlobj.pod',
    );

    # trivial accessors
    my $podname  = $entry->podname;
    my $filename = $entry->filename;
    my $line     = $entry->line;

    # extract the POD for this entry
    my $pod      = $entry->pod;

=head1 DESCRIPTION

=head1 METHODS

=over

=item new

    my $q = Pod::Index::Entry->new(%args);

Create a new search object. Possible arguments are:

=over

=item podname

The name of the pod, as a path relative to an @INC directory.

=item filename

The filename for the pod.

=item line

The line number where the scope of this entry begins.

=back

=item podname

=item filename

=item line

These are just simple accessors that return the value of these properties,
as given to the constructor.

=item pod

Extracts the POD for the scope of the entry from $self->filename, beginning
at $self->line.

=back

=head1 SEE ALSO

L<Pod::Index>,
L<Pod::Index::Search>,
L<Pod::Index::Extract>

=head1 AUTHOR

Ivan Tubert-Brohman E<lt>itub@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (c) 2005 Ivan Tubert-Brohman. All rights reserved. This program is
free software; you can redistribute it and/or modify it under the same terms as
Perl itself.

=cut



