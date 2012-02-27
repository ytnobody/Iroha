package Iroha::Row;
use strict;
use warnings;
use parent qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw( iroha table row ) );

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

sub cols {
    shift->columns( @_ );
}

1;

__END__

=head1 NAME

Iroha::Row - Row Class of Iroha

=head1 METHODS

=head2 update

Update row with specified arguments.

 $row->update( %keyvals );

=head2 delete 

Delete row.

 $row->delete;

=head2 columns

Fetch values from specified columns.

 my @values = $row->columns( @columns );

=head2 cols

Alias of columns().

=head1 AUTHOR

satoshi azuma E<lt>ytnobody at gmail dot comE<gt>

=head1 SEE ALSO

Iroha

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
