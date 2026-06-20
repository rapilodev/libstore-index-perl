package Store::Indexed;
use strict;
use warnings;

our $VERSION = '0.1';
our $BACKEND;

sub import {
    my ($class, @tags) = @_;
    ($BACKEND) = map { uc($1) } grep { /^:(XS|PP)$/i } @tags;
}

sub new {
    my ($class, %args) = @_;
    my $type = $args{backend} || $BACKEND || $ENV{STORE_BACKEND} || 'AUTO';
    $type = eval { require Store::Indexed::XS; 1 } ? 'XS' : 'PP' if $type eq 'AUTO';
    my $target = ($type eq 'XS') ? 'Store::Indexed::XS' : 'Store::Indexed::PP';
    warn $target;
    eval { (my $f = "$target.pm") =~ s|::|/|g; require $f };
    die "Load failed: $@" if $@;
    return $target->new(%args);
}
1;