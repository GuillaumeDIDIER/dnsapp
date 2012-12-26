from django.contrib import admin
from django.db import models

from dnsapp.models.dns_record import DNSRecord
from dnsapp.models.reverse_zone import ReverseZone


class DNSARecord(DNSRecord):

    class Meta:
        db_table = 'dns_a'
        app_label = 'dnsapp'
        unique_together = (('host', 'zone'), ('rev_host', 'rev_zone'))

    host = models.CharField(max_length=100)
    host.help_text = "Host name within its zone"

    ip = models.CharField(max_length=16)
    ip.help_text = "IP address"

    rev_host = models.CharField(max_length=16)
    rev_host.help_text = "Reverse host name, IP suffix numbers (reverse order)"

    rev_zone = models.ForeignKey(ReverseZone)
    rev_zone.help_text = "Reverse zone"

    def __unicode__(self):
        return u"A %s.%s" % (self.host, str(self.zone))


class DNSARecordAdmin(admin.ModelAdmin):
    list_display = ('host', 'zone', 'ip', 'rev_zone')

admin.site.register(DNSARecord, DNSARecordAdmin)
