package Iroha::Row;
use strict;
use warnings;
use parent qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw( iroha table row ) );

our $AUTOLOAD;

BEGIN {
    no strict 'refs';
    for my $key ( qw( cols col fields attr f ) ) {
        *{__PACKAGE__."\::$key"} = sub { shift->columns( @_ ) };
    }
}

sub update {
    my ( $self, %args ) = @_;
    my $iroha = $self->iroha;

    $self->row( { %{$self->row}, %args } );

    $iroha->dbh->query(
        $iroha->sql->update( $self->table, {%args}, { id => $self->row->{id} } )
    );
}

sub delete {
    my $self = shift;
    my $iroha = $self->iroha;
    $iroha->dbh->query(
        $iroha->sql->delete( $self->table, { id => $self->row->{id} } )
    );
}

sub columns {
    my ( $self, @cols ) = @_;
    my %data = %{ $self->row };
    return @cols ? @data{@cols} : %data;
}

sub pull {
    my $self = shift;
    $self->row( $self->iroha->fetch( $self->table => $self->row->{id} )->row );
}

sub _field_access {
    my ( $self, $field, $val ) = @_;
    if ( defined $val ) {
        $self->update( $field => $val );
    }
    return $self->columns( $field );
}

sub AUTOLOAD {
    my ( $self, $val ) = @_;
    my ($method) = $AUTOLOAD =~ /([^:']+$)/;
    $self->_field_access($method, $val);
}

1;

__END__

=head1 NAME

Iroha::Row - Row Class of Iroha

=head1 METHODS

=head2 update

Update row with specified arguments.

 $row->update( %keyvals );

For example, you want to update value of "name" field as "Kaiji",

 $row->update( name => 'Kaiji' );

And, this code is equal to following.

 $row->name( 'Kaiji' );

=head2 delete 

Delete row.

 $row->delete;

=head2 columns

Fetch values from specified columns.

 my @values = $row->columns( @columns );

For example, you want to fetch value of "name" field,

 my $name = $row->columns( 'name' );

And, this code is equal to following.

 my $name = $row->name;

=head2 pull

Update fields in object by data that fetched from database.

See following example ...

 my $row1 = $iroha->fetch( member => 1 );
 my $row2 = $iroha->fetch( member => 1 ); # same identity
 
 $row1->name( 'Kaiji' );     # Write 'Kaiji' into DB
 $row2->name( 'Tonegawa' );  # Overwrite 'Tonegawa' into DB
 
 warn $row1->name; # warn with 'Kaiji'
 warn $row2->name; # warn with 'Tonegawa'
 
 $row1->pull;      # Magic!
 warn $row1->name; # warn with 'Tonegawa' !!!
 
 $row2->pull;      # Magic too
 warn $row2->name; # warn with 'Tonegawa'

=head2 cols, col, fields, attr, f

Alias of columns().

=head1 AUTHOR

satoshi azuma E<lt>ytnobody at gmail dot comE<gt>

=head1 SEE ALSO

Iroha

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
