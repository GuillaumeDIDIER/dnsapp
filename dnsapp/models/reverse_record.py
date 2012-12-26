from django.contrib import admin
from django.db import models

from dnsapp.models.reverse_zone import ReverseZone


class ReverseRecord(models.Model):
    RTYPES = (
        'PTR',
        'SOA',
        'NS',
    )
    DEFAULT_TTL = 3200

    class Meta:
        db_table = 'reverse_dns'
        app_label = 'dnsapp'
    ttl = models.IntegerField(default=DEFAULT_TTL)
    host = models.CharField(max_length=100)
    zone = models.ForeignKey(ReverseZone)
    rtype = models.CharField(max_length=5, choices=zip(RTYPES, RTYPES))
    data = models.CharField(max_length=255)

    def __unicode__(self):
        return u"%s %s.%s" % (self.rtype, self.host, str(self.zone))


class ReverseRecordAdmin(admin.ModelAdmin):
    list_display = ('host', 'zone', 'rtype', 'data')

admin.site.register(ReverseRecord, ReverseRecordAdmin)
