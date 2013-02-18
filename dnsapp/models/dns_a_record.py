from django.contrib import admin
from django.db import models
from django.core.exceptions import ValidationError

from dnsapp.models.name_server import validate_host_name
from dnsapp.models.dns_record import DNSRecord
from dnsapp.models.reverse_zone import ReverseZone, ip_or_none


class DNSARecord(DNSRecord):

    class Meta:
        db_table = 'dns_a'
        app_label = 'dnsapp'
        unique_together = (('host', 'zone'), ('rev_host', 'rev_zone'))

    host = models.CharField(max_length=100, validators=[validate_host_name])
    host.help_text = "Host name within its zone"

    ip = models.IPAddressField(blank=True)
    ip.help_text = "IP address"

    rev_host = models.CharField(max_length=16, blank=True)
    rev_host.help_text = "Reverse host name, IP suffix numbers (reverse order)"

    rev_zone = models.ForeignKey(ReverseZone, related_name='rev_zone')
    rev_zone.help_text = "Reverse zone"

    def __unicode__(self):
        return u"A %s" % self.domain_name

    @property
    def domain_name(self):
        """Full domain name"""
        return '%s.%s' % (self.host, str(self.zone))

    def fill_missing(self):
        """Fill as much fields as possible with other ones

        Only one of ip and rev_host fields needs to be filled
        """
        # Find reverse zone from IP address
        rev_zone = None
        try:
            rev_zone = self.rev_zone
        except ReverseZone.DoesNotExist:
            # No reverse zone supplied, find one
            try:
                rev_zone = ReverseZone.objects.get_by_ip(self.ip)
                self.rev_zone = rev_zone
            except:
                pass

        # Can't do anything without reverse zone
        if rev_zone is None:
            return

        if self.rev_host and not self.ip:
            # Compute IP from reverse information
            self.ip = rev_zone.host2ip(self.rev_host)
        elif not self.rev_host:
            # Compute reverse host from IP address
            self.rev_host = rev_zone.ip2host(self.ip)

    def clean(self):
        # Here, rev_zone should have been filled
        # and either ip or rev_host (or both) filled
        self.fill_missing()
        # Find reverse zone from IP address
        rev_zone = None
        try:
            rev_zone = self.rev_zone
        except ReverseZone.DoesNotExist:
            # No reverse zone supplied and fillmissing() failed to find one
            raise ValidationError(
                "IP address doesn't belong to any reverse zone")

        if self.rev_host:
            # Compute IP from reverse information
            newip = rev_zone.host2ip(self.rev_host)
            if newip is None:
                raise ValidationError("Invalid reverse host record")

            # Compare computed IP with self.ip
            elif self.ip != newip:
                raise ValidationError("IP address doesn't match reverse host")
        elif ip_or_none(self.ip) is not None:
            # Here (not self.rev_host) is True after self.fillmissing()
            # but self.ip is a valid IP address
            # That means rev_zone.ip2host(self.ip) is None
            raise ValidationError(
                "IP address does not belong to the reverse zone")
        else:
            raise ValidationError("No valid IP address given")


class DNSARecordAdmin(admin.ModelAdmin):
    list_display = ('host', 'zone', 'ip', 'rev_zone')

admin.site.register(DNSARecord, DNSARecordAdmin)
