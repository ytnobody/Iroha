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
    name => 'foobar',
    age => 92,
    datein => time,
} );
my $update = { age => 42, sex => 'male', lastup => time };
my $expect = { %{$row->row}, %$update };

$row->update( %$update );

is_deeply $row->row, $expect;

done_testing;
