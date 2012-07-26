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

my $row = $c->insert( member => {
    name => 'hoeghoge',
    age => 44,
    datein => time,
} );
my $id = $row->cols('id');
$row->delete;
is $c->fetch( member => $id ), undef;

done_testing;
