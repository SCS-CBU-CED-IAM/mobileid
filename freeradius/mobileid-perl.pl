#!/usr/bin/perl
# mobileid-perl.pl - 1.0
#
# rlm_perl script that can be called by freeradius as a module.
#
# It will use mobileid.pm from the same folder with the appropriate
# parameters out of the %RAD_REQUEST collection:
#  Called-Station-Id: contains the Mobile ID number
#  X-MSS-Message: contains the related Mobile ID message
#  X-MSS-Language: contains the related Mobile ID user language
#
# Sample rlm_perl module definition: /etc/freeradius/modules/perl_mobileid
# perl mobileid {
#	module = "/opt/mobileid/mobileid-perl.pl"
#   perl_flags = "-I/opt/mobileid"
# }
#
# Dependencies:
#  Perl modules: mobileid.pm File::Basename
#
# Change Log:
#  1.0 31.12.2013: Initial version.

use strict;
use utf8;
use File::Basename qw(dirname);
use mobileid;

# This is very important ! Without this script will not get the filled values from main.
use vars qw(%RAD_REQUEST %RAD_REPLY %RAD_CHECK);

#mobileid::trace_on();
select STDERR; $| = 1;
select STDOUT; $| = 1;

# This the remapping of return values
use constant    RLM_MODULE_REJECT=>     0;#  /* immediately reject the request */
use constant    RLM_MODULE_FAIL=>       1;#  /* module failed, don't reply */
use constant    RLM_MODULE_OK=>         2;#  /* the module is OK, continue */
use constant    RLM_MODULE_HANDLED=>    3;#  /* the module handled the request, so stop. */
use constant    RLM_MODULE_INVALID=>    4;#  /* the module considers the request invalid. */
use constant    RLM_MODULE_USERLOCK=>   5;#  /* reject the request (user is locked out) */
use constant    RLM_MODULE_NOTFOUND=>   6;#  /* user not found */
use constant    RLM_MODULE_NOOP=>       7;#  /* module succeeded without doing anything */
use constant    RLM_MODULE_UPDATED=>    8;#  /* OK (pairs modified) */
use constant    RLM_MODULE_NUMCODES=>   9;#  /* How many return codes there are */
    
# Logging. Same as src/include/radiusd.h
use constant    L_DBG=>     1;
use constant    L_AUTH=>    2;
use constant    L_INFO=>    3;
use constant    L_ERR=>     4;
use constant    L_PROXY=>   5;
use constant    L_ACCT=>    6;

# Mobile ID elements
use constant    CERT_FILE=> 'mycert.crt';
use constant    KEY_FILE=>  'mycert.key';
use constant    CA_FILE=>   'swisscom-ca.crt';
use constant    APID=>      'mid://dev.swisscom.ch';
use constant    APPASS=>    'disabled';

# rlm_perl function handling
sub post_auth {
    &radiusd::radlog(L_INFO, "$0::post_auth");

    # Check if running on Windows
    my $isWin  = 0;
    if ($^O eq 'MSWin32') { $isWin = 1; }

    # Get path of current script and define the OS related separator
    my $dir = dirname(__FILE__);
    my $sep = "/";
    if ($isWin == 1) {
        $sep = "\\";
    }

    # Get the relevant request attributes
    my $msisdn = $RAD_REQUEST{'Called-Station-Id'};
    my $msg    = $RAD_REQUEST{'X-MSS-Message'};
    my $lang   = $RAD_REQUEST{'X-MSS-Language'};

    # Spawn the call to the Mobile ID script
    my $mssapi = new mobileid;
    my $certfile = $dir . $sep . CERT_FILE;
    my $keyfile  = $dir . $sep . KEY_FILE;
    my $cafile   = $dir . $sep . CA_FILE;
    $mssapi->setssl($certfile, $keyfile, $cafile);
    $mssapi->setapinfo(APID, APPASS);
    &radiusd::radlog(L_INFO, "$0::MSS_Signature $msisdn '$msg' $lang");
    my $status = $mssapi->MSS_Signature($msisdn, $msg, $lang, 80);

    # Result handling
    $mssapi = undef;
    if ($status == 1) {
        &radiusd::radlog(L_INFO, "$0::post_auth RLM_MODULE_OK");
        return RLM_MODULE_OK;
    } else {
        &radiusd::radlog(L_ERR, "$0::MSS_Signature (status=$status)");
        &radiusd::radlog(L_ERR, "$0::post_auth RLM_MODULE_REJECT");
        return RLM_MODULE_REJECT;
    }

}

sub authorize {
    return RLM_MODULE_NOOP;
}

sub authenticate {
    return RLM_MODULE_NOOP;
}

sub preacct {
    return RLM_MODULE_NOOP;
}

sub accounting {
    return RLM_MODULE_NOOP;
}

sub checksimul {
    return RLM_MODULE_NOOP;
}

sub pre_proxy {
    return RLM_MODULE_NOOP;
}

sub post_proxy {
    return RLM_MODULE_NOOP;
}

sub xlat {
    return RLM_MODULE_NOOP;
}

sub detach {
    &radiusd::radlog(L_INFO, "$0::Detaching. Reloading. Done.");
    return RLM_MODULE_NOOP;
}

#==========================================================