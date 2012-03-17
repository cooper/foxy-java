package API::Auto::State::IRC;

our %botinfo;
tie %botinfo, 'API::Auto::Tie::botinfo';

main::regre {
    if (shift) { %TEMP::botinfo = %API::Auto::State::IRC::botinfo }
    else       { %API::Auto::State::IRC::botinfo = %TEMP::botinfo }
};
