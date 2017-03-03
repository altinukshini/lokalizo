package FixMyStreet::SendReport::Lokalizo;

use Moo;

BEGIN { extends 'FixMyStreet::SendReport::Email'; }

sub send_from {
    my ( $self, $row ) = @_;
    return [ FixMyStreet->config('CONTACT_EMAIL'), FixMyStreet->config('CONTACT_NAME') ];
}

sub reply_to {
    my ( $self, $row ) = @_;
    # return [ $row->user->email, $row->user->name ];

    if ($row->name eq '') {
        return $row->user->email;
    }

    return $row->name .'<'.$row->user->email.'>';
}

sub send {
    my $self = shift;
    my ( $row, $h ) = @_;

    my $recips = $self->build_recipient_list( $row, $h );

    # on a staging server send emails to ourselves rather than the bodies
    if (FixMyStreet->config('STAGING_SITE') && !FixMyStreet->config('SEND_REPORTS_ON_STAGING') && !FixMyStreet->test_mode) {
        $recips = 1;
        @{$self->to} = [ $row->user->email, $self->to->[0][1] || $row->name ];
    }

    unless ($recips) {
        $self->error( 'No recipients' );
        return 1;
    }

    my ($verbose, $nomail) = CronFns::options();
    my $cobrand = FixMyStreet::Cobrand->get_class_for_moniker($row->cobrand)->new();
    my $params = {
        To => $self->to,
        From => $self->send_from( $row ),
    };

    $params->{'Reply-To'} = $self->reply_to( $row );

    $cobrand->munge_sendreport_params($row, $h, $params) if $cobrand->can('munge_sendreport_params');

    $params->{Bcc} = $self->bcc if @{$self->bcc};

    my $sender = sprintf('<fms-%s@%s>',
        FixMyStreet::Email::generate_verp_token('report', $row->id),
        FixMyStreet->config('EMAIL_DOMAIN')
    );

    if (FixMyStreet::Email::test_dmarc($params->{From}[0])) {
        $params->{'Reply-To'} = [ $params->{From} ];
        $params->{From} = [ $sender, $params->{From}[1] ];
    }

    my $result = FixMyStreet::Email::send_cron($row->result_source->schema,
        $self->get_template($row), $h,
        $params, $sender, $nomail, $cobrand, $row->lang);

    unless ($result) {
        $self->success(1);
    } else {
        $self->error( 'Failed to send email' );
    }

    return $result;
}

1;
