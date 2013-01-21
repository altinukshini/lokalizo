#!/usr/bin/perl

# script for querying the higatlas.fms_update table provided by
# Bentley and offering them up as XML service request updates.
# https://github.com/mysociety/fixmystreet/wiki/Open311-FMS---Proposed-differences-to-Open311
#
# mySociety: http://code.fixmystreet.com/
#-----------------------------------------------------------------

require 'open311_services.pm';

# incoming query params
my $CGI_VAR_START_DATE = 'start_date';
my $CGI_VAR_END_DATE   = 'end_date';
my $CGI_VAR_NO_DEFAULT_DATE   = 'force_no_default_date'; # for testing scratchy Oracle date stuff
my $CGI_VAR_NO_LIMIT   = 'force_no_limit'; # for testing

my $USE_ONLY_DATES = 0;  # dates not times
my $LIMIT_CLAUSE = ' LIMIT 1000';

my $req = new CGI;

get_service_request_updates($req);

sub prepare_for_xml {
    my $s = shift;
    foreach ($s) {
        from_to($_, 'utf8', 'Windows-1252') if $DECODE_FROM_WIN1252;
        s/</&lt;/g; # numpty escaping pending XML Simple?
        s/>/&gt;/g;
        s/&/&amp;/g;
    }
    return $s;
}

#------------------------------------------------------------------
# get_service_discovery
# Although not really implementing this, use it as a test to read the 
# db and confirm connectivity.
#
# TABLE "HIGATLAS"."FMS_UPDATE"
# 
#         "ROW_ID"                                NUMBER(9,0) NOT NULL ENABLE,
#         "SERVICE_REQUEST_ID"    NUMBER(9,0) NOT NULL ENABLE,
#         "UPDATED_TIMEDATE"              DATE DEFAULT SYSDATE NOT NULL ENABLE,
#         "STATUS"                                VARCHAR2(10 BYTE) NOT NULL ENABLE,
#         "DESCRIPTION"                   VARCHAR2(254 BYTE) NOT NULL ENABLE,
# 
#          CONSTRAINT "FMS_UPDATE_PK" PRIMARY KEY ("ROW_ID")
#------------------------------------------------------------------
sub get_service_request_updates {
    # by default, we only want last 24 hours
    # also, limit to 1000 records
    
    my $raw_start_date = $req -> param($CGI_VAR_START_DATE);
    my $raw_end_date = $req -> param($CGI_VAR_END_DATE);
    my $start_date = get_date_or_nothing( $raw_start_date, $USE_ONLY_DATES );
    my $end_date = get_date_or_nothing( $raw_end_date, $USE_ONLY_DATES );

    if (! $req -> param($CGI_VAR_NO_DEFAULT_DATE)) {
        $start_date = get_date_or_nothing( $YESTERDAY, $USE_ONLY_DATES ) unless ($start_date or $end_date);
    }

    $start_date = "updated_timedate >= to_date('$start_date', 'yyyy-mm-dd hh:mi:ss')" if $start_date;
    $end_date = "updated_timedate <= to_date('$end_date', 'yyyy-mm-dd hh:mi:ss')" if $end_date;

    my $where_clause = '';
    $where_clause = join(' AND ', grep {$_} ($start_date, $end_date));
    $where_clause = "WHERE $where_clause" if $where_clause;

    my $limit = $LIMIT_CLAUSE unless $req -> param($CGI_VAR_NO_LIMIT);
    
    my $sql = qq(SELECT row_id, service_request_id, to_char(updated_timedate, 'yyyy-mm-dd hh:mi:ss'), status, description FROM higatlas.fms_update $where_clause ORDER BY updated_timedate DESC $limit);

    my $debug_str = <<XML;
        <!-- DEBUG: from: $raw_start_date => $start_date  -->
        <!-- DEBUG: to:   $raw_end_date => $end_date -->
        <!-- DEBUG: sql:  $sql -->
XML

    my $ary_ref;
    
    if ($TESTING_WRITE_TO_FILE) {
        $ary_ref = [
            [97, 1000, '2013-01-05', 'OPEN', 'report was opened'],
            [99, 1000, '2013-01-06', 'CLOSED', 'report was closed']
        ];
    } else {
        my $dbh = get_db_connection();
        $ary_ref = $dbh->selectall_arrayref($sql);
    }
    
    # rough and ready XML dump now (should use XML Simple to build/escape properly!)
    my $xml = "";
    foreach my $row(@{$ary_ref})  {
        if (defined $row) {
            my ($id, $service_req_id, $updated_at, $status, $desc) = map { prepare_for_xml($_) } @$row;
            $updated_at=~s/(\d{4}-\d\d-\d\d) (\d\d:\d\d:\d\d)/${1}T${2}Z/; # for now assume OCC in Zulu time
            $xml.= <<XML;
    <request_update>
        <update_id>$id</update_id>
        <service_request_id>$service_req_id</service_request_id>
        <status>$status</status>
        <updated_datetime>$updated_at</updated_datetime>
        <description>$desc</description>
    </request_update>
XML
        }
    }
    print <<XML;
Content-type: text/xml

<?xml version="1.0" encoding="utf-8"?>
<service_request_updates>
$xml
</service_request_updates>
$debug_str
XML
}