#----------------------------------------------------
# foxy: an insanely flexible IRC bot.               |
# Copyright (c) 2012, Mitchell Cooper               |
#----------------------------------------------------
package API::Auto::IRC;

use warnings;
use strict;
use Exporter;
use base 'Exporter';

our @EXPORT_OK = qw(notice privmsg nick);

sub notice {
}

sub privmsg { #XXX
    my ($net, $target, $what) = @_;
    $main::irc->channel_from_name($target)->send_privmsg($what);
}

sub nick {
    my ($net, $nick) = @_;
    $main::irc->send_nick($nick);
}

1
