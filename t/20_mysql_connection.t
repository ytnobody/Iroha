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

# expect connection succeeded
my $c = Iroha->connect( @{ $dsn{mysql} } );
isa_ok $c, 'Iroha';

# expect connection failure
my $iroha = eval { Iroha->connect( 'dbi:mysql:hoge', 'foofoo', undef ) };
ok ! defined $iroha;
ok $@ =~ /Access denied/;

done_testing;
