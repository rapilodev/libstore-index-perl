use strict;
use warnings;
use Test::More;
use Time::HiRes qw(gettimeofday tv_interval);
use Store::Indexed::PP;

my $iterations = 100_000;

my $start = [gettimeofday];

my $store = Store::Indexed::PP->new();

for my $i (1 .. $iterations) {
    $store->set($i, "val", $i);
}

my $elapsed_insert = tv_interval($start);
diag("Performance: Inserted $iterations items in " . sprintf("%.4f", $elapsed_insert) . "s");

my $start_get = [gettimeofday];
for my $i (1 .. $iterations) {
    my $val = $store->get($i, "val");
    die "Mismatch at $i" unless $val eq $i;
}
my $elapsed_get = tv_interval($start_get);
diag("Performance: Retrieved $iterations items in " . sprintf("%.4f", $elapsed_get) . "s");

undef $store;

pass("Completed $iterations insertions and retrievals without crash");
done_testing();
