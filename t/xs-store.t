use strict;
use warnings;
use Test::More tests => 10;

BEGIN { use_ok('Store::Indexed::XS'); }

my $store = Store::Indexed::XS->new();
isa_ok($store, 'Store::Indexed::XS', "Object is created correctly");

$store->set(1, "color", "red");
is($store->get(1, "color"), "red", "Store retrieves string value");

$store->set(1, "weight", 50);
is($store->get(1, "weight"), 50, "Store retrieves integer value");

$store->set(1, "color", "blue");
is($store->get(1, "color"), "blue", "Store overwrites existing value");

$store->set(2, "color", "green");
is($store->get(1, "color"), "blue",  "ID 1 remains unchanged");
is($store->get(2, "color"), "green", "ID 2 retrieves correct value");

is($store->get(99, "color"), undef, "Non-existent key returns undef");

my $obj = { foo => 'bar' };
$store->set(1, "object", $obj);
is_deeply($store->get(1, "object"), $obj, "Store handles complex references");

undef $store;
pass("Object destroyed without segmentation fault");
