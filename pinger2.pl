#!/usr/bin/perl

=head1 NAME

PingER2 - New version of PingER with more configurability and maintainablity

=head1 SYNOPSIS

Edit pinger.xml to configure pingER2. 

To run pinger2 execute: C<perl pinger2.pl.>

Pinger will ping all the hosts listed in the configuration and output the results in the DataDirectory

=head1 Pinger.XML Configuration File Format

The Pinger.XML configuration file is written in XML following the XML Schema Definition in pinger.xsd. PingER2 does not check the file for adherence to this schema and might crash if the configuration file is corrupted. Use a XML-validator (for example http://apps.gotdotnet.com/xmltools/xsdvalidator/) to make sure manual changes to the file are correctly done. Preferred and strongly encouraged is the use of the configuration GUI. In case you should edit the configuration file manually make sure that you pay attention to exact capitalization (e.g. TimeToNotification != TimetoNotification).

=over

=item Main Group

=over

=item <PingER>

All the configuration groups are contained in a <PingER> and </PingER> pair.

Example:

    See the file pinger.example.xml in the main directory of the PingER distribution.

=item <Version>

Contains the version number of the PingER2 program. This will be used to convert the file-format to a new version when PingER2 evolves.

Example:

    <Version>2.0.0</Version>

=item <DataDirectory>

All output produced from PingER2 will be dumped into this Directory. If you want to publish PingER2 data on the web using 'connectivity.pl' from the PingER distribution then make sure that this location is accessible. The path has to be provided without a trailing '/'.

Example:

    <DataDirectory>/home/PingER/data</DataDirectory>

=item <SrcName> 

This is the name of the machine where PingER2 runs. PingER2 can try to determine this automatically if this entry is missing. Since this name appears in the output of PingER2 this not be a bogus value like Localhost.

Example:

    <SrcName>gaia9.cc.gatech.edu</SrcName>

=item <SrcIP>

This IP will be outputted by PingER2 and can be determined by <SrcName> if the entry is missing.

Example:

    <SrcIP>192.168.2.1</SrcIP>

=item <MaxProcessCount>

This number determines how many current ping processes are spawned by PingER2. This effectively multiplies the speed of PingER2. Make sure that you have clearance from your Networking Department to lunch massive ping attacks and refrain from pinging arbitrary targets for fun. This might lead to ICMP relay being disabled or you getting mail from network admins.

Example:

    <MaxProcessCount>5</MaxProcessCount> 

=item <DnsV4Cmd>

PingER2 uses this command to query IPV4 addresses from DNS. The command should return a single line containing the IP or a blank line. Popular 'dig' or 'host' will return multiple lines due to CNAME or multiple IP addresses. PingER2 distribution contains a helper script called DnsV4Cmd.pl that uses Perl built-in gethostbyname to resolve host names to IPV4 addresses. For IPV6 such a built-in does not exists so that dig had to be used. The command should include %destination which will be replaced by PingER2 with the host name.

Example:

    <dnsV4Cmd>/home/pinger/pinger/dnsV4Cmd.pl %destination</dnsV4Cmd>

=item <DnsV6Cmd>

Exactly as DnsV4Cmd but defines the DNS-command to be used for IPV6 lookups. The command and it's caveats are described within the description of DnsV4Cmd.

Example:

    <dnsV6Cmd>/usr/bin/dig -t aaaa +short %destination</dnsV6Cmd>

=item <PingV4Cmd>

PingER2 uses this command to ping individual host using IPV4 protocol. PingER2 will try to determine this command during the installation. Make sure that the user the script is run under has all the rights to execute the PingCmd, which might not be the case if you are running a security restricted *nix distribution. This means that either you have to have suid-bits set on the command or run the script using root rights of which the latter is strongly discouraged.

The following identifiers should be present in the command:

=over

=item 

%deadline Should be placed where the timeout parameter is placed

=item

%count Will be replaced with the number of pings to send

=item

%interval The script fills in the interval between individual pings

=item

%packetsize The size of individual packets will be entered here by the script

=item

%destination The destination IP, without it there is no ping.

=back

Example:

    <PingV4Cmd>/bin/ping -n -w %deadline -c %count -i %interval -s %packetsize %destination</PingV4Cmd> 

=item <PingV6Cmd>

Exactly the same as PingV4Cmd but for identifying the command used for pinging IPV6 hosts. 

Example:

    <PingV6Cmd>/bin/ping6 -n -w %deadline -c %count -i %interval -s %packetsize %destination</PingV6Cmd>

=item <BeaconListConfig>

The list of beacons stored in <BeaconList> can be updated according to the entries in <BeaconListConfig>. This is recommended because using this technique no unnecessary hosts are pinged and new entries will be automatically updated.

This tag has the following sub-entries:

=over

=item <HttpGetBin>

This is the command which will be used to retrieve the beacons List. %s will be expanded to the URL of the file to fetch as defined in BeaconListURL.  

=item <BeaconListURL>

Holds the address of the file to be downloaded using the <HttpGetBin> command and be parsed for beacon information.

=item <LastChecked>

Will be filled with a value by PingER2 to keep track of the last time the beaconList was retrieved.

=item <RefereshInterval>

A date that determines the amount of time between two consequitive downloads of the list (See section on dates for examples and reference to the format used).

=back

Example:

    <BeaconListConfig>
        <HttpGetBin>lynx -source -dump %s</HttpGetBin>
        <RefreshInterval>1 day</RefreshInterval>
        <LastChecked>1077803679</LastChecked>
        <BeaconListURL>http://www-iepm.slac.stanford.edu/pinger/beacons.txt</BeaconListURL>
    </BeaconListConfig>

=item <doRandomWait> ::= BOOLEAN

Using the values 'true' and 'false' it is possible to configure pinger to wait a random amount of time inside each ping interval specified by <waitInterval>. Given for instance a waitInterval of 30 minutes and 'true' for doRandomWait, PingER2 will start pinging hosts anywhere inside each 30 minutes interval. This option is usefull if regular pings every day at the same time are not desireable (for instance if they might be registered by the network administrator of the host ping or interfere with other regular activities as backups, etc.).

Example:
    
    <doRandomWait>true</doRandomWait>

=item <waitInterval> ::= TIME IN MINUTES

Specifies the amount of time to wait between runs of PingER2. Please notice that since PingER2 uses Cron to handle the activiation of the pinger2.pl script in regular intervals, it is necessary that after each change to the value of waitInterval the script installCron.pl needs to be executed. The script will update the existing cron-table by replacing the current pinger2.pl entry with the new values. The amount of time should be specified in minutes, but can alternatively also be given using the modifiers hour, day, week or month.

Example:

    <waitInterval>1 hour</waitInterval>

=item <HostList>

This field holds any number of <Host>-entries which will get called by PingER2. In contrast to <BeaconList> these entries are not overridden by the refresh as defined in <BeaconListConfig>. That means that all custom hosts that are to be monitored in addition to the BeaconList should go into this list.

Example:

    <HostList>
        <Host>
            <Name>www.cc.gatech.edu</Name>
        </Host>
        <Host>
            <Name>www.foo.bar</Name>
            <IP>192.168.1.1</IP>
        </Host>
    </HostList>

=item <BeaconList>

This tag groups any number of <Host>-entries which will get called by PingER2. In contrast to <HostList> these entries are overridden by the refresh as defined in <BeaconListConfig>. Customizations of the list of hosts to be pinged should go into the <HostList>.

Example:

    <BeaconList>
        <Host>
            <IP>134.79.18.21</IP>
            <EnableDNSCache>false</EnableDNSCache>
            <Ping>
                <NumPackets>50</NumPackets>
            </Ping>
            <Name>ping.slac.stanford.edu</Name>
        </Host>
        <Host>
            <IP>131.225.9.20</IP>
            <EnableDNSCache>false</EnableDNSCache>
            <Ping>
                <NumPackets>20</NumPackets>
            </Ping>
            <Name>fnal.fnal.gov</Name>
        </Host>
    </BeaconList>

=back

=item Sub-Entries:

=over

=item <Host> ::= xs:complexType

Using this tag allows the configuration of individual host. The most important sub-tag is <Name>. Using this name PingER2 can effectively determine the IP and will assume default settings for the rest of the configuration parameters.

Sub-Tags:

=over

=item <EnableDNSCache> ::= BOOLEAN

If set to true this entry will enable the internal DNS-caching functionality. This means that PingER2 will store IPs to guard against DNS-failure.

Example:

    <EnableDNSCache>true</EnableDNSCache>

=item <Enabled> ::= BOOLEAN

A host can be excluded from being pinged by setting this value to false. 

Example:

    <Enabled>false</Enabled>

=item <IP> ::= A|Quad-A IP Address

PingER2 will try to determine the IP address of the host using a DNS lookup when possible. To circumvent this lookup PingER2 provides this tag to statically assign an IP. Be aware that PingER2 also provides a DNS-cache which will utilize this field to store queried DNS-information.

Example:

    <IP>192.168.1.2</IP>

=item <LogType> ::= full|...

Determines how much of the statistics gathered from pinging this host will be stored in the data output. If the value is set to 'full' then all available information are dumped into the data directory. All other values reduce the output to "min/max/avg".

Example:

    <LogType>minimal</LogType>

=item <Name> ::= STRING

The name of the host to be pinged. This is the essential tag that needs to be supplied for all <Host>s.

Example:

    <Name>www.cc.gatech.edu</Name>

=item <Protocol> ::= IPV4|IPV6

Controls IPv4 vs. IPv6 behavior in PingER2. To ping a individual host with both IPV4 and IPV6 the corresponding host entry has to be duplicated.

Example:

    <Protocol>IPV4</Protocol> 

=item <WaitTime> ::= INTEGER

Determines the amount of time to be wait between individual pings. Be aware that this will increase the time pingER2 needs to complete it's task.

Example:

    <WaitTime>1</WaitTime> 

=back

Complex Tags (still inside <Host>)

=over

=item <Alarm>

If PingER2 fails to reach the host or while determining the IP, Alarm offers a way to configure PingER2 to notify the maintainer of the local PingER version. This feature should be seen as warning tool or as a convenience feature for the beacon list maintainer.

=over

=item <TimeToNotification> ::= TIME

Determines the amount of time PingER will ignore failures. When the interval passed without a successful ping or DNS-lookup then alarm will be invoked.

Example:

    <TimeToNotification>12 hours</TimeToNotification>

=item <Enabled> ::= true|false

This tag is used by pingER2 to switch off the Alarm when Snoozing is diabled or can be used by the maintainer to do the same manually.

Example:

    <Enabled>true</Enabled>

=item <Snooze> ::= true | false

With this feature PingER2 tries to simulate an alarm clock that goes back to sleep after the alarm rings only to ring again after the alarm interval passed again. If snooze is disabled an alarm will only trigger once. The alarm feature does not interfere with the host being pinged, it's just a convenience.

Example:
    
    <Snooze>true</Snooze> >>

=item <TimeOfFirstFailure> ::= INTEGER

This tag will hold the value in seconds after 1970 since when the failure occurred. PingER2 uses this value to determine when the alarm has to go off.

Example:

    <TimeOfFirstFailure>1077812075</TimeOfFirstFailure>

=item <AlarmCmd> ::= STRING

The AlarmCmd is triggered whenever a host exceeded the specified alarm interval. This parameter should contain %message which will be replaced before executing the command. The first example provided appends the error message to the log.file while the second sends an email to the account holder under which PingER2 is run.

Example:

    <AlarmCmd>echo '%message' >> log.file</AlarmCmd>
    <AlarmCmd>echo -e '%message' | mail `whoami` -s "PingER2 Error Message"</AlarmCmd>

=back

=item <Ping>

This complex tag holds all information that determines how to ping a individual host. It is possible to have multiple <Ping> entries per <Host>. PingER2 will traverse them one by one. The following two entries get grouped inside a <Ping>-entry:

=over

=item <NumPings> ::= INTEGER

The number of pings to send to the host. Notice that a large number will also take a respective amount of time, since pings are spaced with a time from <WaitTime>.

Example:

    <NumPings>10</NumPings>

=item <PacketSize> ::= INTEGER

The size in byte of the payload sent to the host as part of the ICMP echo request. A large packet size may overload poor connections especially in developing countries.

Example:

    <PacketSize>100</PacketSize>

=back 

Example for Ping:
    
    <Ping>
        <PacketSize>1000</PacketSize>
        <NumPings>10</NumPings>
    </Ping>

=back

=item <DefaultHost>

This tag is structured exactly as <Host> but provides opportunity to provide default values, i.e. whenever a configuration tag is not found in a <Host> entry the <DefaultHost> will be queried. This saves disk space for the configuration file and makes it more easier to read and modify.

=back

=back

=head1 Description of Internal Variables

The following variable are used inside the PingER script that might be interesting when extending PingER2.

=over

=item logLevel

Represents the amount of logging done by PingER2. From 0 to 10 where 0 is 0 is no and 10 is maximal logging.

=item logFile

Handle to the file which is used for logging.

=item config

This holds the data structure representation of the data unserialized from the configuration file using XML::Simple.

=item beaconList, hostList

These list are arrays of the respective hosts.

=item defaultHost

This variable holds the datastructure representing the fall-back options if the host does not specify it.

=item dataDirectoy

Retrieved from the configuration db. All data output is dumped into this directory.

=item pingV4Cmd, pingV6Cmd, dnsV4Cmd, dnsV6Cmd

Command strings to the respective commands. Should contain % quantifiers.

=item srcName, srcIP

Information representing the source machine.

=item ProcessCount, maxProcessCount

Number of current and maximal processes performing ping-queries.

=back

=head1 Description of Internal Functions

=cut


use XML::Simple;
use Data::Dumper;
use warnings;
use strict;
use Fcntl; 

# Forward variable declarations
my $version="2.0.3, 12/18/2011 by Cottrell";#Verify lynx returns something
my ($logLevel, $logFile, $config, $beaconList, $hostList, $defaultHost, $dataDirectory, $pingV4Cmd, $pingV6Cmd, $dnsV4Cmd, $dnsV6Cmd,
    $srcName, $srcIP, $ProcessCount, $maxProcessCount, $doRandomWait, $waitInterval);


=head2 checkBeaconConfiguration()

This function will retrieve information from the web about beacons and updates entries in the C<< <BeaconList> >>. 

Caution: All existing sub-entries of C<< <BeaconList> >> will be overriden. Entries that are to survive update should to into C<< <HostList> >>

In: The function takes no parameters.

Out: The function returns no value.

=cut

# Makes sure that the configuration file holds a valid BeaconListConfig and checks if we still have the valid beacon.
sub checkBeaconConfiguration()
{
    if (my $beaconConfig = $config->{'BeaconListConfig'})
    {
	my $lastChecked;
	if (!($lastChecked = $beaconConfig->{'LastChecked'}))
	{
	    $lastChecked = 0;
	}

	# Get RefreshInterval
	my $refreshInterval;
	if (!($refreshInterval = $beaconConfig->{'RefreshInterval'}))
	{
	    # Initialize default Value
	    $beaconConfig->{'RefreshInterval'} = '1 Month'; # Default is 30 days
	    $refreshInterval = 86400 * 30;
	} else {
	    $refreshInterval = parseTime($refreshInterval);
	    if ($refreshInterval == -1)
	    {
		# If we could not parse the value then reset to 1 Month
		&logger( `date` . ": Invalid <BeaconListConfig><RefreshInterval>. Resetting to 1 month.", 4);
		$beaconConfig->{'RefreshInterval'} = '1 Month'; # Default is 30 days
		$refreshInterval = 86400 * 30;
	    }
	}
	
	if (time - $lastChecked > $refreshInterval)
	{
	    # Refresh now!
	    &logger("BeaconList will be updated. LastUpdate was: $lastChecked interval is $refreshInterval.\n", 5);

	    my $beaconListURL;
	    if (!($beaconListURL = $beaconConfig->{'BeaconListURL'}))
	    {
		$beaconListURL = $beaconConfig->{'BeaconListURL'} = 'http://www-iepm.slac.stanford.edu/pinger/beacons.txt';
	    }

	    my $httpGetBin;
	    if (!($httpGetBin = $beaconConfig->{'HttpGetBin'}))
	    {
		$httpGetBin = $beaconConfig->{'HttpGetBin'} = 'lynx -source -dump %s';
	    }

	    $httpGetBin =~ s/%s/$beaconListURL/;

	    my $beacons = `$httpGetBin`;

	    my @beacons = split(/\n/, $beacons);

	    # We clear the beacon list before downloading
	    # Entries that are not to be deleted have to go into <HostList>
            unless(scalar(@beacons)<=0) {$beaconList = $config->{'BeaconList'}->{'Host'} = [];}#Mod by Cottrell 12/18/11
            
	    my $line;    
	    foreach $line (@beacons)
	    {
		
		# Get rid of comments and removed hosts
		$line =~ s/\s*(\#|!).*$//;

		# Kill whitespace delimiters
		chomp($line);

		# Skip blank lines
		next unless ($line =~ /\w/); 
		
		# Parse new host
		my $host = {};

		# Check if the hosts specifies custom # of pings and sizes
		my $ping = {};
		my $modified = 0;

		if($line =~ s/send=(\d+)\s*//) {
		    $ping->{'NumPings'} = $1;
		    $modified = 1;
		}

		if($line =~ s/size=(\d+)\s*//) {
		    $ping->{'PacketSize'} = $1;
		    $modified = 1;
		}

		if($modified){
		    $host->{'Ping'} = [$ping];
		}

		# Logging
		if($line =~ s/log=(\d+)\s*//) {
		    $ping->{'LogType'} = $1;
		}

		my $name;
		my $ip;
		($name, $ip) = split(/\s+/,$line);

		$host->{'Name'} = $name;

		$ip =~ /(\d+\.\d+\.\d+\.\d+)/;
		$host->{'IP'} = $1;

		# Beacons get their IPs supplied in the file and are not updated by the DNSCache
		$host->{'EnableDNSCache'} = 'false';

		# Add the newly created host to the beaconList
		push(@{$beaconList}, $host);
	    }
	    $beaconConfig->{'LastChecked'} = time;

    	    &logger("BeaconList has been updated. #beacon lines=".scalar(@beacons)."\n", 0);
	} else {
	    &logger("BeaconList is still up to date.\n", 1);
	}
    }
}

=pod

=head2 parseTime(dateString)

This function will take it''s input parameter and transform it into seconds. ParseTime takes a string and extracts a number and an optional quantifier. The following time quantifiers are understood.

=over 4

=item *

mi = Minutes = 60 seconds

=item * 

mo = Months = 30 * 24 * 60 * 60 seconds

=item *

h = Hours = 60 * 60 seconds

=item *

d = Days = 24 * 60 * 60 seconds

=item *

w = Weeks = 7 * 24 * 60 * 60 seconds

=item *

y = Years = 365 * 24 * 60 * 60 seconds

=back

In: String with a time value.

Out: Time in seconds.

=cut

sub parseTime(%){
    my $string = $_[0];
    $string =~ /\D*(\d*)\D*/;
    my $number = $1;
    
    if (!$number)
    {
	return -1;
    }
    
    if ($string =~ /mi/i) 
    {
	return $number * 60;
    }

    if ($string =~ /mo/i)
    {
	return $number * 3600 * 24 * 30;
    }

    if ($string =~ /h/i)
    {
	return $number * 3600;
    }

    if ($string =~ /d/i)
    {
	return $number * 3600 * 24;
    }

    if ($string =~ /w/i)
    {
	return $number * 3600 * 24 * 7;
    }
    
    if ($string =~ /y/i)
    {
	return $number * 3600 * 24 * 365;
    }
    return $number;
}

#  A small number of tests for parseTime
sub testParseTime(){
    if (&parseTime('1 min')           != 60)         { print "Test Fail - ParseTime - Minute\n";}
    if (&parseTime('2 min')           != 120)        { print "Test Fail - ParseTime - Minute\n";}
    if (&parseTime('1 hour')          != 3600)       { print "Test Fail - ParseTime - Hour\n";  }
    if (&parseTime('day 1')           != 86400)      { print "Test Fail - ParseTime - Day\n";   }
    if (&parseTime('week1')           != 7 * 86400)  { print "Test Fail - ParseTime - Week\n";  }
    if (&parseTime('1MONTH')          != 30 * 86400) { print "Test Fail - ParseTime - Uppercase\n"; }
    if (&parseTime('1 month')         != 30 * 86400) { print "Test Fail - ParseTime - Month\n"; }
    if (&parseTime('year        \n2') != 2*365*86400){ print "Test Fail - ParseTime - Year\n";  }
}

=head2 getAttributeWithAlternative(main,alternative,attributeName)

Thefunction will retrieve an attribute from a given XML::Simple data structure. If the attribute is not available, the function will fall back onto an alternative data structure.

In: Main data structure, Alternative data structure and attribute name

Out: Value of the retrieved attribute or undef if the item could not be found in both the main and alternative data structure.

=cut

sub getAttributeWithAlternative($$$)
{
    my $main = $_[0];
    my $alternative = $_[1];
    my $attribute = $_[2];

    my $result = $main->{$attribute};

    if ($result){
	return $result;
    } else {
	return $alternative->{$attribute};
    }
}

=head2 getHostAttribute(host,attribute)

Retrieves an attribute from the given host or falls back onto the default host if the attribute could not be found.

In: Host reference and attribute name.

Out: Value of the retrieved host attribute or the value given by the defaultHost for that attribute. Undef if neither is available.

=cut

sub getHostAttribute($$)
{
    return getAttributeWithAlternative($_[0], $defaultHost, $_[1]);
}

=head2 getGroupAttribute(host,group,attribute)

Retrieves an attribute in a sub-entry of the given host or looks that entry up in the default host. That function is necessary for more complex lookups into the host/defaultHost data structures.

In: Host reference, group name and attribute name.

Out: The group attribute if found in the host, the sub-entry of the defaultHost/group or undef.

=cut

sub getGroupAttribute($$$){
    my $group = &getHostAttribute($_[0], $_[1]);
    return &getAttributeWithAlternative($group, $defaultHost->{$_[1]}, $_[2]);
}

=head2 setGroupAttribute(host,group,attribute,value)

Sets an attribute in a sub-entry of the given host. If the group does not exists it will be created.

In: Host reference, group name, attribute name and value.

Out: The function does not return any value.

=cut

sub setGroupAttribute($$$$){
    my $host = $_[0];
    my $groupName = $_[1];
    my $attribute = $_[2];
    my $value = $_[3];
    my $group = $host->{$groupName};
    if (!defined $group){
	$group = $host->{$groupName} = {};
    }
    $group->{$attribute} = $value;
}

=head2 retrieveAndcheckForDefault(tagName, defaultValue)

Will try to retrieve a tag with the given name from the main group. 

If the tag is not available it will set it to the value passed as the second parameter.

In any case the function returns the value of the tag in the main group.

=cut

sub retrieveAndCheckForDefault($$){
    my $tag = $_[0];
    my $default = $_[1];
    
    my $result = $config->{$tag};
    if (not defined $result){
	$config->{$tag} = $default;
	$result = $default;
    };
    return $result;
}

=head2 getList(listName)

The function will return the given list from the configuration file and initializes it with an empty entry in case the list did not exist.

In: Name of the list to retrieve.

Out: An array of the entries in the list. If the list is empty or did not exist an empty array is returned.

=cut

sub getList($){
    my $name = $_[0];
    if (! $config->{$name}){
	$config->{$name} = {};
    }
    if (! ($config->{$name}->{'Host'}) ){
	$config->{$name}->{'Host'} = [];
    }
    
    return $config->{$name}->{'Host'};
}

sub getAlarmEnabled($){
    getGroupAttribute($_[0], 'Alarm', 'Enabled');
}

sub getAlarmTimeToNotification($){
    getGroupAttribute($_[0], 'Alarm', 'TimeToNotification');
}

sub getAlarmTimeOfFirstFailure($){
    getGroupAttribute($_[0], 'Alarm', 'TimeOfFirstFailure');
}

sub getAlarmCmd($){
    getGroupAttribute($_[0], 'Alarm', 'AlarmCmd');
}    

sub getAlarmSnooze($){
    getGroupAttribute($_[0], 'Alarm', 'Snooze');
}    

sub getNumPings($){
    return getAttributeWithAlternative($_[0], $defaultHost->{'Ping'}[0], 'NumPings');
}

sub getPacketSize($){
    return getAttributeWithAlternative($_[0], $defaultHost->{'Ping'}[0], 'PacketSize');
}

=head2 checkDefaultHostConfig(host)

This function will check and initialize the default values of the defaultHost entry. This is important because several functions lateron rely on results from the get*Attribute functions.

In: The reference to the default host.

Out: This function does not return any value.

=cut

sub checkDefaultHostConfig($)
{
    my $defaultHost = $_[0];

    if (!$defaultHost->{'RefreshInterval'}){
	$defaultHost->{'RefreshInterval'} = '86400';
    } 

    # Make sure we have valid default entries for Ping
    if (!$defaultHost->{'Ping'})
    {
	$defaultHost->{'Ping'} = [{'NumPings' => '10', 'PacketSize' => '100'}, {'NumPings' => '10', 'PacketSize' => '1000'}];
    }

    my $ping = $defaultHost->{'Ping'}[0];
    
    if (! $ping ){
	die 'FATAL ERROR in checkDefaultHostConfig()';
    }
    
    if (!$ping->{'NumPings'})
    {
	$ping->{'NumPings'} = '10';
    } 

    if (!$ping->{'PacketSize'})
    {
	$ping->{'PacketSize'} = '100';
    }
}

sub testCheckDefaultHostConfig(){
    my $testConfig = XMLin("<Pinger><DefaultHost></DefaultHost></Pinger>", ForceArray => ['Ping']);

    checkDefaultHostConfig($testConfig->{'DefaultHost'});
    $testConfig = XMLin(XMLout($testConfig), ForceArray => ['Ping']);
    if (! $testConfig->{'DefaultHost'}->{'RefreshInterval'}){
	print "Test Fail - checkDefaultHostEntry - RefreshInterval 1\n";
    }
    if (! $testConfig->{'DefaultHost'}->{'Ping'}){
	print "Test Fail - checkDefaultHostEntry - Ping Exists 1\n";
    }
    if (! $testConfig->{'DefaultHost'}->{'Ping'}[0]->{'NumPings'}){
	print "Test Fail - checkDefaultHostEntry - NumPings 1\n";
    }
    if (! $testConfig->{'DefaultHost'}->{'Ping'}[0]->{'PacketSize'}){
	print "Test Fail - checkDefaultHostEntry - PacketSize 1\n";
    }

    $testConfig = XMLin("<Pinger><DefaultHost><Ping><NumPings>3</NumPings></Ping></DefaultHost></Pinger>", ForceArray => ['Ping']);
    checkDefaultHostConfig($testConfig->{'DefaultHost'});

    $testConfig = XMLin(XMLout($testConfig), ForceArray => ['Ping']);
    if (! $testConfig->{'DefaultHost'}->{'RefreshInterval'}){
	print "Test Fail - checkDefaultHostEntry - RefreshInterval 2\n";
    }
    if (! $testConfig->{'DefaultHost'}->{'Ping'}){
	print "Test Fail - checkDefaultHostEntry - Ping Exists 2\n";
    }
    if (! $testConfig->{'DefaultHost'}->{'Ping'}[0]->{'NumPings'}){
	print "Test Fail - checkDefaultHostEntry - NumPings 2\n";
    }
    if (! $testConfig->{'DefaultHost'}->{'Ping'}[0]->{'PacketSize'}){
	print "Test Fail - checkDefaultHostEntry - PacketSize 2\n";
    }

    $testConfig = XMLin("<Pinger><DefaultHost><Ping><PacketSize>3</PacketSize></Ping></DefaultHost></Pinger>", ForceArray => ['Ping']);

    checkDefaultHostConfig($testConfig->{'DefaultHost'});

    $testConfig = XMLin(XMLout($testConfig), ForceArray => ['Ping']);
    if (! $testConfig->{'DefaultHost'}->{'RefreshInterval'}){
	print "Test Fail - checkDefaultHostEntry - RefreshInterval 3\n";
    }
    if (! $testConfig->{'DefaultHost'}->{'Ping'}){
	print "Test Fail - checkDefaultHostEntry - Ping Exists 3\n";
    }
    if (! $testConfig->{'DefaultHost'}->{'Ping'}[0]->{'NumPings'}){
	print "Test Fail - checkDefaultHostEntry - NumPings 3\n";
    }
    if (! $testConfig->{'DefaultHost'}->{'Ping'}[0]->{'PacketSize'}){
	print "Test Fail - checkDefaultHostEntry - PacketSize 3\n";
    }
}


=head2 alarm(host,message)

The alarm function can be called anytime a problematic situation has occured. It will lookup the alarm configuration and trigger the alarmCmd if alarm time has exceeded. There is oneshot-functionality embedded in the alarm-system, that allows for notifications to be triggered only once.

Input: Host that has produced an error and the error message.

Output: This function does not produce any results.

=cut

sub alarm($$)
{
    my $host = $_[0];
    my $hostName = $host->{'Name'};
    my $message = $_[1];

    my $alarmEnabled = &getAlarmEnabled($host);

    if (defined($alarmEnabled) && ($alarmEnabled =~ /true/))
    {
	&logger("alarm(): $hostName -> Alarms are enabled\n", 9); 

	my $timeToNotification = &parseTime(&getAlarmTimeToNotification($host));
	my $timeOfFirstFailure = &getAlarmTimeOfFirstFailure($host);

	if (defined($timeOfFirstFailure))
	{
	    &logger("alarm(): $hostName -> Has had failures before\n", 9); 
	    my $timePassed = time - $timeOfFirstFailure;
	    if ($timePassed > $timeToNotification)
	    {
		&logger("alarm(): $hostName -> Alarm Interval was exceeded -> Notification\n", 9); 
		&alarmNotify($host, $message);
	    } else {
		&logger("alarm(): $hostName -> Still inside Alarm Interval ($timePassed/$timeToNotification)-> No Notification\n", 9); 
	    }		
	    
	} else {
	    # This is the first failure!
	    if (0 == $timeToNotification)
	    {
		&logger("alarm(): $hostName -> Failure on zero tolerance policy -> Notification\n", 9); 
		&alarmNotify($host, $message);
	    } else {
		&logger("alarm(): $hostName -> First failure but we tolerate that -> No Notification\n", 9); 
		&setGroupAttribute($host, 'Alarm', 'TimeOfFirstFailure', time);
	    }
	}
    } else {
	&logger("alarm(): Alarm not enabled for this host.\n", 10);
    }

}

=head2 alarmNotify(host,message)

Does bypass the tolerance function of the alarm-system and directly dispatches a notification for the given host. Snoozing/Oneshot-functionality is maintained.

Input: The host for which an alarm was triggered and the message to send to the administrative team.

Output: This function does not produce any results.

=cut

sub alarmNotify($$)
{
    my ($host, $message) = @_;
    my $hostName = $host->{'Name'};
    my $alarmCmd = &getAlarmCmd($host);
    $alarmCmd =~ s/%message/$message/;
    
    &logger("alarmNotify(): Executing AlarmCmd\n", 6);
    `$alarmCmd`;
    
    if (&getAlarmSnooze($host) =~ /true/)
    {
	&logger("alarmNotify(): $hostName -> Snoozing enabled -> Reseting Alarm\n", 9); 
	&setGroupAttribute($host, 'Alarm', 'TimeOfFirstFailure', time);
    } else {
	&logger("alarmNotify(): $hostName -> Snoozing disabled -> Alarm switched off\n", 9);
	&setGroupAttribute($host, 'Alarm', 'Enabled', 'false');
    }
}

sub getIPV4($){
    return &_getIP(1, $_[0]);
}

sub getIPV6($){
    return &_getIP(0, $_[0]);
}

sub _getIP($$){
    my $ipv4 = $_[0];
    my $hostname = $_[1];
    my $dnsCmd;

    if ($ipv4){
	&logger("getIPV4: $hostname\n", 7);
	$dnsCmd = $dnsV4Cmd;
    } else {
	&logger("getIPV6: $hostname\n", 7);
	$dnsCmd = $dnsV6Cmd;
    }

    $dnsCmd =~ s/%destination/$hostname/;
    
    my $ip = `$dnsCmd`;

    if (defined($ip)){
	if (length($ip) == 0) {
	    $ip = undef;
	} else {
	    chomp($ip);
	}
    }

    return $ip;
}

sub testGetIP(){

    if (not defined &getIPV4("www.gatech.edu")){
	print "Failure - IPV4 on IPV4 Define\n";
    }

    if (defined &getIPV6("www.gatech.edu")){
	print "Failure - IPV6 on IPV4 Define\n";
    }

    if (not defined &getIPV6("www.ipv6.sox.net")){
	print "Failure - IPV6 on IPV6 Define\n";
    }

    if (defined &getIPV4("www.ipv6.sox.net")){
	print "Failure - IPV4 on IPV6 Define\n";
    }
}    

=head2 getIP(host)

Performs an DNS-lookup using the ipv4 or ipv6 command and retrieves the address as a string in A/AAAA format.

Input: The host for which the DNS-lookup shall be performed.

Output: The IP in A/AAAA format.

=cut

sub getIP($)
{
    my $host = $_[0];
    my $hostname = &getHostAttribute($host, 'Name');

    if (&getHostAttribute($host, 'Protocol') =~ /4/){
	return getIPV4($hostname);
    } else {
	return getIPV6($hostname);
    }
}

=head2 updateDNSCache(host)

Retrieves a new IP address for the given host and renews the cache using the retrieved address.

Input: The host whose cache is to be updated.

Output: This function does not produce any results.

=cut

sub updateDNSCache($)
{
    my $host = $_[0];
    my $hostname = &getHostAttribute($host, 'Name');

    my $ip = &getIP($host);

    if (defined $ip)
    {
	if (defined($host->{'IP'})) {
	    if (($host->{'IP'}) ne $ip){
		&alarm($host, 'New IP for host $hostname found in DNS');
	    }
	}
	$host->{'IP'} = $ip;
	$host->{'DnsLastChecked'} = time();
    }
}

=head2 queryDNSCache(host)

This function implements the query strategy for retrieving IP addresses. All the key logic of that strategy can be found inside this function. The current strategy can be described as follows:

=over

=item * 

A DNS lookup is always performed, regardless of whether the DNS-cache is on or off. A warning will always be issued when the DNS-lookup fails.

=item * 

If the DNS-Cache is ON the following decision-path is taken:

=over

=item * 

if cached IP and retrieved IP are identical this IP is returned.

=item * 

if cache and DNS-lookup disagree then the alarm function of the host is called and the new DNS entry takes the place of the cached one and is also returned.

=back

=item * 

If the DNS-Cache is OFF the following decision path happens:

=over

=item * 

If an IP has been given in the configuration it will always be prefered over the DNS-lookup. Appropriate warnings will be generated.

=item * 

If no IP is given the lookup-result will be returned.

=back

=back

Input: The host to query an IP for.

Output: An IP for the host or undefined.

=cut

sub queryDNSCache($)
{
    my $host = $_[0];

    my $hostName = &getHostAttribute($host, 'Name');

    &logger("queryDNSCache: $hostName\n", 7);

    my $ip = $host->{'IP'};

    if (&getHostAttribute($host, 'EnableDNSCache') =~ /true/i){
	
	&updateDNSCache($host);
	$ip = $host->{'IP'};

    } else {
	my $checkIP = getIP($host);

	if (defined($ip)){
	    if (defined($checkIP)){
		if ($ip ne $checkIP){
		    &alarm($host, "DNS returns a different IP for $hostName");
		}
	    } else {
		&alarm($host, "DNS failure, but we have an IP cached for $hostName");
	    }
	} else {
	    if (defined($checkIP)){
		$ip = $checkIP;
	    }
	}
    }

    if (!defined($ip))
    {
	# Still no IP? That means we have failed both from cache as from DNS.
	&alarm($host, "DNS lookup failed for $hostName");
	return undef;
    }
    return $ip;
}


=head2 doPing(ip,interval,size,numPings,host,resultsMatter)

This function sends the actual pings.  It relies on the configured ping-tools to do the dirty work.

Input:

=over

=item *

ip = The IP of the host to ping.

=item * 

interval = The interval between individual pings.

=item * 

size = The size of the individual ping packets.

=item * 

numPings = The number of pings of the given size to send.

=item * 

host = The host structure for the IP address to ping. Needed to select IPV4/6 and to route alarm-functionality appropiately.

=item * 

resultsMatter = Since the first ping of each batch is just used to prime the communication-channel this flag can be used to disable the logging of result.

=back

Output: Will return either a list of the results or undefined on failure.

=cut

sub doPing($$$$$$)
{
    my $ip = $_[0];
    my $interval = $_[1];
    my $size = $_[2];
    my $numPings = $_[3];
    my $host = $_[4];
    my $resultsMatter = $_[5];

    my $dest = $host->{'Name'};
    my $time = time;
    my $ping_output = '';
    my $status;
    my ($packetsSent, $packetsRcvd);
    my ($min, $max, $avg);
    my $seqno = [];
    my $pingtimes = [];
    
    my $pingCmd;
    if (&getHostAttribute($host, 'Protocol') =~ /4/)
    {
	$pingCmd = $pingV4Cmd;
    } else {
	$pingCmd = $pingV6Cmd;
    }

    $pingCmd =~ s/%packetsize/$size/;
    $pingCmd =~ s/%interval/$interval/;
    $pingCmd =~ s/%count/$numPings/;
    $pingCmd =~ s/%destination/$ip/;
    my $deadline = $numPings + 20;
    $pingCmd =~ s/%deadline/$deadline/;
    logger("doPing(): Expanded pingCmd resolved to '$pingCmd'\n", 5);

    my $pid = open(PING, "-|");
    if ($pid == 0) {
	open (STDERR, ">&STDOUT") || die "couldn't redirect stderr: $!\n";
	{ 
	    exec $pingCmd;
	}
	# should never be reached
	my $now = `date`;
	die "$now: Ping execution failed for $dest ($ip): $!";
    }

    while (<PING>) {
	$ping_output .= $_;
	
	if (/(\d+) packets transmitted, (\d+)(\s+packets)?\s+received/) {
	    $packetsSent = $1;
	    $packetsRcvd = $2;
	}
	elsif (/(\d+\.?\d*)\/(\d+\.?\d*)\/(\d+\.?\d*)/) {  #look for num/num/num
	    $min = $1;
	    $avg = $2;
	    $max = $3;
	}
	elsif (/seq=(\d+).*time=(\d+\.?\d*) ms/) {
	    # look for seq=NN and time=NN
	    push(@{$seqno}, $1);
	    my $pingtime;
	    ($pingtime = $2) =~ s/\.$//; # delete trailing period, if needed
	    push (@{$pingtimes}, $pingtime); 
	}
    }

    close PING;
    if (not defined $resultsMatter)
    {
	# if close shows ping did not successfully complete and we
	# didn't get any ping results, dump the ping output to STDERR
	if ($? && !defined $packetsSent) {
	    &logger("doPing(): $dest -> Ping failed.\n", 5);
	    &alarm($host, "Ping of '$dest' ($ip) failed with the following output\n<PingOutPut>\n$ping_output</PingOutPut>\n\nThe PingCmd was\n<PingCmd>\n$pingCmd\n</PingCmd>\n");
	    return undef;
	}
	elsif (!defined $packetsSent) {
	    &logger("doPing(): $dest -> Ping produced no output.\n", 5);
	    &alarm($host, "Ping of '$dest' ($ip) produced no output.\nThe PingCmd was\n<PingCmd>\n$pingCmd\n</PingCmd>\n\n");
	    return undef;
	}
	
	if ($packetsRcvd == 0) {
	    &logger("doPing(): $dest -> $packetsSent pings sent but none returned.\n", 5);
	    &alarm($host, "Host '$dest' ($ip) did not answer ping requests.\nThe PingCmd was\n<PingCmd>\n$pingCmd\n</PingCmd>\n\n");
	}

	# return results
	return [$time, $packetsSent, $packetsRcvd, $min, $avg, $max, $seqno, $pingtimes];

    } else {
	return;
    }
}

=head2 log_it(....)

This subroutine logs entries to the ping record file. It opens the file exclusively so that other processes will have to wait until this write is finished.

Input: A huge number of parameters that hold all the statistics that need to be logged (8-15 parameters to be exact).

Output: -1 on error, undefined otherwise.

=cut

sub log_it {
    my ($log_type, $src_name, $src_ip, $dest_name, $dest_ip, $ping_size, $pingResults) = @_;
    my ($time, $packets_sent, $packets_rcvd, $min, $avg, $max, $seqno, $pingtimes) = @{$pingResults};

    # figure out which file to open (of the format ping-YYYY-MM.txt)
    my ($sec, $minutes, $hour, $mday, $month, $year, $wday, $yday, $isdst) = gmtime(time);
    $month++;
    $year += 1900;
    my $ping_data_fn = sprintf "$dataDirectory/ping-%4d-%2.2d\.txt", $year, $month;

    # try to open the file assuming it exists (this will be true most of
    # the time, so we try it first)
    if (!sysopen PINGDATA, $ping_data_fn, O_RDWR | O_EXCL | O_APPEND) {

	# file doesn't exist, so try creating it
	if (!(sysopen(PINGDATA, $ping_data_fn, (O_RDWR | O_EXCL | O_CREAT)))) {

	    # file appeared sometime between the first and second sysopen calls,
	    # try opening it again
	    if (!sysopen PINGDATA, $ping_data_fn, O_RDWR | O_EXCL | O_APPEND){

		print STDERR "Can't open $ping_data_fn: $!\n";
		return -1; # return error code
	    }
	}
    }

    # first format the output string, then print it; avoid overlapping
    # IO with out subprocesses 

    my $output = "$src_name $src_ip $dest_name $dest_ip $ping_size $time $packets_sent $packets_rcvd";

    if ($packets_rcvd > 0) {
	$output .= " $min $avg $max ";
	if($log_type=~/full/) 
	{
	    $output .= join(' ', @{$seqno}) . " " . join(' ', @{$pingtimes});
	}
    }

    print PINGDATA "$output\n";

    close(PINGDATA);
} 


=head2 pingHost(host)

Ping the given host accordingly to the entries given in the configuration file. All calls to doPing are concurrently using a server/client pipe. 

Input: The host to be pinged.

Output: This function does not return any result.

=cut

sub pingHost($){

    logger("pingHost(): Enter.\n", 9);

    my $host = $_[0];

    if (getHostAttribute($host, 'Enabled') =~ /false/)
    {
	return;
    }
    
    my ($packet_loss, $min, $avg, $max, $time);

    # Get time-stamp
    $time = time;

    # Get IP
    my $ip = queryDNSCache($host);

    if (!defined $ip)
    {
	# queryDNSCache takes care of the alarm functionality
	return;
    }

    my $interval = &getHostAttribute($host, 'WaitTime');
    my $logType = &getHostAttribute($host, 'LogType');
    my $name = &getHostAttribute($host, 'Name');

    logger("pingHost(): $name.\n", 0);

    local *CLIENT;
    local *SERVER;

    pipe(SERVER, CLIENT);
    my $Client = *CLIENT;
    my $Server = *SERVER;

    my $pid = fork();

    if (!defined($pid))
    {
	die "FORK FAILED - FATAL ERROR";
    }

    if (!$pid){
	# CLIENT
	close $Server;
	$| = 1;

        # send one ping to prime caches
	&doPing($ip, $interval, 56, 1, $host, 1);
	    
	my $pingInformation = &getHostAttribute($host, 'Ping');
	
	my $ping;
	foreach $ping (@{$pingInformation})
	{
	    my $numPings = &getNumPings($ping);
	    my $packetSize = &getPacketSize($ping);
	    &logger("pingHost(): $name ($ip) -> $numPings Packets of Size $packetSize\n", 2);
	    
	    my $returnValues = &doPing($ip, $interval, $packetSize, $numPings, $host);
	    
	    if (defined $returnValues)
	    {
		&log_it($logType, $srcName, $srcIP, $name, $ip, $packetSize, $returnValues);
	    }
	}
    
	# Before we exit, we pass the updated Host information to the parent
	print $Client XMLout($host, RootName => 'Host', noattr => 1);
	close $Client;
	# Don't forget to exit
	exit; 
    } else {
	# SERVER
	close $Client;
	return ($pid, $Server);
    }
}

=head2 logger(message,logLevel)

Will print the message passed if the set logLevel is high enough to surpass the current setting.

Input: The message and the logLevel.

Output: This function does not return any results.

=cut

sub logger($$)
{
    print $logFile $_[0] if $logLevel > $_[1];
}

=head2 waitForChild(PipeInformation)

Will wait for one child, read the information the child produced and copy the state the child produced into the configuration xml setting.

Input: The list of all processes spawned from the current one.

Output: This function does not produce any results.

=cut

sub waitForChild($)
{
    my $pipes = $_[0];

    # Wait for a child
    my $pid = wait;

    # Get the host we were pinging and the handle to the pipe between the child-process
    my ($host, $handle) = @{$pipes->{$pid}};

    # Read in from pipe
    local ($/);
    undef $/;
    my $data = <$handle>;
    close $handle;
    
    # Read in from the pipe we opened to the child and replace the existing host node
    %{$host} = %{XMLin($data)};
    
    # Remove the process id from the list
    delete $pipes->{$pid};
}

=head2 pingAllHosts()

This function will ping all hosts given in both the host- and the beacon-list.

Input: This function does not expect any parameters.

Output: This function does not return any results.

=cut

sub pingAllHosts(){
    
    logger("pingAllHosts(): Starting to ping all hosts.\n", 3);
    
    my $host;
    my $pipes = {};

    $ProcessCount = 0;

    foreach $host (@{$hostList}, @{$beaconList})
    {
	# Wait for Children
	while ($ProcessCount >= $maxProcessCount) {
	    &waitForChild($pipes);
	    $ProcessCount--;
	}

	# Ping New Child.
	my ($pid, $handle) = pingHost($host);

	# Store Host and Handle
        if(defined($pid) && $pid ne "")
        { 
	    $pipes->{$pid} = [$host, $handle];
        }
        else
        {
            print "process id = $pid\n";
            print "host = ".Dumper($host)." \n";
            print " handle = $handle\n";
        }
$ProcessCount++;
    }

    while ($ProcessCount > 0){
	&waitForChild($pipes);
	$ProcessCount--;
    }
}

#
# Main Program
#
#

srand(time);

$logLevel = 10;
$logFile = *STDOUT;

# Load the Pinger configuration and use Name as a key into the hostlist
$config = XMLin('pinger.xml', ForceArray => ['Ping', 'Host']);

$beaconList = &getList('BeaconList');
$hostList = &getList('HostList');
$defaultHost = $config->{'DefaultHost'};
$dataDirectory = $config->{'DataDirectory'};
    
$pingV4Cmd = $config->{'PingV4Cmd'};
if ($pingV4Cmd =~ /NOT_SUPPORTED/){
    die "PingV4Cmd not supported. Please install ping and generate a new configuration file.\n";
}

$pingV6Cmd = $config->{'PingV6Cmd'};

if ((not defined $pingV6Cmd) || $pingV6Cmd =~ /NOT_SUPPORTED/){
    printf STDERR "PingV6Cmd not supported. IPV6 entries cannot be pinged!\n";
    undef $pingV6Cmd;
}

$dnsV4Cmd = $config->{'dnsV4Cmd'};
if ($dnsV4Cmd =~ /NOT_SUPPORTED/){
    die "DnsV4Cmd not supported. Aborting.\n";
}

$dnsV6Cmd = $config->{'dnsV6Cmd'};
if ((not defined $dnsV6Cmd) || $dnsV6Cmd =~ /NOT_SUPPORTED/){
    printf STDERR "DNSV6Cmd not supported. DNSV6 entries cannot be retrieved!\n";
    undef $dnsV6Cmd;
}

$srcName = $config->{'SrcName'};
$srcIP = $config->{'SrcIP'};

if (not defined($srcIP)){
    $srcIP = getIPV4($srcName);
    if (not defined($srcIP)){
	die "SrcIP could not be determined. Without the results produced by PingER2 are not useable.\n";
    }
}

$ProcessCount = 0;
$maxProcessCount = $config->{'MaxProcessCount'};

&checkDefaultHostConfig($defaultHost);
&checkBeaconConfiguration();

#
# TESTS
#
#&testCheckDefaultHostConfig();
#&testParseTime();
#&testGetIP();

# Save before we start pinging, in case the user breaks the process...
XMLout($config, OutputFile => 'pinger.xml', RootName => 'Pinger', noattr => 1);

$doRandomWait = &retrieveAndCheckForDefault('doRandomWait', 'false');
$waitInterval = &retrieveAndCheckForDefault('waitInterval', '7');

if ($doRandomWait =~ /true/){

    my $wait = rand($waitInterval);    
    print "Going to sleep for $wait minutes.\n";
    sleep(60 * $wait);
} else {
    print "Random wait disabled we are going to start right now.\n";
}
 
&pingAllHosts();
    
# Save afterwards to store new values for the DNS-Cache...
XMLout($config, OutputFile => 'pinger.xml', RootName => 'Pinger', noattr => 1);

# -- Program End

__END__


=head1 COPYRIGHT

PingER2 is based on PingER from SLAC.

2004 - Christopher Ozbek - cozbek@cc.gatech.edu

This is free software. Redistribute and modify under the same license as Perl itself.

=cut

