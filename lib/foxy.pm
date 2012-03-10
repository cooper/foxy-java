#!/usr/bin/perl
# Copyright (c) 2012, Mitchell Cooper
package foxy;

use warnings;
use strict;
use 5.010;

use IO::Async;
use IO::Async::Loop::Epoll;

our $loop;

sub boot {
    say 'hi!';
    $loop = IO::Async::Loop::Epoll->new;
    $loop->loop_forever;
}

sub shutdown {
    say 'bye!';
    exit 0;
}

main::regre {
    if (shift) { $TEMP::LOOP = $loop }
    else       { $loop = $TEMP::LOOP }
}
