package t::Util;
use strict;
use warnings;
use File::Spec;

sub import {
    my $sqlfile = File::Spec->catfile( 't', 'tables.sql' );
    my $dbfile = File::Spec->catfile( 't', 'test.sqlite' );
    if ( -e $dbfile ) {
        unlink $dbfile;
    }
    `sqlite3 $dbfile < $sqlfile`;
}

1;
