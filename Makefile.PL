use inc::Module::Install;
name 'Iroha';
all_from 'lib/Iroha.pm';

requires 'Class::Accessor::Fast';
requires 'DBIx::Sunny';
requires 'SQL::Maker';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
test_requires 'Test::mysqld';
auto_set_repository;
auto_include;
WriteAll;
