use strict;
use t::Util::SQLite;
use Test::More;
use Iroha;
use utf8;

my %dsn = dsn();

my $c = Iroha->connect( @{ $dsn{sqlite} } );

my $row = $c->insert( member => {
    name => 'hoeghoge',
    age => 44,
    datein => time,
} );
my $id = $row->cols('id');
$row->delete;
is $c->fetch( member => $id ), undef;

done_testing;
