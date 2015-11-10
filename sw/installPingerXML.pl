#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

=head1 NAME 

InstallPingerXML - Your humble pinger.xml preprocessor

=head1 SYNOPSIS

This little script generates the configuration file pinger.xml from an existing pinger.xml.default depending on the current platform. 

=head1 DESCRIPTION

The script should get passed the parameters in pairs of TAG and REPLACEMENT.

The special tag OS can be used to override perls build-in mechanism to figure out which platform 
the system is running. Please be aware that this special tag only effects following pair of TAG 
and REPLACEMENT.

Usually this script does not need to be called by the user but rather will be invoked during 
the install process triggered by the automake scripts.

If you want to skip the use of this script completely please consult the documentation generated from
pinger2.pl to learn more about how the different placeholders in pinger.xml.default need to be replaced.
After having edited the default configuration file successfully save the file under the name pinger.xml.

Example call (partial replacement):

    ./installPingerXML.pl OS linux PINGV4 /bin/ping PINGV6 /bin/ping6
    
Example call (all tags replaced):

    ./installPingerXML.pl PINGV4 /bin/ping PINGV6 /bin/ping6 LYNX /usr/bin/lynx DNSV4 `pwd`/dnsV4Cmd.pl DNSV6 /usr/bin/dig \
                          SRCNAME helsinki.cc.gatech.edu DATADIR `pwd`/data MAIL /bin/mail

By piping the output of this script into a new pinger.xml a fresh configuration file with all the requirements fullfilled can be created.

=head1 TAGS

=over

=item PINGV4, PINGV6

Path to the ping utility for ipv4, ipv6

Example:

    PINGV4 /bin/ping

=item DNSV4, DNSV6

Path to the utility used to resolve ipv4, ipv6 addresses

Example:

    DNSV6 /usr/bin/dig

=item LYNX

Path to lynx, which is used to get the beacons.txt file from the web.

Example:

    LYNX /usr/bin/lynx

=item DATADIR

Path in which PingER should store all its results. Usually a subfolder of the pinger distribution. Be aware that this folder should in general be accessible for the scripts running under Apache, so results can be published.

Example:

    DATADIR /home/pinger/data

=item SRCNAME

This should be the fully qualified hostname of the machine that PingER2 is running on. This name will be used to resolve the source IP from. Please make sure that this entry is accurate since it could mislead the data-analysis otherwise.

Example:

    SRCNAME myhost.gatech.edu

=item MAIL

Path to the unix mail tool, which is used to send alarms to the PingER's administrator in case of failures.

Example:
    
    MAIL /bin/mail

=back

=cut

my $arch = {
    'linux' => {
	'PINGV4' => 'PINGV4 -n -w %deadline -c %count -i %interval -s %packetsize',
	'PINGV6' => 'PINGV6 -n -w %deadline -c %count -i %interval -s %packetsize',
	'DNSV6' => 'DNSV6 -t aaaa +short',
	'LYNX' => 'LYNX -source -dump'
    }
};

my $os = $^O;

if (scalar(@ARGV) < 2){
    die "\n".
	"Not enough parameters!\n".
        "\n".
	"Usage:\n". 
        "   ./installPingerXML.pl (TAG REPLACMENT)+\n".
	"\n".
	"Example call:\n".
	"   ./installPingerXML.pl OS linux PINGV4 /bin/ping PINGV6 /bin/ping6\n".
	"\n";

}

open(HANDLE, "pinger.xml.default");

undef $/;

my $conf = <HANDLE>;

while (scalar(@ARGV) >= 2) {
    my $tag = shift @ARGV;
    my $replace = shift @ARGV;

    my $newtag;

    if (defined $arch->{$os}){
	$newtag = $arch->{$os}->{$tag};
    }

    if (not defined $newtag){
	$newtag = $tag;
    }

    $newtag =~ s/$tag/$replace/;

    $conf =~ s/\$\$\$\$ $tag \$\$\$\$/$newtag/;
}

print $conf;

__END__

=head1 COPYRIGHT

2004 - Micah Wedemeyer & Christopher Ozbek - {micah,cozbek}@cc.gatech.edu

This is free software. Redistribute and modify under the same license as Perl itself.

=cut

