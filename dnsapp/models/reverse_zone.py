from django.contrib import admin
from django.db import models
from dnsapp.models.zone import Zone
from dnsapp.models import ip_address


class ReverseZoneManager(models.Manager):
    """Provide some functions to use IP addresses"""

    def get_by_ip(self, ip):
        """Get the best reverse zone which matches this IP address

        Return ReverseZone instance
        """
        nums = ip.split('.')
        if len(nums) != 4:
            raise self.model.DoesNotExist("Invalid IP address")
        ip_prefixes = (
            '%d.' % int(nums[0]),
            '%d.%d.' % (int(nums[0]), int(nums[1])),
            '%d.%d.%d.' % (int(nums[0]), int(nums[1]), int(nums[2])),
            )
        return self.filter(ip_prefix__in=ip_prefixes).get()


class ReverseZone(models.Model):
    """A reverse zone is a zone with an IP prefix"""

    class Meta:
        db_table = 'reverse_zone'
        app_label = 'dnsapp'

    zone = models.OneToOneField(Zone, unique=True)
    zone.help_text = "Corresponding zone"

    ip_prefix = models.CharField(max_length=16, primary_key=True)
    ip_prefix.help_text = "Prefix of IP addresses in this zone"

    objects = ReverseZoneManager()

    def __unicode__(self):
        return self.ip_prefix

    def host2ip(self, host):
        """Get IP address for the given reversed host name

        Return None if the result is not a valid IP address
        """
        nums = host.split('.')
        nums.reverse()
        ip = self.ip_prefix + '.'.join(nums)
        return ip if ip_address.is_ipv4(ip) else None

    def ip2host(self, ip):
        """Get reverse host name from an IP address, or None"""
        if not ip.startswith(self.ip_prefix) or not ip_address.is_ipv4(ip):
            return None
        nums = ip[len(self.ip_prefix):].split('.')
        nums.reverse()
        return '.'.join(nums)


class ReverseZoneAdmin(admin.ModelAdmin):
    list_display = ('zone', 'ip_prefix')

admin.site.register(ReverseZone, ReverseZoneAdmin)
