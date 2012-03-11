#------------------------------------------
# foxy: an insanely flexible IRC bot.     |
# Copyright (c) 2012, Mitchell Cooper     |
# API/Auto.pm: Auto-compatible API layer. |
#------------------------------------------
package API::Auto;

use warnings;
use strict;
use 5.010;

# used for auto hooks
our ($eo, %commands) = EventedObject->new;

my %events = (
    privmsg => \&h_privmsg
);

$main::irc->attach_event($_, $events{$_}, "Auto.$_") foreach keys %events;

# on_cprivmsg and on_uprivmsg
sub h_privmsg {
    my ($irc, $user, $target, $msg) = @_;
    my $src = {
        svr  => $irc->{server_name},
        nick => $user->{nick},
        host => $user->{host},
        chan => $target->{name},
        user => $user->{user}
    };
    if ($target->isa('IRC::Channel')) {
        $eo->fire_event(on_cprivmsg => $src, $target->{name}, split /\s+/, $msg);
        if ($msg =~ m/!(.+?) (.+)/ || $msg =~ m/!(.+)/) {
            my $cmd = $1;
            $cmd    =~ s/^\s//;
            if ($commands{lc $cmd}) {
                my @a = split /\s+/, $msg;
                $commands{lc $cmd}($src, @a[1..$#a]);
            }
        }
        return 1;
    }
    $eo->fire_event(on_uprivmsg => $src, split /\s+/, $msg);
    return 1;
}

package State::IRC;
our %botinfo = (alphachat => { nick => 'Sharon' });

1
