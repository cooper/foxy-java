# lib/API/Std.pm - Standard API subroutines.
# Copyright (C) 2010-2012 Xelhua Development Group, et al.
# This program is free software; rights to this code are stated in doc/LICENSE.
package API::Auto::Std;
use strict;
use warnings;
use feature qw(say);
use Exporter;
use base qw(Exporter);


our (%LANGE, %MODULE, %EVENTS, %HOOKS, %CMDS, %ALIASES, %RAWHOOKS);
our @EXPORT_OK = qw(conf_get trans err awarn timer_add timer_del cmd_add 
                    cmd_del hook_add hook_del rchook_add rchook_del match_user
                    has_priv mod_exists ratelimit_check fpfmt);


# Initialize a module.
sub mod_init {

    my ($name, $author, $version, $autover) = @_;
    my $pkg = caller;

    # Run the module's _init sub.
    return unless $pkg->can('_init');
    my $mi = $pkg->_init();

    return 1; #XXX
    # success
    if ($mi) {
        my $mod = LL::Module->new(
            name    => $name,
            version => $version,
            author  => $author,
            package => $pkg,
            manager => 'API::Auto',
            type    => 'auto'
        );

        LL::add($mod);
        return 1;
    }

    LL::unload_package($pkg);
    return;
}

# Check if a module exists.
sub mod_exists { LL::is_loaded(shift) }

# Void a module.
sub mod_void {
    my $name = shift;

    # Check if this module exists.
    return unless my $mod = LL::is_loaded(shift);

    # Run the module's _void sub.
    my $pkg = $mod->{package};
    return unless !$pkg->can('_void');
    my $mi = $pkg->_void();

    if ($mi) {
        LL::unload_module($name) or return;
        return 1;
    }
    return;
}

# Add a command to Auto. XXX
sub cmd_add {
    my ($cmd, $lvl, $priv, $help, $sub) = @_;
    $cmd = uc $cmd;
    $API::Auto::commands{lc $cmd}      =
    $API::Auto::Std::CMDS{$cmd}{'sub'} = $sub;
    $API::Auto::Std::CMDS{$cmd}{lvl}   = $lvl;
    $API::Auto::Std::CMDS{$cmd}{help}  = $help;
    $API::Auto::Std::CMDS{$cmd}{priv}  = $priv;
    return 1;
}

# Alias a command to another. XXX
sub cmd_alias {
    my ($alias, $cmd) = @_;
    
    # Prepare data.
    $alias = uc $alias;
    $cmd = uc $cmd;
    
    # Create alias.
    $ALIASES{$alias} = $cmd;

    return 1;
}

# Delete a command from Auto. XXX
sub cmd_del {
    my ($cmd) = @_;
    $cmd = uc $cmd;

    if (defined $API::Std::CMDS{$cmd}) {
        delete $API::Std::CMDS{$cmd};
    }
    else {
        return;
    }

    return 1;
}

# Add an event to Auto.
sub event_add { }

# Delete an event from Auto. XXX
sub event_del {
    my ($name) = @_;

    if (defined $EVENTS{lc $name}) {
        delete $EVENTS{lc $name};
        delete $HOOKS{lc $name};
        return 1;
    }
    else {
        API::Log::dbug('DEBUG: Attempt to delete a non-existing event ('.lc $name.')! Ignoring...');
        return;
    }
}

# Trigger an event.
sub event_run {
    my ($event, @args) = @_;
    $API::Auto::eo->fire_event($event => @args);
    return 1;
}

# Add a hook to Auto.
sub hook_add {
    my ($event, $name, $sub) = @_;
    $API::Auto::eo->attach_event($event => sub { shift; $sub->(@_) }, $name);
}

# Delete a hook from Auto.
sub hook_del {
    my ($event, $name) = @_;
    $API::Auto::eo->delete_event($event, $name);
}

# Add a timer to Auto. XXX
sub timer_add {
    my ($name, $type, $time, $sub) = @_;
    $name = lc $name;

    # Check for invalid type/time.
    return if $type =~ m/[^1-2]/sm;
    return if $time =~ m/[^0-9]/sm;

    if (!defined $Auto::TIMERS{$name}) {
        $Auto::TIMERS{$name}{type} = $type;
        $Auto::TIMERS{$name}{time} = time + $time;
        if ($type == 2) { $Auto::TIMERS{$name}{secs} = $time }
        $Auto::TIMERS{$name}{sub}  = $sub;
        return 1;
    }

    return 1;
}

