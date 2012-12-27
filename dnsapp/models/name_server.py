import re

from django.contrib import admin
from django.db import models
from django.core.validators import RegexValidator


# Regexp for domain names
# Adapted from django.core.validators.URLValidator
domain_name_re = re.compile(
    r'^(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)*'
    r'(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?)\.?$', re.IGNORECASE)
validate_domain_name = RegexValidator(
    domain_name_re, message=u"Enter a valid Domain Name")

# A FQDN always has a trailing period
fqdn_re = re.compile(
    r'^(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+$', re.IGNORECASE)
validate_fqdn = RegexValidator(
    fqdn_re, message=u"Enter a valid Fully Qualified Domain Name")

# A zone does not have a trailing period
zone_re = re.compile(
    r'^(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+'
    r'(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?)$', re.IGNORECASE)
validate_zone = RegexValidator(
    zone_re,
    message=u"Enter a valid Domain Zone Name (without trailing period)")


class NameServer(models.Model):

    class Meta:
        db_table = 'nameserver'
        app_label = 'dnsapp'

    host = models.CharField(max_length=255, primary_key=True,
                            validators=[validate_fqdn])
    host.help_text = "DNS of a nameserver"

    def __unicode__(self):
        return self.host

admin.site.register(NameServer)
