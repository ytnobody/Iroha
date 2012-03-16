package t::Util::SQLite;
use strict;
use warnings;
use File::Spec;
use DBIx::Sunny;

sub import {

    # SQLite
    {
        my $sqlfile = File::Spec->catfile( 't', 'tables.sql' );
        my $dbfile = File::Spec->catfile( 't', 'test.sqlite' );
        if ( -e $dbfile ) {
            unlink $dbfile;
        }
        `sqlite3 $dbfile < $sqlfile`;
    }

    my $caller = caller;
    no strict 'refs';
    no warnings 'redefine';
    
    *{$caller."::dsn"} = sub {
        return ( sqlite => [ 'dbi:SQLite:t/test.sqlite' ] );
    };

}

1;
