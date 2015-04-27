# mobileid.pm - 1.0
#
# Generic perl module to invoke Swisscom Mobile ID service.
# Dependencies: SOAP::Lite, Time::HiRes
#
# Infos:
#  http://search.cpan.org/~phred/SOAP-Lite-1.08/lib/SOAP/Lite.pm
#  http://search.cpan.org/~gaas/libwww-perl-6.05/lib/LWP/UserAgent.pm
#
# Change Log:
#  1.0 31.12.2013: Initial version

package mobileid;

use strict;
use warnings;
use Time::HiRes qw(gettimeofday);

$MOBILEID::TRACE = 0;

use SOAP::Lite;

# Creator
sub new {
    my $self = {};
    my $x = shift;

    $self->{SOAPport}    = undef;
    $self->{msgingmode}  = 'synch';
    $self->{servicename} = 'uri';
    $self->{MSSP_URI}    = 'http://mid.swisscom.ch/';
 
    return bless $self;
}

# Destructor
sub DESTROY {
    my $self = shift;
    
    $self->{soapclient} = undef;
}

# Enable tracing
sub trace_on {
    my $self = shift;
    
    $MOBILEID::TRACE=1;
}

# Enable request tracing
sub trace_request_on {
    my $self = shift;
   
    SOAP::Lite->import(+trace => ['all', '-objects']);
}

# Defines the client auth related elements
sub setssl { # Cert, Key, CA
    my $self = shift;
    $self->{SSL_cert_file} = shift;
    $self->{SSL_key_file}  = shift;
    $self->{SSL_ca_file}   = shift;
}

# Defines the AP related elements
sub setapinfo { # APID, APPASS
    my $self = shift;
    $self->{APID}      = shift;
    $self->{APPASS}    = shift;
    
    $self->{APTRANSID} = sprintf("AP.PERL.%04d.%04d",rand(10000),rand(10000));
	$self->{INSTANT}   = $self->makeapinstant(gettimeofday);
}

# Creates an instant of '2008-01-17T13:22:00.363Z'
sub makeapinstant { 
    my $self = shift;
    my $t    = shift;
    my $usec = shift;
    my $tzoffset = shift;
    $tzoffset = 0 if (!defined($tzoffset));

    my @t = gmtime($t+$tzoffset);
    my $s = sprintf("%d-%02d-%02dT%02d:%02d:%02d.%06d",
		    1900+$t[5],1+$t[4],$t[3],$t[2],$t[1],$t[0],$usec);
    if ($tzoffset == 0) {
	    $s .= 'Z';
    } else {
	    $s .= ($tzoffset > 0) ? '+' : '-';
	    $tzoffset = 0 - $tzoffset  if ($tzoffset < 0);
	    $s .= sprintf("%02d:%02d", $tzoffset/3600, ($tzoffset/60)%60);
    }

    return $s;
}

# ################################################################

# Internal: Request attribute info
sub _build_reqattrs {
    my $self = shift;
    my %aset2 = @_;
    my %aset = ();

    $aset{'MajorVersion'} = 1;
    $aset{'MinorVersion'} = 1;
    $aset{'xmlns:mss'}    = 'http://uri.etsi.org/TS102204/v1.1.2#';
    $aset{'xmlns:fi'}     = 'http://mss.ficom.fi/TS102204/v1.0.0#';
    $aset{'TimeOut'}      = $self->{'timeout'};
    
    foreach my $key (keys %aset2) {
        if (defined($aset2{$key})) {
            $aset{$key} = $aset2{$key};
        }
    }

    return %aset;
}

# Internal: build AP info
sub _build_ap_info {
    my $self = shift;
    
    my %aset = ();
    $aset{'AP_ID'}      = $self->{APID}         if (defined($self->{APID}));
    $aset{'AP_PWD'}     = $self->{APPASS}       if (defined($self->{APPASS}));
    $aset{'AP_TransID'} = $self->{APTRANSID}    if (defined($self->{APTRANSID}));
    $aset{'Instant'}    = $self->{INSTANT}      if (defined($self->{INSTANT}));

    return SOAP::Data
	    -> name('mss:AP_Info' => '')
	    -> type('')
	    -> attr({ %aset })
	    ;
}

# Internal: build MSSP info
sub _build_mssp_id {
    my $self = shift;

    my @mss_ids = ();
    my $cnt = 0;

    if (defined($self->{MSSP_URI})) {
    push @mss_ids, SOAP::Data
        -> type('')
        -> name('mss:URI' => $self->{MSSP_URI})
        ;
    }

    return SOAP::Data
    -> name('mss:MSSP_Info' => \SOAP::Data
        -> name('mss:MSSP_ID' => \SOAP::Data
            -> value( @mss_ids )
            )
        )
    ;
}

