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

    # XXX XXX XXX

    # create IRC object
    $main::irc = my $irc = Async::IRC->new(
        nick => 'Sharon',
        user => 'sharon',
        real => 'Sharon Herget',
        host => 'Ventura.NL.EU.AlphaChat.net',
        port => 6667
    );


    $loop->add($irc);
    $irc->{autojoin} = ['#cooper'];
    $irc->connect;
    $irc->attach_event(raw => sub { say "@_" });
    $irc->attach_event(privmsg => sub {
        my ($irc, $who, $chan, $what) = @_;
        if ($what =~ m/^e:(.+)/) {
            return unless $who->{nick} eq 'cooper';
            my $val = eval $1;
            $irc->send("PRIVMSG $$chan{name} :".(defined $val ? $val : $@ ? $@ : "\2undef\2"));
        }
    });
    # XXX XXX XXX
    $loop->loop_forever;
}

sub shutdown {
    say 'bye!';
    exit 0;
}

main::regre {
    if (shift) { $TEMP::LOOP = $foxy::loop }
    else       { $foxy::loop = $TEMP::LOOP }
}
