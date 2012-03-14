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
    my ($irc, $target, $what) = &args;
    $irc->channel_from_name($target)->send_privmsg($what);
}

sub nick {
    my ($irc, $nick) = &args;
    $irc->send_nick($nick);
}

# argument list with IRC object instead of server name
sub args { (manager::get(shift), @_) }

1
