package FixMyStreet::SendReport::Lokalizo;

use Moo;

BEGIN { extends 'FixMyStreet::SendReport::Email'; }

sub send_from {
    my ( $self, $row ) = @_;
    return [ FixMyStreet->config('CONTACT_EMAIL'), FixMyStreet->config('CONTACT_NAME') ];
}

1;