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

my %me_events = (
    nick_change => \&update_my_info,
    host_change => \&update_my_info,
    user_change => \&update_my_info
);

manager::attach_irc_event($_, $events{$_}, "Auto.$_", 300)   foreach keys %events;
manager::attach_me_event($_, $me_events{$_}, "Auto.$_", 300) foreach keys %me_events;

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

#main::onreload {
#    if (shift) { $TEMP::eo = $API::Auto::eo }
#    else       { $API::Auto::eo = $TEMP::eo }
#};

# update State::IRC::botinfo
sub update_my_info {
    my $me  = shift;
    my $svr = $me->{irc}->{server_name};
    $State::IRC::botinfo{$svr}{$_} = $me->{$_} foreach qw(nick host user);
    return 1;
}

package State::IRC;
our %botinfo;

#main::onreload {
#    if (shift) { %TEMP::botinfo = %State::IRC::botinfo }
#    else       { %State::IRC::botinfo = %TEMP::botinfo }
#};

1