# Internal: common fault parser
sub _parse_fault {
	my $self = shift;
	my $som  = shift;

	my $reasontxt    = $som->valueof('//Fault/Reason/Text');
	my $faultcode    = $som->valueof('//Fault/Code/Value');
	my $faultsubcode = $som->valueof('//Fault/Code/Subcode/Value');
	my $faultrole    = $som->valueof('//Fault/Role');
	my $faultnode    = $som->valueof('//Fault/Node');
	my $faultdetail  = $som->valueof('//Fault/Detail/detail');
	my $faulthost    = $som->valueof('//Fault/Detail/hostname');


	$self->{_faultresult}->{reasontext} = $reasontxt;
	$self->{_faultresult}->{code}       = $faultcode;
	$self->{_faultresult}->{subcode}    = $faultsubcode;
	$self->{_faultresult}->{role}       = $faultrole;
	$self->{_faultresult}->{node}       = $faultnode;
	$self->{_faultresult}->{host}       = $faulthost;
	$self->{_faultresult}->{detail}     = $faultdetail;
}

# ################################################################
# Signature request
sub MSS_Signature { # MSISDN, Message, UserLang, Timeout
    my $self = shift;
    $self->{MSISDN}      = shift;
    $self->{SIGNDATA}    = shift;
    $self->{userlang}    = shift;
    $self->{timeout}     = shift;
    $self->{SOAPport}    = 'https://mobileid.swisscom.com/soap/services/MSS_SignaturePort'; 
    $self->{signprofile} = 'http://mid.swisscom.ch/MID/v1/AuthProfile1';

    $self->{soapclient} = new SOAP::Lite
	    -> uri($self->{servicename})
	    -> readable($MOBILEID::TRACE)
	    -> soapversion(1.2)
	    -> encodingStyle('')
	    -> proxy($self->{SOAPport});

    # Set the SSL options
    $self->{soapclient}->transport->ssl_opts(
        SSL_cert_file => $self->{SSL_cert_file},
        SSL_key_file  => $self->{SSL_key_file},
        SSL_ca_file   => $self->{SSL_ca_file}
    );

    # Serialize it
    $self->{soapclient}->serializer()
	    -> envprefix('soapenv');

    # Create elements
    my @mss_elts = ();
    
    # Add the AP infos
    push @mss_elts, $self->_build_ap_info();

    # Add the MSSP Infos
    push @mss_elts, $self->_build_mssp_id();
 
    # Add the Mobile User
    if (defined($self->{MSISDN})) {
    push @mss_elts, SOAP::Data
        -> name('mss:MobileUser' => \SOAP::Data
            -> name('mss:MSISDN' => $self->{MSISDN})
            -> type('')
            );
    }

    # Add the DTBS
    if (defined($self->{'SIGNDATA'})) {
    push @mss_elts, SOAP::Data
        -> name('mss:DataToBeSigned' => $self->{SIGNDATA} )
        -> attr({ 'MimeType' => 'text/plain', 'Encoding' => 'UTF-8' })
        -> type('')
    }

    # Add the signature profile
    if (defined($self->{'signprofile'})) {
	push @mss_elts, SOAP::Data
	    -> name('mss:SignatureProfile' => \SOAP::Data
		    -> name('mss:mssURI' => $self->{'signprofile'})
		    -> type('')
		    );
    }

    # Define the optional additional services
    # <mss:AdditionalServices>
    my @mss_adds = ();
 
    # User language
    if (defined($self->{userlang})) {
	push @mss_adds, SOAP::Data
	    -> name('mss:Service' => \SOAP::Data
		    -> value( SOAP::Data
			      -> name('mss:Description' => \SOAP::Data
				      -> type('')
				      -> name('mss:mssURI' => 'http://mss.ficom.fi/TS102204/v1.0.0#userLang')
				      ),
			      SOAP::Data
			      -> type('')
			      -> name('fi:UserLang' => $self->{userlang})
			      )
		    );
    }
    # </mss:AdditionalServices>
    # Add additional services: we have some data
    if (scalar(@mss_adds) > 0) {
	push @mss_elts, SOAP::Data
	    -> name('mss:AdditionalServices' => \SOAP::Data
		    -> value(@mss_adds)
		    );
    } 

    # Build the final SOAP request 
    my %aset = $self->_build_reqattrs( 'MessagingMode', $self->{msgingmode}, 
				       'MSSP_TransID', $self->{'MSSP_TransID'} );
    my $mss_signrequest =  SOAP::Data
	    -> name('mss:MSS_SignatureReq' => \SOAP::Data
		    -> value(@mss_elts)
		    )
	    -> attr({ %aset });

    # Make SOAP Call
    my $som = $self->{soapclient}->call( SOAP::Data
					 -> uri('')
					 -> name('MSS_Signature')
					 => ($mss_signrequest)
					 );
    $self->{reply} = $som;
    my %results = ();  

    # Parse the failure and return
    if ($som->fault) {
	    $self->_parse_fault($som);
	    if ($MOBILEID::TRACE) {
            %results = $self->getfaultresults();
            printf "========= FAILURE =========\n";
            foreach my $k (sort keys %results) {
                printf("%-20s '%s'\n", $k, $results{$k});
            };
	    }
	    
	    return 0;
    }

    # Parse the success
    my $msisdn = $som->valueof('//MSS_SignatureResponse/MSS_SignatureResp/MobileUser/MSISDN');
    $self->{_result}->{msisdn} = $msisdn;

    my $useridentifier = $som->valueof('//MSS_SignatureResponse/MSS_SignatureResp/MobileUser/UserIdentifier');
    $self->{_result}->{useridentifier} = $useridentifier;

    my $msspuri        = $som->valueof('//MSS_SignatureResponse/MSS_SignatureResp/MSSP_Info/MSSP_ID/URI');
    my $msspdnsname    = $som->valueof('//MSS_SignatureResponse/MSS_SignatureResp/MSSP_Info/MSSP_ID/DNSName');
    my $msspipaddress  = $som->valueof('//MSS_SignatureResponse/MSS_SignatureResp/MSSP_Info/MSSP_ID/IPAddress');
    my $msspidstring   = $som->valueof('//MSS_SignatureResponse/MSS_SignatureResp/MSSP_Info/MSSP_ID/IdentifierString');
    $self->{_result}->{msspuri} = $msspuri;
    $self->{_result}->{msspdnsname} = $msspdnsname;
    $self->{_result}->{msspipaddress} = $msspipaddress;
    $self->{_result}->{msspidentifierstring} = $msspidstring;

    my $mssptransid = $som->dataof('//MSS_SignatureResponse/MSS_SignatureResp')->attr->{'MSSP_TransID'};
    $self->{_result}->{mssp_transid} = $mssptransid;

    my $signature = $som->valueof('//MSS_SignatureResponse/MSS_SignatureResp/MSS_Signature/Base64Signature');
    $self->{_result}->{signature} = $signature;

    my $signatureprofile = $som->valueof('//MSS_SignatureResponse/MSS_SignatureResp/SignatureProfile/mssURI');
    $self->{_result}->{signatureprofile} = $signatureprofile;

    my $v_statuscode = $som->dataof("//MSS_SignatureResponse/MSS_SignatureResp/Status/StatusCode")->attr->{'Value'};
    my $v_statusmsg  = $som->valueof("//MSS_SignatureResponse/MSS_SignatureResp/Status/StatusMessage");
    my $v_statusdet  = $som->valueof("//MSS_SignatureResponse/MSS_SignatureResp/Status/StatusDetail/");
    $self->{_result}->{statuscode}    = $v_statuscode;
    $self->{_result}->{statusmessage} = $v_statusmsg;
    $self->{_result}->{statusdetail}  = $v_statusdet;

    # Trace the success
    if ($MOBILEID::TRACE) {
        %results = $self->getresults();
        printf "========= SUCCESS =========\n";
        foreach my $k (sort keys %results) {
            printf("%-20s '%s'\n", $k, $results{$k});
        }
    }

    # Return a status
    return 1;
}

# ################################################################

sub getresults {
    my $self = shift;
    my %results = ();

    foreach my $k ('msisdn', 'mssp_transid', 'signature', 'statuscode', 'statusmessage') {
	    if (defined($self->{_result}->{$k})) {
	        $results{$k} = $self->{_result}->{$k} if (defined($self->{_result}->{$k}));
	    }
    }

    return (%results);
}

sub getfaultresults {
    my $self = shift;
    my %results = ();
    foreach my $k ('reasontext', 'subcode', 'detail') {
	    if (defined($self->{_faultresult}->{$k})) {
	        $results{$k} = $self->{_faultresult}->{$k} if (defined($self->{_faultresult}->{$k}));
	    }
    }

    return (%results);
}

1;