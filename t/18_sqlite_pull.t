use strict;
use t::Util::SQLite;
use Test::More;
use Iroha;
use utf8;

my %dsn = dsn();

my $c = Iroha->connect( @{ $dsn{sqlite} } );

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
