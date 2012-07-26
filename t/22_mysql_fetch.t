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
