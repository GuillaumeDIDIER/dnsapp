import datetime
from django.contrib import admin
from django.db import models

from dnsapp.models.name_server import NameServer


def serial2tuple(serial):
    """Convert a serial (integer in YYYYMMDDNN format) to a (Y,M,D,N) tuple

    YYYY = year
    MM = month
    DD = day
    NN = number in the day
    """
    y = serial / 1000000
    m = (serial / 10000) % 100
    d = (serial / 100) % 100
    n = serial % 100
    return (y, m, d, n)


def tuple2serial(y, m, d, n):
    """Give the serial from a 4-tuple"""
    return ((y * 100 + m) * 100 + d) * 100 + n


def get_today_serial():
    """Get the serial of the day"""
    date = datetime.date.today()
    return tuple2serial(date.year, date.month, date.day, 0)


def increment_serial(serial=None):
    """Increment a serial number, setting it do today's date if possible"""
    new_serial = get_today_serial()
    return serial + 1 if serial and serial >= new_serial else new_serial


class Zone(models.Model):

    # Default serial is today
    DEFAULT_SERIAL = get_today_serial()
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

    soa_serial = models.PositiveIntegerField(default=DEFAULT_SERIAL)
    soa_serial.help_text = "Serial number for SOA record"

    soa_refresh = models.PositiveIntegerField(default=DEFAULT_REFRESH)
    soa_refresh.help_text = "Refresh time for SOA record"

    soa_retry = models.PositiveIntegerField(default=DEFAULT_RETRY)
    soa_retry.help_text = "Retry time for SOA record"

    soa_expire = models.PositiveIntegerField(default=DEFAULT_EXPIRE)
    soa_expire.help_text = "Expire time for SOA record"

    soa_minimum = models.PositiveIntegerField(default=DEFAULT_MINIMUM)
    soa_minimum.help_text = "Minimum time (TTL) for SOA record"

    nameservers = models.ManyToManyField(NameServer, related_name='ns')
    nameservers.help_text = "NS records"

    def __unicode__(self):
        return self.zone

    def update_serial(self):
        """Update serial number"""
        self.soa_serial = increment_serial(self.soa_serial)


class ZoneAdmin(admin.ModelAdmin):
    list_display = ('zone', 'description', 'soa_serial')

admin.site.register(Zone, ZoneAdmin)
