package API::Auto::State::IRC;

our %botinfo;

main::regre {
    if (shift) { %TEMP::botinfo = %API::Auto::State::IRC::botinfo }
    else       { %API::Auto::State::IRC::botinfo = %TEMP::botinfo }
};