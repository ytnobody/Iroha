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

$c->insert( member => { name => 'ほげ', sex => 'その他' } );
$c->insert( member => { name => 'ふが', sex => 'その他' } );
my @rows = $c->search( member => { sex => 'その他' } );
is scalar @rows, 2;
for my $row ( @rows ) {
    isa_ok $row, 'Iroha::Row';
    is $row->table, 'member';
}

done_testing;
