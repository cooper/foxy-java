#!/usr/bin/perl
# Copyright (c) 2012, Mitchell Cooper
package foxy;

use warnings;
use strict;
use 5.010;

our $loop;

sub boot {
    say 'hi!';
}

sub shutdown {
    say 'bye!';
}

main::regre {
    if (shift) { $TEMP::LOOP = $loop }
    else       { $loop = $TEMP::LOOP }
}
