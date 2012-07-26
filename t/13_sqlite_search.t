use strict;
use t::Util::SQLite;
use Test::More;
use Iroha;
use utf8;

my %dsn = dsn();

my $c = Iroha->connect( @{ $dsn{sqlite} } );

$c->insert( member => { name => 'ほげ', sex => 'その他' } );
$c->insert( member => { name => 'ふが', sex => 'その他' } );
my @rows = $c->search( member => { sex => 'その他' } );
is scalar @rows, 2;
for my $row ( @rows ) {
    isa_ok $row, 'Iroha::Row';
    is $row->table, 'member';
}

done_testing;
