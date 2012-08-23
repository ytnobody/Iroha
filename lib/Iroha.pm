package Iroha;
use strict;
use warnings;
use parent qw( Class::Accessor::Fast );
use DBIx::Sunny;
use SQL::Maker;
use Carp ();
use Iroha::Row;
use Guard ();
use 5.010000;

our $VERSION = '0.01';
our $IROHA;

__PACKAGE__->mk_accessors( qw( dbh sql ) );

sub connect {
    my ( $class, $dsn, @args ) = @_;
    my $dbh = DBIx::Sunny->connect( $dsn, @args );
    my ( $driver ) = $dsn =~ /^dbi:(.+?):/i;
    my $sql = SQL::Maker->new( { driver => $driver } );
    return $class->new( { sql => $sql, dbh => $dbh } );
}

sub insert {
    my ( $self, $table, $args ) = @_;
    my $row = defined $args->{id} ? $self->fetch( $table => delete $args->{id} ) : undef ;
    if ( defined $row ) {
        $row->update( %$args );
    }
    else {
        $self->dbh->query(
            $self->sql->insert( $table, $args )
        );
        ( $row ) = $self->search( $table => $args );
    }
    return $row;
}

sub search {
    my ( $self, $table, $args, $options ) = @_; 
    my $rows = $self->dbh->select_all(
        $self->sql->select( $table, ['*'], $args, $options )
    );
    return grep { defined $_ } 
           map { $_ ? Iroha::Row->new( { row => $_, iroha => $self, table => $table } ) : undef } 
           @$rows
    ;
}

sub fetch {
    my ( $self, $table, $id ) = @_;
    my $row = $self->dbh->select_row(
        $self->sql->select( $table, ['*'], { id => $id } )
    );
    return $row ? Iroha::Row->new( { row => $row, iroha => $self, table => $table } ) : undef;
}

sub query {
    my ( $self, $sql, @binds ) = @_;
    return $self->dbh->query( $sql, @binds );
}

sub transaction {
    my ( $self, $code ) = @_;

    no warnings 'redefine';
    no strict 'refs';

    my $caller = caller;
    local $IROHA = $self;

    local *{$caller."\::insert"} = sub {
        my $self = $IROHA;
        my ( $table, $args ) = @_;
        $self->dbh->query(
            $self->sql->insert( $table, $args )
        );
        my ( $row ) = $self->search( $table => $args );
        return $row;
    };

    local *{$caller."\::search"} = sub {
        my $self = $IROHA;
        my ( $table, $args, $options ) = @_;
        my $rows = $self->dbh->select_all(
            $self->sql->select( $table, ['*'], $args, $options )
        );
        return grep { defined $_ } 
               map { $_ ? Iroha::Row->new( { row => $_, iroha => $self, table => $table } ) : undef } 
               @$rows
        ;
    };

    local *{$caller."\::fetch"} = sub {
        my $self = $IROHA;
        my ( $table, $id ) = @_;
        my $row = $self->dbh->select_row(
            $self->sql->select( $table, ['*'], { id => $id } )
        );
        return $row ? Iroha::Row->new( { row => $row, iroha => $self, table => $table } ) : undef;
    };

    local *{$caller."\::query"} = sub {
        my $self = $IROHA;
        my ( $sql, @binds ) = @_;
        return $self->dbh->query( $sql, @binds );
    };

    local *{$caller."\::dbh"} = sub {
        return $IROHA->{dbh};
    };

    local *{$caller."\::rollback"} = sub { 
        $IROHA->dbh->rollback ;
        die "ROLLBACK";
    };

    my $auto_commit = $IROHA->dbh->{AutoCommit};
    $IROHA->dbh->{AutoCommit} = 0;

    my $guard = Guard::guard {
        $IROHA->dbh->commit;
        $IROHA->dbh->{AutoCommit} = $auto_commit;
    };

    eval { $code->() };
    if ( $@ ) {
        Carp::carp( "transaction: ". $@ );
        return;
    }
    return 1;
}

1;
__END__

=encoding utf8

=head1 NAME

Iroha - Schema-less ORM

=head1 SYNOPSIS

  use Iroha;
  use utf8;
  
  # Connect to database
  my $c = Iroha->connect( 'dbi:...', 'user', 'pass' );
  
  # Insert into member table
  my $row = $c->insert( member => { name => 'おれおれ', ... } );
  
  # Select rows from member table
  my @rows = $c->search( member => { area => '日本', ... }, { limit => 3 } );
  
  # Fetch a row with id=3 from member table 
  my $row = $c->fetch( member => 3 );
  
  # Update member's name and age
  $row->update( name => '源義経', age => 17 );
  # Ah, mistake...
  $row->age( 19 );
  
  # Get values from fields
  my ( $name, $age ) = $row->cols( qw( name age ) );
  # or 
  my $name = $row->name;
  my $age = $row->age;
  
  # Synchronize fields from database
  $row->pull;
  
  # Delete member
  $row->delete;

=head1 DESCRIPTION

Iroha is schema-less Object-Relational-Mapper.

=head1 ONLY ONE CONSTRAINT

Name of primary key on your table must be 'id'.

=head1 METHODS

=head2 connect

Connect to database with specified arguments.

 my $iroha = Iroha->connect( $dsn, $user, $password, \%options );

=head2 insert

Insert into specified table with specified arguments.

 my $row = $iroha->insert( $table => $hashref );

If you specified 'id' key in $hashref, it work like as REPLACE.

=head2 fetch 

Fetch a row from specified table with specified identification-key.

 my $row = $iroha->fetch( $table => $id );

=head2 search

Search rows from specified table with specified conditions.

 my @rows = $iroha->search( $table => \%where, \%options );

=head2 query

Prepare and execute in simple method.

 my $is_success = $iroha->query( $sql, @binds );

=head2 dbh

Returns DBH.

 my $dbh = $iroha->dbh;

=head2 transaction

Implementation of transaction as DSL-like.

  my $is_success = $iroha->transaction( sub {
      my $akagi = insert( member => { name => 'Akagi', age => 26, datein => time } ) or rollback();
      my $hirayama = insert( member => { name => 'Hirayama', age => 25, datein => time } ) or rollback();
      $hirayama->name( 'Akagi' );
      if ( $akagi->name eq $hirayama->name ) {
          rollback();
      }
  } );

You may use insert(), fetch(), search(), query() and dbh() as like as simple function in callback.

=head1 AUTHOR

satoshi azuma E<lt>ytnobody at gmail dot comE<gt>

=head1 SEE ALSO

Iroha::Row

DBIx::Sunny

SQL::Maker

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
