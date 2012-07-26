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

my $row1 = $c->insert( member => { name => 'Chang', age => 26, datein => time } );
my $row2 = $c->fetch( member => $row1->id );
is $row1->name, $row2->name, 'same name as Chang';
$row2->name( 'Mitsuyama' );
is $row1->name, 'Chang', 'row1 is Chang' ;
is $row2->name, 'Mitsuyama', 'row2 is Mitsuyama';
$row1->pull;
is $row1->name, 'Mitsuyama', 'now, row1 is Mitsuyama';
is $row2->name, $row1->name, 'same name as Mitsuyama';

done_testing;
