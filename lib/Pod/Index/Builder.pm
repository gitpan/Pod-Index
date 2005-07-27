package Pod::Index::Builder;

use 5.008;
$VERSION = '0.10';

use strict;
use warnings;

use base qw(Pod::Parser);

####### Pod::Parser overriden methods

sub verbatim {
    #my ($self, $text, $line_num, $pod_para) = @_;
    # do nothing
}

sub textblock {
    my ($self, $text, $line_num, $pod_para) = @_;
    $self->_pi_para($text, $line_num, $pod_para);
}

sub command {
    my ($self, $cmd, $text, $line_num, $pod_para)  = @_;
    $self->_pi_para($text, $line_num, $pod_para);
}

sub interior_sequence { 
    my ($self, $seq_command, $seq_argument, $seq_obj) = @_ ;
    if ($seq_command eq 'X') {
        push @{$self->{pi_pod_index}{$seq_argument}}, $self->{pi_pos};
    }
    return '';
}


###### new methods

sub _pi_para {
    my ($self, $text, $line_num, $pod_para) = @_;
    $self->{pi_pos} = $pod_para->file_line;
    $self->interpolate($text, $line_num);
}

sub pod_index { shift->{pi_pod_index} }

sub print_index {
    my ($self, $f) = @_;

    # figure out filehandle
    my $fh;
    if ($f and !ref $f) {
        open $fh, ">", $f or die "couldn't open $f: $!\n";
    } elsif ($f) {
        $fh = $f;
    } else {
        $fh ||= *STDOUT;
    }

    # print out the index
    my $idx = $self->pod_index;
    for my $key (sort keys %$idx) {
        for my $pos (sort @{$idx->{$key}}) {
            print $fh "$key\t$pos\n";
        }
    }
}

1;

__END__

=head1 NAME

Pod::Index::Builder - Build a pod index

=head1 SYNOPSYS

    use Pod::Index::Builder;

    my $p = Pod::Index::Builder->new;
    for my $file (@ARGV) {
        $p->parse_from_file($file);
    }

    $p->print_index;

=head1 DESCRIPTION

This is a subclass of L<Pod::Parser> that reads POD and outputs nothing.
However, it saves the position of every XE<lt>> entry it sees. The index can
be retrieved as a hashref, or printed to the output filehandle in a format
that is understandable by L<Pod::Index::Search>.

=head1 METHODS

=over

=item pod_index

Retrieves the index as a hashref. The hash keys are the keywords contained
in the XE<lt>> tags; the values are array references of "positions", in 
the format "filename:line_number". A sample use, taken from the C<print_index>
method, is as follows:

    my $idx = $p->pod_index;

    for my $key (sort keys %$idx) {
        for my $pos (@{$idx->{$key}}) {
            print $fh "$key\t$pos\n";
        }
    }


=item print_index

    $parser->print_index($fh);
    $parser->print_index($filename);
    $parser->print_index();

Prints the index to the given ouput filename or filehandle (or STDOUT by
default). The format is tab-delimited, with the key name in the first column,
and the position (filename:linenumber) in the second column.

=back

=head1 SEE ALSO

L<Pod::Index>,
L<Pod::Index::Search>,
L<Pod::Parser>,
L<perlpod>

=head1 AUTHOR

Ivan Tubert-Brohman E<lt>itub@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (c) 2005 Ivan Tubert-Brohman. All rights reserved. This program is
free software; you can redistribute it and/or modify it under the same terms as
Perl itself.

=cut

