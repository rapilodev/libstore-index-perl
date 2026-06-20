package Store::Indexed::XS;
use strict;
use warnings;
use XSLoader;

our $VERSION = '0.1';
XSLoader::load('Store::Indexed::XS', $VERSION);

=head1 NAME

Store::Indexed::XS - Storage for custom payload

=head1 SYNOPSIS

    use Store::Indexed::XS;
    
    my $store = Store::Indexed::XS->new();
    $store->set(1, "color", "red");
    my $val = $store->get(1, "color");

=cut

sub get_all_fields {
    my ($self, $id, @fields) = @_;
    my %result;
    for my $field (@fields) {
        $result{$field} = $self->get($id, $field);
    }
    return \%result;
}

1;
