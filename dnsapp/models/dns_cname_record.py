from django.contrib import admin
from django.db import models

from dnsapp.models.zone import Zone


class DNSCNAMERecord(models.Model):
    DEFAULT_TTL = 3200

    class Meta:
        db_table = 'dns_cname'
        app_label = 'dnsapp'
        unique_together = ('host', 'zone')

    host = models.CharField(max_length=100)
    host.help_text = "Host name within its zone"

    zone = models.ForeignKey(Zone)
    zone.help_text = "Zone which owns the record"

    ttl = models.PositiveIntegerField(default=DEFAULT_TTL)
    ttl.help_text = "Time to live"

    data = models.CharField(max_length=255)
    data.help_text = "Host name / Full domain name"

    def __unicode__(self):
        return u"CNAME %s.%s" % (self.host, str(self.zone))


class DNSCNAMERecordAdmin(admin.ModelAdmin):
    list_display = ('host', 'zone', 'data')

admin.site.register(DNSCNAMERecord, DNSCNAMERecordAdmin)
