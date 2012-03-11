#----------------------------------------------------
# foxy: an insanely flexible IRC bot.               |
# Copyright (c) 2012, Mitchell Cooper               |
#----------------------------------------------------
package API::Auto::Log;

use warnings;
use strict;
use Exporter;
use base 'Exporter';

our @EXPORT_OK = qw(alog dbug slog);

sub alog ($) { }
sub dbug ($) { }
sub slog ($) { }

1
