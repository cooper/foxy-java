package API::Auto::Tie;

use warnings;
use strict;

sub TIEHASH {
    my $class = shift;
    bless { pkg => $class }, $class;
}

sub FETCH {
    my ($this, $key, $code) = @_;
    if ($code = $this->{pkg}->can("_tie_$key")) {
        return $code->(@_)
    }
    if ($code = $this->{pkg}->can("_tie")) {
        return $code->(@_)
    }
    if (exists $this->{data}->{$key}) {
        return $this->{data}->{$key}
    }
    return
}

sub STORE {
    my ($this, $key, $value) = @_;
    $this->{data}->{$key} = $value;
}

sub DELETE {
    my ($this, $key) = @_;
    delete $this->{data}->{$key};
}

sub CLEAR {
    my $this = shift;
    %{$this->{data}} = ();
}

sub EXISTS {
    my ($this, $key) = @_;
    return exists $this->{data}->{$key};
}

sub FIRSTKEY {
    my $this = shift;
    keys %{$this->{data}};
    return each %{$this->{data}};
}

sub NEXTKEY {
    my ($this, $lastkey) = @_;
    return each %{$this->{data}};
}

package API::Auto::Tie::botinfo;

use warnings;
use strict;
use base 'API::Auto::Tie';

sub _tie {
    my ($tie, $svr) = @_;
    my $irc = manager::get($svr) or return;
    return {
        nick  => $irc->{me}->{nick},
        ident => $irc->{me}->{user},
        user  => $irc->{me}->{user},
        host  => $irc->{me}->{host}
    }
}

1
