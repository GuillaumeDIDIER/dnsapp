from django.contrib import admin
from django.db import models

from dnsapp.models.zone import Zone


class DNSMXRecord(models.Model):
    DEFAULT_TTL = 3200

    class Meta:
        db_table = 'dns_mx'
        app_label = 'dnsapp'
        unique_together = ('zone', 'data')

    zone = models.ForeignKey(Zone)
    zone.help_text = "Zone which owns the record"

    ttl = models.PositiveIntegerField(default=DEFAULT_TTL)
    ttl.help_text = "Time to live"

    mx_priority = models.PositiveIntegerField(null=True)
    mx_priority.help_text = "MX priority"

    # Note: this field is NOT host, as it is the answer and not the query
    data = models.CharField(max_length=255)
    data.help_text = "IP address / Host name / Full domain name"

    def __unicode__(self):
        return u"MX %s for %s" % (self.data, str(self.zone))


class DNSMXRecordAdmin(admin.ModelAdmin):
    list_display = ('data', 'zone', 'mx_priority')

admin.site.register(DNSMXRecord, DNSMXRecordAdmin)