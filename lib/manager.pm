#--------------------------------------
# foxy: an insanely flexible IRC bot. |
# Copyright (c) 2012, Mitchell Cooper |
#--------------------------------------
package manager;

use warnings;
use strict;
use 5.010;

my (%ircs, @irc_events, @me_events);

sub add {
    my $irc = shift;
    add_irc_events($irc);
    add_me_events($irc->{me});   
    $ircs{$irc->{server_name}} = $irc;
}

##################
#                #
#   IRC EVENTS   #
#                #
##################

sub add_irc_events {
    my $irc = shift;
    foreach my $e (@irc_events) {
        my ($event, $code, $name, $priority) = @$e;
        $irc->attach_event($event => $code, $name, $priority);
    }
    return 1;
}

# Attach and event to all IRC objects
sub attach_irc_event {
    my ($event, $code, $name, $priority) = @_;
    $_->attach_event($event => $code, $name, $priority) foreach values %ircs;
    push @irc_events, [@_];
    return 1;
}

# Remove an event from all IRC objects
sub delete_irc_event {
    my ($event, $name) = @_;
    $_->delete_event($event => $name) foreach values %ircs;
    @irc_events = grep { not ($_->[0] eq $event && $_[2] eq $name) } @irc_events;
    return 1;
}

#################
#               #
#   ME EVENTS   #
#               #
#################

sub add_me_events {
    my $irc = shift;
    foreach my $e (@me_events) {
        my ($event, $code, $name, $priority) = @$e;
        $irc->{me}->attach_event($event => $code, $name, $priority);
    }
    return 1;
}

# Attach and event to all me objects
sub attach_me_event {
    my ($event, $code, $name, $priority) = @_;
    $_->{me}->attach_event($event => $code, $name, $priority) foreach values %ircs;
    push @me_events, [@_];
    return 1;
}

# Remove an event from all me objects
sub delete_me_event {
    my ($event, $name) = @_;
    $_->{me}->delete_event($event => $name) foreach values %ircs;
    @me_events = grep { not ($_->[0] eq $event && $_[2] eq $name) } @me_events;
    return 1;
}

# get an IRC instance from server name.
sub get { $ircs{+shift} }

1
