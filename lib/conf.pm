#--------------------------------------
# foxy: an insanely flexible IRC bot. |
# Copyright (c) 2012, Mitchell Cooper |
# conf: configuration package.        |
#--------------------------------------
package conf;
 
use warnings;
use strict;
use 5.010;

our %conf;
 
sub parse {
    delete $conf{_parsed};
    open my $fh, '<', shift or return;

    my ($i, $block, $name, $key, $val) = (0, 'sec', 'main'); 
    LINE: for (<$fh>) {
        $i++;

        # comment
        when (/^#/) { next LINE }

        # key & value
        when (/^(.+?)\s*=(.+)$/) {
            $conf{defined $block ? $block : 'sec'}
                 {defined $name ? $name : 'main'}{trim($1)} = parse_value(trim($2));
        }

        # named block start
        # block (name):
        when (/^(.+?)\s*\((.+?)\):$/) {
            ($block, $name) = (trim($1), trim($2));
        }
 
        # nameless block start
        # block:
        when (/^(.+?):$/) {
            ($block, $name) = ('sec', trim($1));
        }
    }
 
    close $fh;
    $conf{_parsed} = 1;
    return %conf
}
 
# get conf value
sub get {
    my ($str, $current, $last, $level) = (shift, \%conf, \%conf);
    my @lvl = my @levels = split /:/, $str;
 
    # assume unnamed block
    unshift @levels, 'sec' if @levels == 2;
 
    while (defined ( $level = shift @levels )) {
        $current = defined $current->{$level} ?
                           $current->{$level} :
                           $conf{$lvl[0]}{'*'}{$level};
    }
    return make_value_useful($current);
}
 
# (actual get) same as get but does not assume what you mean for convenience.
sub aget {
    my ($str, $current, $level) = (shift, \%conf);
    my @levels = split /:/, $str;
 
    while (defined ( $level = shift @levels )) {
        return unless ref $current eq 'HASH';
        $current = $current->{$level};
    }
    return make_value_useful($current);
}
 
# (long get) same as aget but accepts separate arguments
# (useful for fetching conf values from variables)
sub lget {
    my @levels = @_;
    my ($current, $level) = \%conf;
    while (defined ( $level = shift @levels )) {
        return unless ref $current eq 'HASH';
        $current = $current->{$level};
    }
    return make_value_useful($current);
}
 
sub parse_value {
    my $value = shift;
    given ($value) {
        # string
        when (/"(.+)"$/) {
            return $1;
        }
        # array
        when (/\((.+)\)$/) {
            return [split /\s+/, $1];
        }
    }
 
    # other (such as int)
    return $value;
}
 
# transform from reference if necessary
sub make_value_useful {
    my $value = shift;
    given (ref $value) {
        when ('HASH') {
            return %$value;
        }
        when ('ARRAY') {
            return @$value;
        }
        when ('SCALAR') {
            return $$value;
        }
    }
    return $value;
}
 
sub trim {
    my $string =  shift;
       $string =~ s/\s+$//;
       $string =~ s/^\s+//;
    return $string;
}

main::regre {
    if (shift) { %TEMP::conf = %conf::conf }
    else       { %conf::conf = %TEMP::conf }
}
