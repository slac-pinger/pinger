#!/usr/bin/perl

=head1 NAME

installCron - Your humble cron installer

=head1 SYNOPSIS

This little script will install an appropiate cron entry for PingER2 into the crontab of the current user (or replace an existing entry).

=head1 DESCRIPTION

This script should be invoked whenever the tag <waitInterval> has changed inside the pinger.xml configuration file. To update the associated crontab installCron.pl will retrieve the current crontab using 'crontag -l', erase the first 3 lines of comments and all the lines containing references to pinger2.pl and will append itself to the bottom of the new crontab.

Warning: This script needs to be run from the same location as the pinger2.pl perl-script.

This script should be called initially by the install process of PingER2. 

Example invocation.

    ./installCron.pl

=head1 SEE ALSO

The documentation for PingER2 (pinger2.html) explains the file format of pinger.xml and can give more detailed information on the effects caused by <waitInterval>.

=cut

use XML::Simple;
# use Data::Dumper;
use warnings;
use strict;
use Fcntl; 

# Load the Pinger configuration and use Name as a key into the hostlist
my $config = XMLin('pinger.xml', ForceArray => ['Ping', 'Host']);

sub parseTimeInMinutes(%){
    my $string = $_[0];
    $string =~ /\D*(\d*)\D*/;
    my $number = $1;
    
    if (!$number)
    {
	return -1;
    }
    
    if ($string =~ /mo/i)
    {
	return $number * 60 * 24 * 30;
    }

    if ($string =~ /h/i)
    {
	return $number * 60;
    }

    if ($string =~ /d/i)
    {
	return $number * 60 * 24;
    }

    if ($string =~ /w/i)
    {
	return $number * 60 * 24 * 7;
    }
    
    if ($string =~ /y/i)
    {
	return $number * 60 * 24 * 365;
    }
    return $number;
}

sub printCronTimeInfo(%%){
    my $timeInMinutes = $_[0];
    my $name = $_[1];
    if ($timeInMinutes == 1){
	print("Setting Cron Interval to: once every " . "$name" . "\n");
    } 
    else
    {
	print("Setting Cron Interval to: once every $timeInMinutes " . "$name" . "s\n");
    }
}

sub getCronStars(%){
    my $timeInMinutes = $_[0];
    
    if ($timeInMinutes < 5) {
 	print("!! Warning !! Setting the interval between PingER2 runs under 5 minutes might\n" .
              "              not be enough for one run to finish before the next starts.\n" .
              "              The recommended setting is 30 minutes at least.\n");
    }

    if ($timeInMinutes < 60) {
	printCronTimeInfo($timeInMinutes, "minute");
	return "*/$timeInMinutes * * * * ";
    }

    $timeInMinutes = $timeInMinutes / 60;

    if ($timeInMinutes < 24){
	printCronTimeInfo($timeInMinutes, "hour");
	return "* */$timeInMinutes * * * ";
    }

    $timeInMinutes = $timeInMinutes / 24;

    if ($timeInMinutes < 30){
	printCronTimeInfo($timeInMinutes, "day");
	return "* * */$timeInMinutes * * ";
    }

    $timeInMinutes = $timeInMinutes / 30;

    if ($timeInMinutes < 12){
	printCronTimeInfo($timeInMinutes, "month");
	return "* * * */$timeInMinutes * ";
    }

    die "!! FATAL !! Cron and Pinger do not support longer intervals than once every 12 months." . 
        "            Plase adjust <waitInterval> in pinger.xml\n" . 
	"            The recommended setting is 30 minutes.\n";
}

#
# MAIN PROGRAM
#

# Retrieve configuration from xml file
my $waitInterval = $config->{'waitInterval'};

if (not defined $waitInterval){
    print("\n" .
	  "!! Warning !! The interval between PingER2 runs has not been set.\n" .
	  "              Plase adjust <waitInterval> in pinger.xml\n" . 
	  "              The recommended setting is 30 minutes.\n" . 
	  "\n");
    $waitInterval = "5";
}

# Convert configuration to a cron time parameter "cronStars"
my $cronStars = &getCronStars(parseTimeInMinutes($waitInterval));

# Get our own location
my $whereAmI = `pwd`;
chomp($whereAmI);

my $newCrontabContents = "";
my $commentsToKill = 3;

# Retrieve previous crontab entry
my $crontabContents = `crontab -l`; # *** TODO *** What to do if crontab is not there???

print "\nOld Crontab-Content\n\n" . $crontabContents . "\n";

# Kill all previous pinger2.entries and remove the first 3 comment lines
my @lines = split(/\n/, $crontabContents);

my $line;
for $line (@lines){

    if (($line =~ /^\#/) && ($commentsToKill > 0)){
	$commentsToKill--;
	next;
    } else {
	$commentsToKill = 0;
    }
    
    $newCrontabContents .= $line . "\n" if not $line =~ /pinger2.pl/;
}

$newCrontabContents .= $cronStars . "cd $whereAmI; perl $whereAmI" . "/pinger2.pl > " . "$whereAmI" . "/pingerCronStat.stdout 2> " . "$whereAmI" . "/pingerCronStat.stderr\n";

print "New Crontab-Content\n\n" . $newCrontabContents . "\n";

# add error processing as above
my $pid = open(KID_TO_WRITE, "|-");

if (not defined $pid){
    die("Forking to execute crontab failed!!");
}

$SIG{ALRM} = sub { die "Could not execute crontab!" };

if ($pid) {  # parent
    
    print KID_TO_WRITE $newCrontabContents;
    close(KID_TO_WRITE) || warn "kid exited $?";
    
} else {     # child
    exec("crontab") || die "Could not execute crontab: $!";
    # The programm will never get here, or should not at least
} 

print "Crontab successfully updated!!\nWe are done here exiting...\n" 

__END__

=head1 COPYRIGHT

2004 - Charles Pippin & Christopher Ozbek - {cepipping,cozbek}@cc.gatech.edu

This is free software. Redistribute and modify under the same license as Perl itself.

=cut


