package Catmandu::Exporter::Template;

use namespace::clean;
use Catmandu::Sane;
use Catmandu::Util qw(is_string);
use Catmandu;
use Template;
use Moo;

our $VERSION = '0.03';

with 'Catmandu::Exporter';

my $XML_DECLARATION = qq(<?xml version="1.0" encoding="UTF-8"?>\n);

my $ADD_TT_EXT = sub {
    my $tmpl = $_[0];
    is_string($tmpl) && $tmpl !~ /\.tt$/ ? "$tmpl.tt" : $tmpl;
};

has xml             => (is => 'ro');
has template_before => (is => 'ro', coerce => $ADD_TT_EXT);
has template        => (is => 'ro', coerce => $ADD_TT_EXT, required => 1);
has template_after  => (is => 'ro', coerce => $ADD_TT_EXT);

sub _tt {
    local $Template::Stash::PRIVATE = 0;
    state $tt = Template->new({
        ENCODING     => 'utf8',
        ABSOLUTE     => 1,
        ANYCASE      => 0,
        INCLUDE_PATH => Catmandu->roots,
        VARIABLES    => { _roots  => Catmandu->roots,
                          _root   => Catmandu->root,
                          _config => Catmandu->config, },
    });
}

sub _process {
    my ($self, $tmpl, $data) = @_;
    $self->_tt->process($tmpl, $data || {}, $self->fh)
        || Catmandu::Error->throw(Template->error || "Template error");
}

sub add {
    my ($self, $data) = @_;
    if ($self->count == 0) {
        $self->fh->print($XML_DECLARATION) if $self->xml;
        $self->_process($self->template_before) if $self->template_before;
    }
    $self->_process($self->template, $data);
}

sub commit {
    my ($self) = @_;
    $self->_process($self->template_after) if $self->template_after;
}

=head1 NAME

Catmandu::Exporter::Template - a TT2 Template exporter in Catmandu style


=head1 SYNOPSIS

If you are new to Catmandu see L<Catmandu::Tutorial>.

    use Catmandu::Exporter::Template;

    my $exporter = Catmandu::Exporter::Template->new(
				fix => 'myfix.txt'
				xml => 1,
				template_before => '<path>/header.xml' ,
				template => '<path>/record.xml' ,
				template_after => '<path>/footer.xml' ,
		   );

    $exporter->add_many($arrayref);
    $exporter->add_many($iterator);
    $exporter->add_many(sub { });

    $exporter->add($hashref);

    $exporter->commit; # trigger the template_after

    printf "exported %d objects\n" , $exporter->count;

=head1 METHODS

=head2 new(%opts)

=over

=item *

template: Required. Must contain path to the template.

=item *

xml: Optional. Value: 0 or 1. Prepends xml header to the template.

=item *

template_before: Optional. Prepend template.

=item *

template_after: Optional. Append template.

=item *

fix: Optional. Apply Catmandu fixes while exporting.

=back

Catmandu::Exporter::Template can be used to export data objects using
L<Template Toolkit|Template::Manual>. The only required argument is 'template'
which points to a file to render for each exported object. Set the
'template_before' and 'template_before' to add output at the start and end of
the export.  Optionally provide an 'xml' indicator to include a XML header. 

=head2 add($hashref)

Add data $hashref to the exporter.

=head2 commit

Commit all changes and execute the template_after if given.

=head2 count

Gives the number of records added to the exporter.

=head1 AUTHOR

Nicolas Steenlant, C<< <nicolas.steenlant at ugent.be> >>

=head1 CONTRIBUTOR

Vitali Peil, C<< <vitali.peil at uni-bielefeld.de> >>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Catmandu::Exporter>, L<Template>

=cut

1;
