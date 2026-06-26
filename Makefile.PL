#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Store::Indexed::XS',
    VERSION_FROM  => 'lib/Store/Indexed/XS.pm',
    OBJECT        => 'XS$(OBJ_EXT)',
    INC           => '-I.', 
);
