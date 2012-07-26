use strict;
use Test::More;
use Iroha;
use utf8;

BEGIN {
    eval { require t::Util::MySQL };
    if ( $@ ) {
        plan skip_all => 't::Util::MySQL requires run these tests. We recommend to install Test::mysqld for running this test.';
    }
};

use t::Util::MySQL;

my %dsn = dsn();

my $c = Iroha->connect( @{ $dsn{mysql} } );

my $query = "INSERT INTO member (name, age, datein) VALUES (?,?,?)";
ok $c->query( $query, 'Mr. Query', 30, time ), 'Query is okey';
my ( $row ) = $c->search( member => { name => 'Mr. Query' } );
isa_ok $row, 'Iroha::Row';
is $row->age, 30;
$row->age( 31 );
my $r = $c->fetch( member => $row->id );
is $r->age, 31;
$row->delete;

done_testing;
