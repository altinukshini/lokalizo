package FixMyStreet::App::Controller::Root;
use Moose;
use namespace::autoclean;

use File::Slurp;
use JSON::MaybeXS;
use List::MoreUtils qw(any);
use POSIX qw(strcoll);
use RABX;
use mySociety::MaPit;

BEGIN { extends 'Catalyst::Controller' }

__PACKAGE__->config( namespace => '' );

=head1 NAME

FixMyStreet::App::Controller::Root - Root Controller for FixMyStreet::App

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 auto

Set up general things for this instance

=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    # decide which cobrand this request should use
    $c->setup_request();

    return 1;
}

=head2 index

Home page.

If request includes certain parameters redirect to '/around' - this is to
preserve old behaviour.

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    my @old_param_keys = ( 'pc', 'x', 'y', 'e', 'n', 'lat', 'lon' );
    my %old_params = ();

    foreach my $key (@old_param_keys) {
        my $val = $c->get_param($key);
        next unless $val;
        $old_params{$key} = $val;
    }

    if ( scalar keys %old_params ) {
        my $around_uri = $c->uri_for( '/around', \%old_params );
        $c->res->redirect($around_uri);
        return;
    }

    # my @bodies = $c->model('DB::Body')->search({
    #     deleted => 0,
    # }, {
    #     '+select' => [ { count => 'area_id' } ],
    #     '+as' => [ 'area_count' ],
    #     join => 'body_areas',
    #     distinct => 1,
    # })->all;
    # @bodies = sort { strcoll($a->name, $b->name) } @bodies;
    # $c->stash->{bodies} = \@bodies;
    # $c->stash->{any_empty_bodies} = any { $_->get_column('area_count') == 0 } @bodies;

    # eval {
    #     my $data = File::Slurp::read_file(
    #         FixMyStreet->path_to( '../data/all-reports.json' )->stringify
    #     );
    #     my $j = decode_json($data);
    #     $c->stash->{fixed} = $j->{fixed};
    #     $c->stash->{open} = $j->{open};
    # };
    # if ($@) {
    #     my $message = _("There was a problem showing the All Reports page. Please try again later.");
    #     if ($c->config->{STAGING_SITE}) {
    #         $message .= '</p><p>Perhaps the bin/update-all-reports script needs running. Use: bin/update-all-reports</p><p>'
    #             . sprintf(_('The error was: %s'), $@);
    #     }
    #     $c->detach('/page_error_500_internal_error', [ $message ]);
    # }

    # Down here so that error pages aren't cached.
    # $c->response->header('Cache-Control' => 'max-age=3600');

}

=head2 default

Forward to the standard 404 error page

=cut

sub default : Path {
    my ( $self, $c ) = @_;
    $c->detach('/page_error_404_not_found', []);
}

=head2 page_error_404_not_found, page_error_410_gone

    $c->detach( '/page_error_404_not_found', [$error_msg] );
    $c->detach( '/page_error_410_gone',      [$error_msg] );

Display a 404 (not found) or 410 (gone) page. Pass in an optional error message in an arrayref.

=cut

sub page_error_404_not_found : Private {
    my ( $self, $c, $error_msg ) = @_;

    # Try getting static content that might be given under an admin proxy.
    # First the special generated JavaScript file
    $c->go('/js/translation_strings', [ $1 ], []) if $c->req->path =~ m{^admin/js/translation_strings\.(.*?)\.js$};
    # Then a generic static file
    $c->serve_static_file("web/$1") && return if $c->req->path =~ m{^admin/(.*)};

    $c->stash->{template}  = 'errors/page_error_404_not_found.html';
    $c->stash->{error_msg} = $error_msg;
    $c->response->status(404);
}

sub page_error_410_gone : Private {
    my ( $self, $c, $error_msg ) = @_;
    $c->stash->{template}  = 'index.html';
    $c->stash->{error} = $error_msg;
    $c->response->status(410);
}

sub page_error_403_access_denied : Private {
    my ( $self, $c, $error_msg ) = @_;
    $c->detach('page_error', [ $error_msg || _("Sorry, you don't have permission to do that."), 403 ]);
}

sub page_error_400_bad_request : Private {
    my ( $self, $c, $error_msg ) = @_;
    $c->forward('/auth/get_csrf_token');
    $c->detach('page_error', [ $error_msg, 400 ]);
}

sub page_error_500_internal_error : Private {
    my ( $self, $c, $error_msg ) = @_;
    $c->detach('page_error', [ $error_msg, 500 ]);
}

sub page_error : Private {
    my ($self, $c, $error_msg, $code) = @_;
    $c->stash->{template}  = 'errors/generic.html';
    $c->stash->{message} = $error_msg || _('Unknown error');
    $c->response->status($code);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
}

__PACKAGE__->meta->make_immutable;

1;
