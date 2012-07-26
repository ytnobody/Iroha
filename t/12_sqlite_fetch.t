use strict;
use t::Util::SQLite;
use Test::More;
use Iroha;
use utf8;

my %dsn = dsn();

my $c = Iroha->connect( @{ $dsn{sqlite} } );

my $data = {
    name => 'テスト2',
    age => 23,
    sex => 'female',
    area => '北の方',
    datein => time,
    lastup => time,
};
my $row = $c->insert( member => $data );

$data->{id} = 1;

is_deeply $c->fetch( member => $data->{id} )->row, $data;

done_testing;
