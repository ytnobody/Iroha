package t::Util;
use strict;
use warnings;
use File::Spec;
use DBIx::Sunny;
use Test::mysqld;

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

    # MySQL
    my $mysqld = Test::mysqld->new( my_cnf => { 'skip-networking' => '' } );
    
    {
        my $sql = '';
        open my $fh, '<', File::Spec->catfile( 't', 'tables.mysql' );
        map { $sql .= $_ } <$fh>;
        close $fh;
        my $dbh = DBIx::Sunny->connect( $mysqld->dsn );
        if ( $dbh ) {
            $dbh->query( 'DROP TABLE IF EXISTS member' );
            $dbh->query( $sql );
            $dbh->disconnect;
        }
    }

    my $caller = caller;
    no strict 'refs';
    no warnings 'redefine';
    
    *{$caller."::dsn"} = sub {
        return ( sqlite => [ 'dbi:SQLite:t/test.sqlite' ], mysql => [ $mysqld->dsn ] );
    };

}

1;
