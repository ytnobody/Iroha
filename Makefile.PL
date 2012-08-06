use inc::Module::Install;
name 'Iroha';
all_from 'lib/Iroha.pm';

requires 'Class::Accessor::Fast';
requires 'DBIx::Sunny';
requires 'SQL::Maker';
requires 'Guard';

tests 't/*.t';

### comment-in it when you want to run author-test with Module::Install::AuthorTests
# author_tests 'xt';

test_requires 'Test::More';

recommends 'Test::mysqld';

### comment-in it when you want to make it with Module::Install::Repository
# auto_set_repository;

auto_include;
WriteAll;
