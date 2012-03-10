#!/usr/bin/perl
# Copyright (c) 2012, Mitchell Cooper
use warnings;
use strict;
use 5.010;

local ($0,         $SIG{TERM},       $SIG{KILL},       $SIG{INT}       ) =
      ('foxyjava', \&foxy::shutdown, \&foxy::shutdown, \&foxy::shutdown) ;
our   ($run_dir, %reloadable);

BEGIN {
    sub regre (&) { $reloadable{(caller)[0]} = shift }

    # find running directory
    $run_dir = shift @ARGV;
    if (!$run_dir) {
        say 'Run directory not specified.';
        exit 1;
    }
    unshift @INC, 'lib';
    chdir $run_dir;
}

use foxy;
use EventedObject;
use IRC;
use Handlers;
use Async::IRC;

foxy::boot();

sub reload {
    my $pkg = shift;

    # first callback
    $reloadable{$pkg}(1) if $reloadable{$pkg};

    # delete the package symbol table
    no strict 'refs';
    @{$pkg.'::ISA'} = ();
    my $symtab = $pkg.'::';
    foreach my $symbol (keys %$symtab) {
        next if $symbol =~ /\A[^:]+::\z/;
        delete $symtab->{$symbol};
    }
    use strict 'refs';

    my $inc_file = join('/', split /(?:'|::)/, $pkg).'.pm';
    delete $INC{$inc_file};

    # re-evaluate the file
    do $inc_file || return if shift;

    # afterwards callback
    $reloadable{$pkg}() if $reloadable{$pkg};
    reload('TEMP', 1);
    return 1;
}
