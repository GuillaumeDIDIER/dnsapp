from django.contrib import admin
from django.db import models

from dnsapp.models.zone import Zone


class DNSRecord(models.Model):
    RTYPES = (
        'A',
        'CNAME',
        'MX',
        'SOA',
        'NS',
    )
    DEFAULT_TTL = 3200
    PROTECTED_NAMES = (
        r'root',
    )

    class Meta:
        db_table = 'dns'
        app_label = 'dnsapp'
    ttl = models.IntegerField(default=DEFAULT_TTL)
    host = models.CharField(max_length=100)
    zone = models.ForeignKey(Zone)
    rtype = models.CharField(max_length=5, choices=zip(RTYPES, RTYPES))
    data = models.CharField(max_length=255)

    def __unicode__(self):
        return u"%s %s.%s" % (self.rtype, self.host, str(self.zone))


class DNSRecordAdmin(admin.ModelAdmin):
    list_display = ('host', 'zone', 'rtype', 'data')

admin.site.register(DNSRecord, DNSRecordAdmin)
