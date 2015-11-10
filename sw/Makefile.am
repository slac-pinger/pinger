bin_SCRIPTS = pinger2
CLEANFILES = $(bin_SCRIPTS) pinger.xml dnsV4Cmd.pl
pkgdata_DATA = pinger2.pl pinger.xsd pinger.xml dnsV4Cmd.pl beacons.txt installCron.pl
EXTRA_DIST = $(pkgdata_DATA) pinger.xml.default dnsV4Cmd.pl.default installPingerXML.pl

pinger2: pinger2.pl pinger.xml dnsV4Cmd.pl
	rm -f pinger2
	echo "#! " $(BASH) > pinger2
	echo "cd $(pkgdatadir)" >> pinger2
	echo "$(PERL) pinger2.pl" >> pinger2
	chmod ugo+x pinger2

pinger.xml: installPingerXML.pl dnsV4Cmd.pl
	rm -f pinger.xml
	$(PERL) installPingerXML.pl LYNX $(LYNX) PINGV4 $(PINGV4) PINGV6 $(PINGV6) DNSV4 $(pkgdatadir)/dnsV4Cmd.pl DNSV6 $(DIG) SRCNAME `hostname -f` DATADIR $(pkgdatadir)/data MAIL $(MAIL) > pinger.xml

dnsV4Cmd.pl:
	rm -f dnsV4Cmd.pl
	echo "#!"$(PERL) > dnsV4Cmd.pl
	cat dnsV4Cmd.pl.default >> dnsV4Cmd.pl

install-data-local:
	mkdir -p $(pkgdatadir)/data

install-data-hook:
	chmod ugo+x $(pkgdatadir)/installCron.pl
	chmod ugo+x $(pkgdatadir)/dnsV4Cmd.pl

