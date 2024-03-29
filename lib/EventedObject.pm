# Copyright (c) 2012, Ethrik Development Group
# Copyright (c) 2012, Mitchell Cooper
# see doc/LICENSE for license information.
package EventedObject;
 
use warnings;
use strict;
 
# create a new evented object
sub new {
    bless {}, shift;
}
 
# attach an event callback
sub attach_event {
    my ($obj, $event, $code, $name, $priority) = @_;
    $priority ||= 0; # priority does not matter, so call last.
    $obj->{events}->{$event}->{$priority} ||= [];
    push @{$obj->{events}->{$event}->{$priority}}, [$name, $code];
    return 1;
}
 
sub fire_event {
    my ($obj, $event) = (shift, shift);
 
    # event does not have any callbacks
    return unless $obj->{events}->{$event};
 
    # iterate through callbacks by priority.
    foreach my $priority (sort { $b <=> $a } keys %{$obj->{events}->{$event}}) {
        foreach my $cb (@{$obj->{events}->{$event}->{$priority}}) {
 
            # create info about the call
            $obj->{event_info} = {
                object   => $obj,
                callback => $cb->[0],
                caller   => [caller 1],
                priority => $priority
            };
 
            # call it.
            $cb->[1]->($obj, @_);
        }
    }
 
    return 1;
}
 
sub delete_event {
    my ($obj, $event, $name) = @_;
 
    # event does not have any callbacks
    return unless $obj->{events}->{$event};
 
    # iterate through callbacks and delete matches
    foreach my $priority (keys %{$obj->{events}->{$event}}) {
        my $a = $obj->{events}->{$event}->{$priority};
        @$a   = grep { $_->[0] ne $name } @$a;
 
        # none left in this priority.
        if (scalar @$a == 0) {
            delete $obj->{events}->{$event}->{$priority};
        }
    }
 
    # delete this event because all have been removed.
    if (scalar keys %{$obj->{events}->{$event}} == 0) {
        delete $obj->{events}->{$event};
    }
 
    return 1;
}
 
# aliases
*on   = *attach_event;
*del  = *delete_event;
*fire = *fire_event;
 
1
