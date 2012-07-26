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
    name => 'oreore', 
    age => 32,
    sex => '女',
} );
my $expect = [qw[1 oreore 女 32]];
is_deeply [ $row->cols( qw( id name sex age ) ) ], $expect;

done_testing;
