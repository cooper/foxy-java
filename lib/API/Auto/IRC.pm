#----------------------------------------------------
# foxy: an insanely flexible IRC bot.               |
# Copyright (c) 2012, Mitchell Cooper               |
#----------------------------------------------------
package API::Auto::IRC;

use warnings;
use strict;
use Exporter;
use base 'Exporter';

our @EXPORT_OK = qw(notice privmsg);

sub notice {
}

sub privmsg { #XXX
    my ($net, $target, $what) = @_;
    $main::irc->channel_from_name($target)->send_privmsg($what);
}

1
