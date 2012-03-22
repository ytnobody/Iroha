use strict;
use t::Util::SQLite;
use Test::More;
use Iroha;
use utf8;

my %dsn = dsn();

for my $key ( 'sqlite' ) {

    my $c = Iroha->connect( @{ $dsn{$key} } );
    isa_ok $c, 'Iroha';

    subtest "insert_$key" => sub {
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
    };

    subtest "fetch_$key" => sub {
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

    subtest "search_$key" => sub {
        $c->insert( member => { name => 'ほげ', sex => 'その他' } );
        $c->insert( member => { name => 'ふが', sex => 'その他' } );
        my @rows = $c->search( member => { sex => 'その他' } );
        is scalar @rows, 2;
        for my $row ( @rows ) {
            isa_ok $row, 'Iroha::Row';
            is $row->table, 'member';
        }
    };

    subtest "cols_$key" => sub {
        my $row = $c->insert( member => {
            name => 'oreore', 
            age => 32,
            sex => '女',
        } );
        my $expect = [qw[5 oreore 女 32]];
        is_deeply [ $row->cols( qw( id name sex age ) ) ], $expect;
    };

    subtest "update_$key" => sub {
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

    subtest "delete_$key" => sub {
        my $row = $c->insert( member => {
            name => 'hoeghoge',
            age => 44,
            datein => time,
        } );
        my $id = $row->cols('id');
        $row->delete;
        is $c->fetch( member => $id ), undef;
    };

    subtest "query_$key" => sub {
        my $query = "INSERT INTO member (name, age, datein) VALUES (?,?,?)";
        ok $c->query( $query, 'Mr. Query', 30, time ), 'Query is okey';
        my ( $row ) = $c->search( member => { name => 'Mr. Query' } );
        isa_ok $row, 'Iroha::Row';
        is $row->age, 30;
        $row->age( 31 );
        my $r = $c->fetch( member => $row->id );
        is $r->age, 31;
        $row->delete;
    };

    subtest "pull_$key" => sub {
        my $row1 = $c->insert( member => { name => 'Chang', age => 26, datein => time } );
        my $row2 = $c->fetch( member => $row1->id );
        is $row1->name, $row2->name, 'same name as Chang';
        $row2->name( 'Mitsuyama' );
        is $row1->name, 'Chang', 'row1 is Chang' ;
        is $row2->name, 'Mitsuyama', 'row2 is Mitsuyama';
        $row1->pull;
        is $row1->name, 'Mitsuyama', 'now, row1 is Mitsuyama';
        is $row2->name, $row1->name, 'same name as Mitsuyama';
    };

    subtest "transaction_$key" => sub {
        ok $c->transaction( sub {
            my $row = insert( member => { name => 'Kaiji', age => 28, datein => time } ) or rollback();
            $row->delete;
        } ), 'transaction OK';
        ok ! $c->transaction( sub {
            my $akagi = insert( member => { name => 'Akagi', age => 26, datein => time } ) or rollback();
            my $hirayama = insert( member => { name => 'Hirayama', age => 25, datein => time } ) or rollback();
            $hirayama->update( name => 'Akagi' );
            if ( $akagi->f('name') eq $hirayama->f('name') ) {
                rollback();
            }
        } ), 'transaction rollbacked';
        my ( $hirayama ) = $c->search( member => { name => 'Hirayama' } );
        is $hirayama, undef;
    };

}

done_testing;
