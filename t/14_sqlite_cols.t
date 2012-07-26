use strict;
use t::Util::SQLite;
use Test::More;
use Iroha;
use utf8;

my %dsn = dsn();

my $c = Iroha->connect( @{ $dsn{sqlite} } );

my $row = $c->insert( member => {
    name => 'oreore', 
    age => 32,
    sex => '女',
} );
my $expect = [qw[1 oreore 女 32]];
is_deeply [ $row->cols( qw( id name sex age ) ) ], $expect;

done_testing;
