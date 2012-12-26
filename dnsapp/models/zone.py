from django.contrib import admin
from django.db import models

from dnsapp.models.name_server import NameServer


class Zone(models.Model):

    # Default refresh time is one week
    DEFAULT_REFRESH = 604800
    # Default retry time is one day
    DEFAULT_RETRY = 86400
    # Default retry time is one month (4 weeks)
    DEFAULT_EXPIRE = 2419200
    # Default minimum time is one hour
    DEFAULT_MINIMUM = 3600

    class Meta:
        db_table = 'zone'
        app_label = 'dnsapp'

    zone = models.CharField(max_length=255, primary_key=True)
    zone.help_text = "Zone DNS suffix"

    description = models.CharField(max_length=255)
    description.help_text = "Zone human-readable description"

    soa_primary_ns = models.ForeignKey(NameServer, related_name='primary_ns')
    soa_primary_ns.help_text = "Primary name server for SOA record"

    soa_resp_person = models.CharField(max_length=255)
    soa_resp_person.help_text = "Responsible person for SOA record"

    soa_serial = models.IntegerField()
    soa_serial.help_text = "Serial number for SOA record"

    soa_refresh = models.IntegerField(default=DEFAULT_REFRESH)
    soa_refresh.help_text = "Refresh time for SOA record"

    soa_retry = models.IntegerField(default=DEFAULT_RETRY)
    soa_retry.help_text = "Retry time for SOA record"

    soa_expire = models.IntegerField(default=DEFAULT_EXPIRE)
    soa_expire.help_text = "Expire time for SOA record"

    soa_minimum = models.IntegerField(default=DEFAULT_MINIMUM)
    soa_minimum.help_text = "Minimum time (TTL) for SOA record"

    nameservers = models.ManyToManyField(NameServer, related_name='ns')
    nameservers.help_text = "NS records"

    def __unicode__(self):
        return self.zone


class ZoneAdmin(admin.ModelAdmin):
    list_display = ('zone', 'description', 'soa_serial')

admin.site.register(Zone, ZoneAdmin)
