package Cassandane::TestEntity::Factory::AddressBook;
use Moo;

use feature 'state';
use Carp ();

sub fill_in_creation_defaults {
    my ($self, $prop) = @_;

    state $i = 1;
    $prop->{name} //= 'Address Book #' . $i++;

    return;
}

sub default {
    my ($self) = @_;

    my $jmap = $self->user->entity_jmap;
    local $jmap->{CreatedIds}; # do not pollute the client for later use

    my $res = $jmap->request([[ "AddressBook/get" => {} ]]);

    my ($abook) = grep {
      $_->{isDefault}
    } $res->sentence_named("AddressBook/get")->arguments->{list}->@*;

    unless ($abook && $abook->{id}) {
      Carp::confess(
        "Failed to find a Default AddressBook?! JMAP Resp: "
        . explain($res)
      );
    }

    my $id    = delete $abook->{id};
    $self->instance_class->new({
        id         => $id,
        factory    => $self,
        properties => $abook,
    })
}

use Cassandane::TestEntity::AutoSetup;

no Moo;
1;
