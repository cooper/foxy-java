#!/usr/bin/perl

use warnings;
use strict;
use 5.010;

local ($0,         $SIG{TERM},       $SIG{KILL},       $SIG{INT}       ) =
      ('foxyjava', \&foxy::shutdown, \&foxy::shutdown, \&foxy::shutdown) ;
our   ($run_dir, %reloadable);

# find running directory
BEGIN {
    $run_dir = shift @ARGV;
    if (!$run_dir) {
        say 'Run directory not specified.';
        exit 1;
    }
    unshift @INC, $run_dir;
    chdir $run_dir;
}

use foxy;

foxy::boot();

sub reloadable { $reloadable{(caller)[0]} = shift }

sub reload {
    my $pkg = shift;

    # first callback
    $reloadable{$pkg}[0]() if $reloadable{$pkg};

    # delete the package symbol table
    no strict 'refs';
    @{$class.'::ISA'} = ();
    my $symtab = $class.'::';
    foreach my $symbol (keys %$symtab) {
        next if $symbol =~ /\A[^:]+::\z/;
        delete $symtab->{$symbol};
    }
    use strict 'refs';

    my $inc_file = join('/', split /(?:'|::)/, $class).'.pm';
    delete $INC{$inc_file};

    # re-evaluate the file
    do $inc_file or return;

    # afterwards callback
    $reloadable{$pkg}[1]() if $reloadable{$pkg};
    return 1;
}
