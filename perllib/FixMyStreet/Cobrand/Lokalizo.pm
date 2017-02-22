package FixMyStreet::Cobrand::Lokalizo;
use base 'FixMyStreet::Cobrand::Base';

use strict;
use warnings;
use FixMyStreet;
use FixMyStreet::Geocode::Bing;
use DateTime;
use Encode;
use List::MoreUtils 'none';
use URI;
use Digest::MD5 qw(md5_hex);
use Regexp::Common;

use Carp;
use mySociety::MaPit;
use mySociety::PostcodeUtil;
use mySociety::Locale;

=head1 path_to_web_templates

    $path = $cobrand->path_to_web_templates(  );

Returns the path to the templates for this cobrand - by default
"templates/web/$moniker" (and then base in Web.pm).

=cut

sub path_to_web_templates {
    my $self = shift;
    my $paths = [
        FixMyStreet->path_to( 'templates/web', $self->moniker ),
    ];
    return $paths;
}

=head1 path_to_email_templates

    $path = $cobrand->path_to_email_templates(  );

Returns the path to the email templates for this cobrand - by default
"templates/email/$moniker" (and then default in Email.pm).

=cut

sub path_to_email_templates {
    my ( $self, $lang_code ) = @_;
    my $paths = [
        FixMyStreet->path_to( 'templates', 'email', $self->moniker, $lang_code ),
        FixMyStreet->path_to( 'templates', 'email', $self->moniker ),
    ];
    return $paths;
}

=head1 country

Returns the country that this cobrand operates in, as an ISO3166-alpha2 code.
Default is none. This is not really used for anything important (minor GB only
things involving eastings/northings mostly).

=cut

sub country {
    return '';
}

=head1 problems

Returns a ResultSet of Problems, potentially restricted to a subset if we're on
a cobrand that only wants some of the data.

=cut

sub problems {
    my $self = shift;
    return $self->problems_restriction($self->{c}->model('DB::Problem'));
}

=head1 problems_on_map

Returns a ResultSet of Problems to be shown on the /around map, potentially
restricted to a subset if we're on a cobrand that only wants some of the data.

=cut

sub problems_on_map {
    my $self = shift;
    return $self->problems_on_map_restriction($self->{c}->model('DB::Problem'));
}

=head1 updates

Returns a ResultSet of Comments, potentially restricted to a subset if we're on
a cobrand that only wants some of the data.

=cut

sub updates {
    my $self = shift;
    return $self->updates_restriction($self->{c}->model('DB::Comment'));
}

=head1 problems_restriction/updates_restriction

Used to restricts reports and updates in a cobrand in a particular way. Do
nothing by default.

=cut

sub problems_restriction {
    my ($self, $rs) = @_;
    return $rs;
}

sub updates_restriction {
    my ($self, $rs) = @_;
    return $rs;
}

=head1 categories_restriction

Used to restrict categories available when making new report in a cobrand in a
particular way. Do nothing by default.

=cut

sub categories_restriction {
    my ($self, $rs) = @_;
    return $rs;
}


=head1 problems_on_map_restriction

Used to restricts reports shown on the /around map in a cobrand in a particular way. Do
nothing by default.

=cut

sub problems_on_map_restriction {
    my ($self, $rs) = @_;
    return $rs;
}

=head1 users

Returns a ResultSet of Users, potentially restricted to a subset if we're on
a cobrand that only wants some of the data.

=cut

sub users {
    my $self = shift;
    return $self->users_restriction($self->{c}->model('DB::User'));
}

=head1 users_restriction

Used to restricts users in the admin in a cobrand in a particular way. Do
nothing by default.

=cut

sub users_restriction {
    my ($self, $rs) = @_;
    return $rs;
}

sub site_key { return 0; }

=head2 restriction

Return a restriction to data saved while using this specific cobrand site.

=cut

sub restriction {
    my $self = shift;

    return $self->moniker ? { cobrand => $self->moniker } : {};
}

=head2 admin_base_url

Base URL for the admin interface.

=cut

sub admin_base_url {
    my $self = shift;
    return FixMyStreet->config('ADMIN_BASE_URL') || $self->base_url . "/admin";
}

=head2 base_url

Return the base url for the cobranded version of the site

=cut

sub base_url { FixMyStreet->config('BASE_URL') }

=head2 base_url_for_report

