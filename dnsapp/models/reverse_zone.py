import re

from django.contrib import admin
from django.db import models
from django.core.exceptions import ValidationError
from django.core.validators import validate_ipv4_address, RegexValidator

from dnsapp.models.zone import Zone, ZoneAdmin


IP4_ZONE_SUFFIX = '.in-addr.arpa'

# /8, /16 or /24 prefix
ip4_prefix_re = re.compile(r'^(25[0-5]|2[0-4]\d|[0-1]?\d?\d\.){1,3}$')
validate_ip4_prefix = RegexValidator(
    ip4_prefix_re, message=u"Enter a valid IPv4 prefix")


def ip_or_none(ip):
    """Return IP address if it is valide, None otherwise"""
    try:
        validate_ipv4_address(ip)
        return ip
    except ValidationError:
        return None


def ptr2ip(ptrdns):
    """Transform a PTR name to an IP or an IP prefix

    return None if the given name is invalid
    """
    ptrdns = ptrdns.rstrip('.')
    if not ptrdns.endswith(IP4_ZONE_SUFFIX):
        return None
    nums = ptrdns[0:-len(IP4_ZONE_SUFFIX)].split('.')
    if len(nums) == 0 or len(nums) > 4:
        return None
    ip_parts = []
    try:
        for n in nums:
            if int(n) < 0 or int(n) > 255:
                return None
            ip_parts.insert(0, n)
    except ValueError:
        return None
    if len(ip_parts) < 4:
        ip_parts.append('')
    return '.'.join(ip_parts)


def ip2ptr(ip):
    """Transform an IP or an IP prefix to a PTR zone

    return None if the given IP is invalid"""
    nums = ip.rstrip('.').split('.')
    if len(nums) == 0 or len(nums) > 4:
        return None
    ptr_parts = []
    try:
        for n in nums:
            if int(n) < 0 or int(n) > 255:
                return None
            ptr_parts.insert(0, n)
    except ValueError:
        return None
    return '.'.join(ptr_parts) + IP4_ZONE_SUFFIX


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


class ReverseZone(Zone):
    """A reverse zone is a zone with an IP prefix"""

    class Meta:
        db_table = 'reverse_zone'
        app_label = 'dnsapp'

    ip_prefix = models.CharField(max_length=16, unique=True,
                                 blank=True, editable=False,
                                 validators=[validate_ip4_prefix])
    ip_prefix.help_text = "Prefix of IP addresses in this zone"

    objects = ReverseZoneManager()

    def host2ip(self, host):
        """Get IP address for the given reversed host name

        Return None if the result is not a valid IP address
        """
        nums = host.split('.')
        nums.reverse()
        return ip_or_none(self.ip_prefix + '.'.join(nums))

    def ip2host(self, ip):
        """Get reverse host name from an IP address, or None"""
        if not ip.startswith(self.ip_prefix) or not ip_or_none(ip):
            return None
        nums = ip[len(self.ip_prefix):].split('.')
        nums.reverse()
        return '.'.join(nums)

    def clean(self):
        # Zone is given, compute corresponding IP prefix
        if not self.zone:
            raise ValidationError("Empty zone")
        zone_ip = ptr2ip(self.zone)
        if zone_ip is None:
            raise ValidationError("Invalid zone name for a reverse")
        # Update IP prefix, as it is not directly editable
        self.ip_prefix = zone_ip
        super(ReverseZone, self).clean()


class ReverseZoneAdmin(admin.ModelAdmin):
    list_display = ('ip_prefix', ) + ZoneAdmin.list_display

admin.site.register(ReverseZone, ReverseZoneAdmin)
