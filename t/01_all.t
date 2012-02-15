use strict;
use t::Util;
use Test::More;
use Iroha;

my $c = Iroha->connect( 'dbi:SQLite:t/test.sqlite' );
isa_ok $c, 'Iroha';

subtest 'insert' => sub {
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
};

subtest 'fetch' => sub {
    my $data = {
        name => 'テスト2',
        age => 23,
        sex => 'female',
        area => '北の方',
        datein => time,
        lastup => time,
    };
    my $row = $c->insert( member => $data );
    $data->{id} = 2;

    is_deeply $c->fetch( member => $data->{id} )->row, $data;
};

subtest 'select' => sub {
    $c->insert( member => { name => 'ほげ', sex => 'その他' } );
    $c->insert( member => { name => 'ふが', sex => 'その他' } );
    my @rows = $c->select( member => { sex => 'その他' } );
    is scalar @rows, 2;
    for my $row ( @rows ) {
        isa_ok $row, 'Iroha::Row';
        is $row->table, 'member';
    }
};

subtest 'fetch' => sub {
    my $row = $c->insert( member => {
        name => 'oreore', 
        age => 32,
        sex => '女',
    } );
    my $expect = [qw[5 oreore 女 32]];
    is_deeply [ $row->cols( qw( id name sex age ) ) ], $expect;
};

subtest 'update' => sub {
    my $row = $c->insert( member => {
        name => 'foobar',
        age => 92,
        datein => time,
    } );
    my $update = { age => 42, sex => 'male', lastup => time };
    my $expect = { %{$row->row}, %$update };

    $row->update( %$update );

    is_deeply $row->row, $expect;
};

subtest 'delete' => sub {
    my $row = $c->insert( member => {
        name => 'hoeghoge',
        age => 44,
        datein => time,
    } );
    my $id = $row->cols('id');
    $row->delete;
    is $c->fetch( member => $id ), undef;
};

done_testing;
