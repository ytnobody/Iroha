use strict;
use t::Util::SQLite;
use Test::More;
use Iroha;
use utf8;

my %dsn = dsn();

my $c = Iroha->connect( @{ $dsn{sqlite} } );

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

done_testing;
