man_MANS = pinger2.1
pkgdata_DATA = pinger2.html
EXTRA_DIST = $(man_MANS) $(pkgdata_DATA)

pinger2.html:
	rm -f pinger2.html
	pod2html ../sw/pinger2.pl > pinger2.html

pinger2.1:
	rm -f pinger2.1
	pod2man ../sw/pinger2.pl > pinger2.1