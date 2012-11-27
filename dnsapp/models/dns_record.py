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
    rid = models.IntegerField(primary_key=True)
    ttl = models.IntegerField(default=DEFAULT_TTL)
    host = models.CharField(max_length=100)
    zone = models.ForeignKey(Zone)
    rtype = models.CharField(max_length=5, choices=zip(RTYPES, RTYPES))
    data = models.CharField(max_length=255)

admin.site.register(DNSRecord)
