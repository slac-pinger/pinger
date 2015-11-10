SUBDIRS = sw docs
EXTRA_DIST = testPrereqs.pl

req_missing=" not installed, see README ----"
err_tag=NOT_SUPPORTED
test_prereqs:
	@if [ "$(PERL)" = "$(err_tag)" ]; then \
		echo "---- perl MUST be installed before continuing"; \
		exit 1; \
	fi; \
	if [ "$(PINGV4)" = "$(err_tag)" ]; then \
		echo "---- ping for IPv4$(req_missing)"; \
	fi; \
	if [ "$(PINGV6)" = "$(err_tag)" ]; then \
		echo "---- ping for IPv6$(req_missing)"; \
	fi; \
	if [ "$(LYNX)" = "$(err_tag)" ]; then \
		echo "---- lynx$(req_missing)"; \
	fi; \
	if [ "$(DIG)" = "$(err_tag)" ]; then \
		echo "---- dig$(req_missing)"; \
	fi; \
	if [ "$(MAIL)" = "$(err_tag)" ]; then \
		echo "---- mail$(req_missing)"; \
	fi; \
	$(PERL) testPrereqs.pl

install_cron:
	$(BASH) -c "cd $(pkgdatadir); $(PERL) installCron.pl"