Return the base url for a report (might be different in a two-tier county, but
most of the time will be same as base_url). Report may be an object, or a
hashref.

=cut

sub base_url_for_report {
    my $self = shift; 
    return base_url_with_lang($self);
}

=head2 base_host

Return the base host for the cobranded version of the site

=cut

sub base_host {
    my $self = shift;
    my $uri  = URI->new( $self->base_url );
    return $uri->host;
}

=head2 enter_postcode_text

Return override text that prompts the user to enter their postcode/place name.
Can be specified in template.

=cut

sub enter_postcode_text { }


=head2 base_url_with_lang

Return base url with language

=cut

sub base_url_with_lang {

   my $self = shift;

   my $base = $self->base_url;

   my $lang = $mySociety::Locale::lang;

   if ($lang eq 'sq') {
      $base =~ s{https://}{$&sq.};
   } 
   if ($lang eq 'sr') {
      $base =~ s{https://}{$&sr.};
   }

   #else {
   #    $base =~ s{https://}{$&en.};
   # }

   return $base;

}


=head2 set_lang_and_domain

    my $set_lang = $cobrand->set_lang_and_domain( $lang, $unicode, $dir )

Set the language and domain of the site based on the cobrand and host.

=cut

sub set_lang_and_domain {
    my ( $self, $lang, $unicode, $dir ) = @_;

    my @languages = @{$self->languages};
    push @languages, 'en-gb,English,en_GB' if none { /en-gb/ } @languages;
    my $languages = join('|', @languages);
    my $lang_override = $self->language_override || $lang;
    my $lang_domain = $self->language_domain || 'FixMyStreet';

    my $headers = $self->{c} ? $self->{c}->req->headers : undef;
    my $set_lang = mySociety::Locale::negotiate_language( $languages, $lang_override, $headers );
    mySociety::Locale::gettext_domain( $lang_domain, $unicode, $dir );
    mySociety::Locale::change();

    if ($mySociety::Locale::langmap{$set_lang}) {
        DateTime->DefaultLocale( $mySociety::Locale::langmap{$set_lang} );
    } else {
        DateTime->DefaultLocale( 'en_US' );
    }

    return $set_lang;
}
sub languages { FixMyStreet->config('LANGUAGES') || [] }
sub language_domain { }
sub language_override { }

=head2 alert_list_options

Return HTML for a list of alert options for the cobrand, given QUERY and
OPTIONS.

=cut

sub alert_list_options { 0 }

=head2 recent_photos

Return N recent photos. If EASTING, NORTHING and DISTANCE are supplied, the
photos must be attached to problems within DISTANCE of the point defined by
EASTING and NORTHING.

=cut

sub recent_photos {
    my $self = shift;
    my $area = shift;
    return $self->problems->recent_photos(@_);
}

=head2 recent

Return recent problems on the site.

=cut

sub recent {
    my ( $self ) = @_;
    return $self->problems->recent();
}

=item shorten_recency_if_new_greater_than_fixed

By default we want to shorten the recency so that the numbers are more
attractive.

=cut

sub shorten_recency_if_new_greater_than_fixed {
    return 1;
}

=head2 front_stats_data

Return a data structure containing the front stats information that a template
can then format.

=cut

sub front_stats_data {
    my ( $self ) = @_;

    my $recency         = '1 week';
    my $shorter_recency = '3 days';

    my $fixed   = $self->problems->recent_fixed();
    my $updates = $self->problems->number_comments();
    my $new     = $self->problems->recent_new( $recency );

    if ( $new > $fixed && $self->shorten_recency_if_new_greater_than_fixed ) {
        $recency = $shorter_recency;
        $new     = $self->problems->recent_new( $recency );
    }

    my $stats = {
        fixed   => $fixed,
        updates => $updates,
        new     => $new,
        recency => $recency,
    };

    return $stats;
}

=head2 disambiguate_location

Returns any disambiguating information available. Defaults to none.

=cut 

sub disambiguate_location { FixMyStreet->config('GEOCODING_DISAMBIGUATION') or {}; }

=head2 cobrand_data_for_generic_update

Parameter is UPDATE_DATA, a reference to a hash of non-cobranded update data.
Return cobrand extra data for the update

=cut

sub cobrand_data_for_generic_update { '' }

=head2 cobrand_data_for_generic_update

Parameter is PROBLEM_DATA, a reference to a hash of non-cobranded problem data.
Return cobrand extra data for the problem

=cut

sub cobrand_data_for_generic_problem { '' }

=head2 uri

Given a URL ($_[1]), QUERY, EXTRA_DATA, return a URL with any extra params
needed appended to it.

In the default case, we need to make sure zoom is always present if lat/lon
are, to stop OpenLayers defaulting to null/0.

=cut

sub uri {
    my ( $self, $uri ) = @_;
    $uri->query_param( zoom => $self->default_link_zoom )
      if $uri->query_param('lat') && !$uri->query_param('zoom');

    return $uri;
}


=head2 header_params

Return any params to be added to responses

=cut

sub header_params { return {} }

=head2 map_type

Return an override type of map if necessary.

=cut
sub map_type {
    my $self = shift;
    return 'OSM' if $self->{c} && $self->{c}->req->uri->host =~ /^osm\./;
    return;
}

=head2 reports_per_page

The number of reports to show per page on all reports page.

=cut

sub reports_per_page {
    return FixMyStreet->config('ALL_REPORTS_PER_PAGE') || 100;
}

=head2 reports_ordering

The order_by clause to use for reports on all reports page

=cut

sub reports_ordering {
    return 'updated-desc';
}

=head2 on_map_list_limit

Return the maximum number of items to be given in the list of reports on the map

=cut

sub on_map_list_limit { return undef; }

=head2 on_map_default_max_pin_age

Return the default maximum age for pins.

=cut

sub on_map_default_max_pin_age { return '6 months'; }

=head2 on_map_default_status

Return the default ?status= query parameter to use for filter on map page.

=cut

sub on_map_default_status { return 'all'; }

=head2 allow_photo_upload

Return a boolean indicating whether the cobrand allows photo uploads

=cut

sub allow_photo_upload { return 1; }

=head2 allow_photo_display

Return a boolean indicating whether the cobrand allows photo display

=cut

sub allow_photo_display {
    my ( $self, $r ) = @_;
    return 1;
}

=head2 allow_update_reporting

Return a boolean indication whether users should see links next to updates
allowing them to report them as offensive.

=cut

sub allow_update_reporting { return 0; }

=head2 geocode_postcode

Given a QUERY, return LAT/LON and/or ERROR.

=cut

sub geocode_postcode {
    my ( $self, $s ) = @_;
    return {};
}

=head2 geocoded_string_check

Parameters are LOCATION, QUERY. Return a boolean indicating whether the
string LOCATION passes the cobrands checks.

=cut

sub geocoded_string_check { return 1; }

=head2 find_closest

Used by send-reports to attach nearest things to the bottom of the report

=cut

sub find_closest {
    my ( $self, $latitude, $longitude, $problem ) = @_;
    my $str = '';

    if ( my $j = FixMyStreet::Geocode::Bing::reverse( $latitude, $longitude, disambiguate_location()->{bing_culture} ) ) {
        # cache the bing results for use in alerts
        if ( $problem ) {
            $problem->geocode( $j );
            $problem->update;
        }
        if ($j->{resourceSets}[0]{resources}[0]{name}) {
            $str .= sprintf(_("Nearest road to the pin placed on the map (automatically generated by Bing Maps): %s"),
                $j->{resourceSets}[0]{resources}[0]{name}) . "\n\n";
        }
    }

    return $str;
}

=head2 find_closest_address_for_rss

Used by rss feeds to provide a bit more context

=cut

sub find_closest_address_for_rss {
    my ( $self, $latitude, $longitude, $problem ) = @_;
    my $str = '';

    my $j;
    if ( $problem && ref($problem) =~ /FixMyStreet/ && $problem->can( 'geocode' ) ) {
       $j = $problem->geocode;
    } else {
        $problem = FixMyStreet::App->model('DB::Problem')->find( { id => $problem->{id} } );
        $j = $problem->geocode;
    }

    # if we've not cached it then we don't want to look it up in order to avoid
    # hammering the bing api
    # if ( !$j ) {
    #     $j = FixMyStreet::Geocode::Bing::reverse( $latitude, $longitude, disambiguate_location()->{bing_culture}, 1 );

    #     $problem->geocode( $j );
    #     $problem->update;
    # }

    if ($j && $j->{resourceSets}[0]{resources}[0]{name}) {
        my $address = $j->{resourceSets}[0]{resources}[0]{address};
        my @address;
        push @address, $address->{addressLine} if $address->{addressLine} and $address->{addressLine} !~ /^Street$/i;
        push @address, $address->{locality} if $address->{locality};
        $str .= sprintf(_("Nearest road to the pin placed on the map (automatically generated by Bing Maps): %s"),
            join( ', ', @address ) ) if @address;
    }

    return $str;
}

=head2 format_postcode

Takes a postcode string and if it looks like a valid postcode then transforms it
into the canonical postcode.

=cut

sub format_postcode {
    my ( $self, $postcode ) = @_;

    if ( $postcode ) {
        $postcode = mySociety::PostcodeUtil::canonicalise_postcode($postcode)
            if $postcode && mySociety::PostcodeUtil::is_valid_postcode($postcode);
    }

    return $postcode;
}
=head2 area_check

Paramters are AREAS, QUERY, CONTEXT. Return a boolean indicating whether
AREAS pass any extra checks. CONTEXT is where we are on the site.

=cut

sub area_check { return ( 1, '' ); }

=head2 all_reports_single_body

Return a boolean indicating whether the cobrand displays a report of all
councils

=cut

sub all_reports_single_body { 0 }

=head2 ask_ever_reported

Return a boolean indicating whether people should be asked whether this is the
first time they' ve reported a problem

=cut

sub ask_ever_reported { 1 }

=head2 send_questionnaires

Return a boolean indicating whether people should be sent questionnaire emails.

=cut

sub send_questionnaires { 1 }

=head2 admin_pages

List of names of pages to display on the admin interface

=cut

sub admin_pages {
    my $self = shift;

    my $user = $self->{c}->user;

    my $pages = {
         'summary' => [_('Summary'), 0],
         'timeline' => [_('Timeline'), 5],
         'stats'  => [_('Stats'), 8],
    };

    # There are some pages that only super users can see
    if ( $user->is_superuser ) {
        $pages->{flagged} = [ _('Flagged'), 7 ];
        $pages->{config} = [ _('Configuration'), 9];
    };
    # And some that need special permissions
    if ( $user->is_superuser || $user->has_body_permission_to('category_edit') ) {
        my $page_title = $user->is_superuser ? _('Bodies') : _('Categories');
        $pages->{bodies} = [ $page_title, 1 ];
        $pages->{body} = [ undef, undef ];
    }
    if ( $user->is_superuser || $user->has_body_permission_to('report_edit') ) {
        $pages->{reports} = [ _('Reports'), 2 ];
        $pages->{report_edit} = [ undef, undef ];
        $pages->{update_edit} = [ undef, undef ];
        $pages->{abuse_edit} = [ undef, undef ];
    }
    if ( $user->is_superuser || $user->has_body_permission_to('template_edit') ) {
        $pages->{templates} = [ _('Templates'), 3 ];
        $pages->{template_edit} = [ undef, undef ];
    };
    if ( $user->is_superuser || $user->has_body_permission_to('responsepriority_edit') ) {
        $pages->{responsepriorities} = [ _('Priorities'), 4 ];
        $pages->{responsepriority_edit} = [ undef, undef ];
    };

    if ( $user->is_superuser || $user->has_body_permission_to('user_edit') ) {
        $pages->{users} = [ _('Users'), 6 ];
        $pages->{user_edit} = [ undef, undef ];
    }

    return $pages;
}

=head2 admin_show_creation_graph

Show the problem creation graph in the admin interface
=cut

sub admin_show_creation_graph { 1 }

=head2 admin_allow_user

Perform checks on whether this user can access admin. By default only superusers
are allowed.

=cut

sub admin_allow_user {
    my ( $self, $user ) = @_;
    return 1 if $user->is_superuser;
}

=head2 available_permissions

Grouped lists of permission types available for use in the admin

=cut

sub available_permissions {
    my $self = shift;

    return {
        _("Problems") => {
            moderate => _("Moderate report details"),
            report_edit => _("Edit reports"),
            report_edit_category => _("Edit report category"), # future use
            report_edit_priority => _("Edit report priority"), # future use
            report_inspect => _("Markup problem details"),
            report_instruct => _("Instruct contractors to fix problems"), # future use
            planned_reports => _("Manage shortlist"),
            contribute_as_another_user => _("Create reports/updates on a user's behalf"),
            contribute_as_body => _("Create reports/updates as the council"),

            # NB this permission is special in that it can be assigned to users
            # without their from_body being set. It's included here for
            # reference, but left commented out because it's not assigned in the
            # same way as other permissions.
            # trusted => _("Trusted to make reports that don't need to be inspected"),
        },
        _("Users") => {
            user_edit => _("Edit other users' details"),
            user_manage_permissions => _("Edit other users' permissions"),
            user_assign_body => _("Grant access to the admin"),
            user_assign_areas => _("Assign users to areas"), # future use
        },
        _("Bodies") => {
            category_edit => _("Add/edit problem categories"),
            template_edit => _("Add/edit response templates"),
            responsepriority_edit => _("Add/edit response priorities"),
        },
    };
}


=head2 area_types

The MaPit types this site handles

=cut

sub area_types          { FixMyStreet->config('MAPIT_TYPES') || [ 'LGA' ] }
sub area_types_children { FixMyStreet->config('MAPIT_TYPES_CHILDREN') || [] }

=head2 contact_name, contact_email

Return the contact name or email for the cobranded version of the site (to be
used in emails).

=cut

sub contact_name  { FixMyStreet->config('CONTACT_NAME') }
sub contact_email { FixMyStreet->config('CONTACT_EMAIL') }

=item email_host

Return if we are the virtual host that sends email for this cobrand

=cut

sub email_host {
    return 1;
}

=item remove_redundant_areas

Remove areas whose reports go to another area (XXX)

=cut

sub remove_redundant_areas {
    my $self = shift;
    my $all_areas = shift;

    my $whitelist = FixMyStreet->config('MAPIT_ID_WHITELIST');
    return unless $whitelist && ref $whitelist eq 'ARRAY' && @$whitelist;

    my %whitelist = map { $_ => 1 } @$whitelist;
    foreach (keys %$all_areas) {
        delete $all_areas->{$_} unless $whitelist{$_};
    }
}

=item short_name

Remove extra information from body names for tidy URIs

=cut

sub short_name {
    my $self = shift;
    my ($area) = @_;

    my $name = $area->{name} || $area->name;
    $name =~ tr{/}{_};
    $name = URI::Escape::uri_escape_utf8($name);
    $name =~ s/%20/+/g;
    return $name;
}

=item is_council

For UK sub-cobrands, to specify various alternations needed for them.

=cut
sub is_council { 0; }

=item is_two_tier

For UK sub-cobrands, to specify various alternations needed for them.

=cut
sub is_two_tier { 0; }

=item council_rss_alert_options

Generate a set of options for council rss alerts. 

=cut

sub council_rss_alert_options {
    my ( $self, $all_areas, $c ) = @_;

    my ( @options, @reported_to_options );
    foreach (values %$all_areas) {
        $_->{short_name} = $self->short_name( $_ );
        ( $_->{id_name} = $_->{short_name} ) =~ tr/+/_/;
        push @options, {
            type      => 'council',
            id        => sprintf( 'area:%s:%s', $_->{id}, $_->{id_name} ),
            text      => sprintf( _('Problems within %s'), $_->{name}),
            rss_text  => sprintf( _('RSS feed of problems within %s'), $_->{name}),
            uri       => $c->uri_for( '/rss/area/' . $_->{short_name} ),
        };
    }

    return ( \@options, @reported_to_options ? \@reported_to_options : undef );
}

=head2 reports_body_check

This function is called by the All Reports page, and lets you do some cobrand
specific checking on the URL passed to try and match to a relevant body.

=cut

sub reports_body_check {
    my ( $self, $c, $code ) = @_;
    return 0;
}

=head2 default_photo_resize

Size that photos are to be resized to for display. If photos aren't
to be resized then return 0;

=cut

sub default_photo_resize { return 0; }

=head2 get_report_stats

Get stats to display on the council reports page

=cut

sub get_report_stats { return 0; }

sub get_body_sender {
    my ( $self, $body, $category ) = @_;

    # look up via category
    my $contact = $body->contacts->search( { category => $category } )->first;
    if ( $body->can_be_devolved ) {
        if ( $contact->send_method ) {
            return { method => $contact->send_method, config => $contact, contact => $contact };
        } else {
            return { method => $body->send_method, config => $body, contact => $contact };
        }
    } elsif ( $body->send_method ) {
        return { method => $body->send_method, config => $body, contact => $contact };
    }

    return $self->_fallback_body_sender( $body, $category, $contact );
}

sub _fallback_body_sender {
    my ( $self, $body, $category, $contact ) = @_;

    return { method => 'Email', contact => $contact };
};

sub example_places {
    my $e = FixMyStreet->config('EXAMPLE_PLACES') || [ 'High Street', 'Main Street' ];
    $e = [ map { Encode::decode('UTF-8', $_) } @$e ];
    return $e;
}

=head2 title_list

Returns an arrayref of possible titles for a person to send to the mobile app.

=cut

sub title_list { return undef; }

=head2 only_authed_can_create

If true, only users with the from_body flag set are able to create reports.

=cut

sub only_authed_can_create {
    return 0;
}

=head2 areas_on_around

If set to an arrayref, will plot those area ID(s) from mapit on all the /around pages.

=cut

sub areas_on_around { []; }

=head2

A list of extra fields we wish to save to the database in the 'extra' column of
problems based on variables passed in by the form. Return a list of hashrefs
of values we wish to save, e.g.
( { name => 'address', required => 1 }, { name => 'passport', required => 0 } )

=cut

sub report_form_extras {}

sub process_open311_extras {}

=head 2 pin_colour

Returns the colour of pin to be used for a particular report
(so perhaps different depending upon the age of the report).

=cut

sub change_category_text {
    my ($self, $category) = @_;

    my $lang = $mySociety::Locale::lang;
    my $enc = 'utf-8';

    my %allowedCategories_sq = (
        "Something else"     =>  "Tjera",
        "Traffic"     =>  "Trafik",
        "Environmental"     =>  "Ambient",
        "Infrastructure"    =>  "Infrastrukture",
        "Waste"     =>  "Mbeturina",
        "Disaster risk reduction"       =>  "Zvoglimi i rrezikut te fatkeqesive"
    );

    if ($lang eq 'sq') {
        if (exists $allowedCategories_sq{$category}) {
	    #return $allowedCategories_sq{$category};
            return decode($enc, $allowedCategories_sq{$category});
        }
        return $category;
    }

    return $category;
}


sub change_body_text {
    my ($self, $body) = @_;

    my $lang = $mySociety::Locale::lang;

    my $enc = 'utf-8';

    my %bodies_sq = (
        "Municipality of Pristina" => "Komuna e Prishtinës",
        "Municipality of Decan" => "Komuna e Deçanit",
        "Municipality of Prizren" => "Komuna e Prizrenit",
        "Municipality of Gjakova" => "Komuna e Gjakovës",
        "Municipality of Skenderaj" => "Komuna e Skënderajit",
        "Municipality of Glogovac" => "Komuna e Gllogocit",
        "Municipality of Stimlje" => "Komuna e Shtimes",
        "Municipality of Gjilan" => "Komuna e Gjilanit",
        "Municipality of Shtrpce" => "Komuna e Shtërpcë",
        "Municipality of Dragash" => "Komuna e Dragashit",
        "Municipality of Suva Reka" => "Komuna e Suharekës",
        "Municipality of Istog" => "Komuna e Istogut",
        "Municipality of Ferizaj" => "Komuna e Ferizajit",
        "Municipality of Kacanik" => "Komuna e Kaçanikut",
        "Municipality of Viti" => "Komuna e Vitisë",
        "Municipality of Klina" => "Komuna e Klinës",
        "Municipality of Vushtrri" => "Komuna e Vushtrrisë",
        "Municipality of Fushe Kosove" => "Komuna e Fushë Kosovës",
        "Municipality of Zubin Potok" => "Komuna e Zubin Potokut",
        "Municipality of Kamenica" => "Komuna e Kamenicës",
        "Municipality of Zvecan" => "Komuna e Zveçanit",
        "Municipality of Mitrovica" => "Komuna e Mitrovicës",
        "Municipality of Malisheve" => "Komuna e Malishevës",
        "Municipality of Leposaviq" => "Komuna e Leposaviqit",
        "Municipality of Hani i Elezit" => "Komuna e Hanit të Elezit",
        "Municipality of Lipjan" => "Komuna e Lipjanit",
        "Municipality of Mamush" => "Komuna e Mamushës",
        "Municipality of Novo Brdo" => "Komuna e Novobërdës",
        "Municipality of Junik" => "Komuna e Junikut",
        "Municipality of Obilic" => "Komuna e Obilicit",
        "Municipality of Klokot" => "Komuna e Kllokotit",
        "Municipality of Rahovec" => "Komuna e Rahovecit",
        "Municipality of Gracanice" => "Komuna e Graçanicës",
        "Municipality of Peja" => "Komuna e Pejës",
        "Municipality of Ranilug" => "Komuna e Ranillugut",
        "Municipality of Podujevo" => "Komuna e Podujevës",
        "Municipality of Partesh" => "Komuna e Parteshit",
        "Municipality of North Mitrovica" => "Komuna e Mitrovicës Veriore"
    );

    my %bodies_sr = (
        "Municipality of Pristina" => "Opština Priština",
        "Municipality of Decan" => "Opština Dečane",
        "Municipality of Prizren" => "Opština Prizren",
        "Municipality of Gjakova" => "Opština Djakovic",
        "Municipality of Skenderaj" => "Opština Srbica",
        "Municipality of Glogovac" => "Opština Glogovac",
        "Municipality of Stimlje" => "Opština Štimlje",
        "Municipality of Gjilan" => "Opština Gnjilane",
        "Municipality of Shtrpce" => "Opština Štrpce",
        "Municipality of Dragash" => "Opština Dragaš",
        "Municipality of Suva Reka" => "Opština Suva Reka",
        "Municipality of Istog" => "Opština Istok",
        "Municipality of Ferizaj" => "Opština Uroševac",
        "Municipality of Kacanik" => "Opština Kačanik",
        "Municipality of Viti" => "Opština Vitina",
        "Municipality of Klina" => "Opština Klina",
        "Municipality of Vushtrri" => "Opština Vučitrn",
        "Municipality of Fushe Kosove" => "Opština Kosovo Polje",
        "Municipality of Zubin Potok" => "Opština Zubin Potok",
        "Municipality of Kamenica" => "Opština Kamenica",
        "Municipality of Zvecan" => "Opština Zvečan",
        "Municipality of Mitrovica" => "Opština Mitrovica",
        "Municipality of Malisheve" => "Opština Mališevo",
        "Municipality of Leposaviq" => "Opština Leposavič",
        "Municipality of Hani i Elezit" => "Opština Elez Han",
        "Municipality of Lipjan" => "Opština Lipjan",
        "Municipality of Mamush" => "Opština Mamuša",
        "Municipality of Novo Brdo" => "Opština Novo Brdo",
        "Municipality of Junik" => "Opština Junik",
        "Municipality of Obilic" => "Opština Obilič",
        "Municipality of Klokot" => "Opština Klokot",
        "Municipality of Rahovec" => "Opština Orahovac",
        "Municipality of Gracanice" => "Opština Gračanica",
        "Municipality of Peja" => "Opština Peč",
        "Municipality of Ranilug" => "Opština Ranilug",
        "Municipality of Podujevo" => "Opština Podujevo",
        "Municipality of Partesh" => "Opština Parteš",
        "Municipality of North Mitrovica" => "Opština Severna Mitrovica"
    );

    if ($lang eq 'sq') {
        if (exists $bodies_sq{$body}) {
            return decode($enc, $bodies_sq{$body});
        }
        return $body;
    } elsif ($lang eq 'sr') {
        if (exists $bodies_sr{$body}) {
            return decode($enc, $bodies_sr{$body});
        }
        return $body;
    }

    return $body;
}


sub pin_colour {

    my ( $self, $p, $context ) = @_;

    my @allowedPinCategories = ("waste", "traffic", "infrastructure", "environmental", "disasterriskreduction");
    my $finalPinCategory = "other";

    my $pinCategory = $self->clean_category( $p->category );

    if ( grep { $_ eq $pinCategory } @allowedPinCategories ) {
	   $finalPinCategory = $pinCategory;
    }

    #return 'green' if time() - $p->confirmed->epoch < 7 * 24 * 60 * 60;
    #return 'yellow' if $context eq 'around' || $context eq 'reports' || $context eq 'report';

    return $finalPinCategory.'-progress' if $p->is_closed;
    return $p->is_fixed ? $finalPinCategory.'-fixed' : $finalPinCategory.'-problem';

}

=head2 clean_category

Clean category from spaces and make it all lowercase

=cut

sub clean_category {
    my ( $self, $s ) = @_;
    # my $s = shift;
    $s =~ s/\s+//g;
    $s = lc $s;
    return $s;
}

=head2 path_to_pin_icons

Used to override the path for the pin icons if you want to add custom pin icons
for your cobrand.

=cut

sub path_to_pin_icons {
    return '/i/';
}


=head2 tweak_all_reports_map

Used to tweak the display settings of the map on the all reports pages.

Used in some cobrands to improve the intial display for Internet Explorer.

=cut

sub tweak_all_reports_map {}

sub can_support_problems { return 0; }

=head2 default_map_zoom / default_link_zoom

default_map_zoom is used when displaying a map overriding the
default of max-4 or max-3 depending on population density.

default_link_zoom is used in links that contain a 'lat' and no
zoom, to stop e.g. OpenLayers defaulting to null/0.

=cut

sub default_map_zoom { 4 };
sub default_link_zoom { 2 }

sub users_can_hide { return 0; }

=head2 default_show_name

Returns true if the show name checkbox should be ticked by default.

=cut

sub default_show_name {
    0;
}

=head2 report_check_for_errors

Perform validation for new reports. Takes Catalyst context object as an argument

=cut

sub report_check_for_errors {
    my $self = shift;
    my $c = shift;

    return (
        %{ $c->stash->{field_errors} },
        %{ $c->stash->{report}->user->check_for_errors },
        %{ $c->stash->{report}->check_for_errors },
    );
}

sub report_sent_confirmation_email { 1; }

=head2 never_confirm_reports

If true then we never send an email to confirm a report

=cut

sub never_confirm_reports { 0; }

=head2 allow_anonymous_reports

If true then can have reports that are truely anonymous - i.e with no email or name. You
need to also put details in the anonymous_account function too.

=cut

sub allow_anonymous_reports { 0; }

=head2 anonymous_account

Details to use for anonymous reports. This should return a hashref with an email and
a name key

=cut

sub anonymous_account { undef; }

=head2 show_unconfirmed_reports

Whether reports in state 'unconfirmed' should still be shown on the public site.
(They're always included in the admin interface.)

=cut

sub show_unconfirmed_reports {
    0;
}

=head2 never_confirm_updates

If true then we never send an email to confirm an update

=cut

sub never_confirm_updates { 0; }

sub include_time_in_update_alerts { 0; }

=head2 prettify_dt

    my $date = $c->prettify_dt( $datetime );

Takes a datetime object and returns a string representation.

=cut

sub prettify_dt {
    my $self = shift;
    my $dt = shift;

    return Utils::prettify_dt( $dt, 1 );
}

=head2 extra_contact_validation

Perform any extra validation on the contact form.

=cut

sub extra_contact_validation { (); }


=head2 get_geocoder

Return the default geocoder from config.

=cut

sub get_geocoder {
    my ($self, $c) = @_;
    return $c->config->{GEOCODER};
}


sub problem_as_hashref {
    my $self = shift;
    my $problem = shift;
    my $ctx = shift;

    return $problem->as_hashref( $ctx );
}

sub updates_as_hashref {
    my $self = shift;
    my $problem = shift;
    my $ctx = shift;

    return {};
}

sub jurisdiction_id_example {
    my $self = shift;
    return $self->moniker;
}

=head2 body_details_data

Returns a list of bodies to create with ensure_body.  These
are mostly just passed to ->find_or_create, but there is some
pre-processing so that you can enter:

    area_id => 123,
    parent => 'Big Town',

instead of

    body_areas => [ { area_id => 123 } ],
    parent => { name => 'Big Town' },

For example:

    return (
        {
            name => 'Big Town',
        },
        {
            name => 'Small town',
            parent => 'Big Town',
            area_id => 1234,
        },


=cut

sub body_details_data {
    return ();
}

=head2 contact_details_data

Returns a list of contact_data to create with setup_contacts.
See Zurich for an example.

=cut

sub contact_details_data {
    return ()
}

=head2 lookup_by_ref_regex

Returns a regex to match postcode form input against to determine if a lookup
by id should be done.

=cut

sub lookup_by_ref_regex {
    return qr/^\s*ref:\s*(\d+)\s*$/;
}

=head2 category_extra_hidden

Return true if an Open311 service attribute should be a hidden field.
=cut

sub category_extra_hidden {
    my ($self, $meta) = @_;
	return 0;
}



1;
