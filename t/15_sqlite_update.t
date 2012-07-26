use strict;
use t::Util::SQLite;
use Test::More;
use Iroha;
use utf8;

my %dsn = dsn();

my $c = Iroha->connect( @{ $dsn{sqlite} } );

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