# Delete a timer from Auto. XXX
sub timer_del {
    my ($name) = @_;
    $name = lc $name;

    if (defined $Auto::TIMERS{$name}) {
        delete $Auto::TIMERS{$name};
        return 1;
    }

    return;
}

# Hook onto a raw command. XXX
sub rchook_add {
    my ($cmd, $name, $sub) = @_;
    $cmd = uc $cmd;

    # If the hook already exists, ignore it.
    if (defined $RAWHOOKS{$cmd}{$name}) { return }
    
    # Create the hook.
    $API::Auto::eo->attach_event("rc_$cmd" => sub { shift; $sub->(@_) }, "rc.$name");
    $RAWHOOKS{$cmd}{$name} = $sub; # compat

    return 1;
}

# Delete a raw command hook. XXX
sub rchook_del {
    my ($cmd, $name) = @_;
    $cmd = uc $cmd;

    # Make sure the hook exists.
    if (!defined $RAWHOOKS{$cmd}{$name}) { return }

    # Delete it.
    $API::Auto::eo->delete_event("rc_$cmd" => "rc.$name");
    delete $RAWHOOKS{$cmd}{$name};

    return 1;
}

# Configuration value getter.
sub conf_get { [ conf::get('Auto/'.shift()) ] }

# Translation subroutine. (foxy is English only.)
sub trans { shift }

# Match user subroutine. XXX
sub match_user {
    my (%user) = @_;

    # Get data from config.
    if (!conf_get('user')) { return }
    my %uhp = conf_get('user');

    # Create an array of matches.
    my @matches = ();

    foreach my $userkey (keys %uhp) {
        # For each user block.
        my %ulhp = %{ $uhp{$userkey} };
        foreach my $uhk (keys %ulhp) {
            # For each user.

            if ($uhk eq 'net') {
                if (defined $user{svr}) {
                    if (lc $user{svr} ne lc(($ulhp{$uhk})[0][0])) {
                        # config.user:net conflicts with irc.user:svr.
                        last;
                    }
                }
            }
            elsif ($uhk eq 'mask') {
                # Put together the user information.
                my $mask = $user{nick}.q{!}.$user{user}.q{@}.$user{host};
                if (API::IRC::match_mask($mask, ($ulhp{$uhk})[0][0])) {
                    # We've got a host match.
                    push @matches, $userkey;
                }
            }
            elsif ($uhk eq 'chanstatus' and defined $ulhp{'net'}) {
                my ($ccst, $ccnm) = split m/[:]/sm, ($ulhp{$uhk})[0][0];
                my $svr = $ulhp{net}[0];
                if (defined $Auto::SOCKET{$svr}) {
                    if ($ccnm eq 'CURRENT' and defined $user{chan}) {
                        if (defined $State::IRC::chanusers{$svr}{$user{chan}}{lc $user{nick}}) {
                            if ($State::IRC::chanusers{$svr}{$user{chan}}{lc $user{nick}} =~ m/($ccst)/sm) { push @matches, $userkey; }
                        }
                    }
                    else {
                        foreach my $bcj (keys %{ $Proto::IRC::botchans{$svr} }) {
                            if (lc($bcj) eq lc($ccnm)) {
                                if (defined $State::IRC::chanusers{$svr}{$bcj}{lc $user{nick}}) {
                                    if ($State::IRC::chanusers{$svr}{$bcj}{lc $user{nick}} =~ m/($ccst)/sm) { push @matches, $userkey; }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    return @matches;
}

# Privilege subroutine. XXX
sub has_priv {
    my (@matches, $cpriv) = @_;

    foreach my $cuser (@matches) {
        if (conf_get("user:$cuser:privs")) {
            my $cups = (conf_get("user:$cuser:privs"))[0][0];

            if (defined $Auto::PRIVILEGES{$cups}) {
                foreach (@{ $Auto::PRIVILEGES{$cups} }) {
                    if ($_) { if ($_ eq $cpriv or $_ eq 'ALL') { return 1 } }
                }
            }
        }
    }

    return;
}

# Ratelimit check subroutine. foxy doesn't have a ratelimit feature.
sub ratelimit_check { 1 }

# Error subroutine.
sub err {
    my ($lvl, $msg, $fatal) = @_;
    say "Level $lvl Auto log: $msg";
    return 1;
}

# Warn subroutine.
sub awarn {
    my ($lvl, $msg) = @_;
    say "Level $lvl Auto warning: $msg";
    return 1;
}

# Formatting a file path.
sub fpfmt {
    my ($path) = @_;
    if ($path =~ m/\s/xsm) { return "\"$path\"" }
    else { return $path }
}


1;
# vim: set ai et sw=4 ts=4:
