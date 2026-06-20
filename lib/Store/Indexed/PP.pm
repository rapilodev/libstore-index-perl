package Store::Indexed::PP;
use strict;
use warnings;

sub new {
    my ($class) = @_;
    return bless [], $class;
}

sub set {
    die if @_ != 4;
    my ($self, $id, $key, $val) = @_;
    $self->[$id]{$key} = $_[3];
    return 1;
}

sub get {
    die if @_ != 3;
    my ($self, $id, $key) = @_;
    return $self->[$id]{$key};
}

sub delete {
    die if @_ != 3;
    my ($self, $id, $key) = @_;
    delete $self->[$id]{$key};
    return 1;
}

sub exists {
    my ($self, $id, $key) = @_;
    die if @_ != 3;
    return exists $self->[$id]{$key} ? 1 : 0;
}

1;

