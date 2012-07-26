use strict;
use t::Util::SQLite;
use Test::More;
use Iroha;
use utf8;

my %dsn = dsn();

my $c = Iroha->connect( @{ $dsn{sqlite} } );

my $data = {
    name => 'テスト',
    age => 30,
    sex => '男',
    area => '内緒',
    datein => time,
    lastup => time,
};
my $row = $c->insert( member => $data );

$data->{id} = 1;

is_deeply $row->row, $data;

my $data2 = { %$data };
$data2->{name} = 'ほげほげ';

my $row2 = $c->insert( member => $data2 );
$data2->{id} = 1;

is_deeply $row2->row, $data2;
is $row2->name, 'ほげほげ';
is $row2->id, 1;


done_testing;
