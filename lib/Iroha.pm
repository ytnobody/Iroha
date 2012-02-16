package Iroha;
use strict;
use warnings;
use parent qw( Class::Accessor::Fast );
use DBIx::Sunny;
use SQL::Maker;
use Carp ();
use Iroha::Row;

our $VERSION = '0.01';

__PACKAGE__->mk_accessors( qw( dbh sql ) );

sub connect {
    my ( $class, $dsn, @args ) = @_;
    my $dbh = DBIx::Sunny->connect( $dsn, @args ) or Carp::croak( $DBIx::Sunny::errstr );
    my ( $driver ) = $dsn =~ /^dbi:(.+?):/;
    my $sql = SQL::Maker->new( { driver => $driver } );
    return $class->new( { sql => $sql, dbh => $dbh } );
}

sub insert {
    my ( $self, $table, $args ) = @_;
    $self->dbh->query(
        $self->sql->insert( $table, $args )
    );
    my ( $row ) = $self->select( $table => $args );
    return $row;
}

sub select {
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

1;
__END__

=head1 NAME

Iroha - Cheapy O.R.Mapper

=head1 SYNOPSIS

  use Iroha;
  
  # Connect to database
  my $c = Iroha->connect( 'dbi:...', 'user', 'pass' );
  
  # Insert into member table
  my $row = $c->insert( member => { name => 'foobar', ... } );
  
  # Select rows from member table
  my @rows = $c->select( member => { area => 'Japan', ... }, { limit => 3 } );
  
  # Fetch a row with id=3 from member table 
  my $row = $c->fetch( member => 3 );
  
  # Update member's name and age
  $row->update( name => 'piyopiyo', age => 19 );
  
  # Get values from fields
  my ( $name, $age ) = $row->cols( qw( name age ) );
  
  # Delete member
  $row->delete;

=head1 DESCRIPTION

Iroha is cheapy Object-Relational-Mapper

=head1 NOTICE

* Iroha supports UTF-8 charset only.

=head1 AUTHOR

satoshi azuma E<lt>ytnobody at gmail dot comE<gt>

=head1 SEE ALSO

Iroha::Row

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
