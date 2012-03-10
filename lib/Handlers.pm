#---------------------------------------------------
# libirc: an insanely flexible perl IRC library.   |
# ntirc:  an insanely flexible IRC client.         |
# foxy:   an insanely flexible IRC bot.            |
# Copyright (c) 2011, the NoTrollPlzNet developers |
# Copyright (c) 2012, Mitchell Cooper              |
# Core/Handlers.pm: core handlers for ntirc/libirc.|
#---------------------------------------------------

# clarity-----
# | interal libirc Handlers (lib/IRC/Handlers.pm) and ntirc libirc handlers (this file)
# | can be a bit confusing. this file contains handlers specific to ntirc's functioning,
# | whereas libirc's Handlers.pm contains useful handlers used by all of libirc.
# ------------
package Handlers;

use warnings;
use strict;
use feature qw(switch);

my %handlers = (
    nick_taken => \&handle_nick_taken
);

# applies each handler to an IRC instance
sub apply_handlers {
    my $irc = shift;

    foreach my $handler (keys %handlers) {
        $irc->attach_event($handler, $handlers{$handler}, "foxy.$handler", 200);
    }

    return 1
}


sub handle_nick_taken {
    my $irc = shift;
    $irc->{temp_nick_count} = 0 unless exists $irc->{temp_nick_count};
    $irc->{temp_nick_count}++;
    my $nick = $irc->{me}->{nick};

    # if we have tried 4 or less times then send the NICK with _ appended
    if ($irc->{temp_nick_count} < 5) {
        $irc->send("NICK ${nick}_");
    }

    # if we have tried 5 times then unset the counter and give up
    else {
        delete $irc->{temp_nick_count}
    }
}



1
