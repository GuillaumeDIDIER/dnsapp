from django.contrib import admin
from django.db import models
from django.core.exceptions import ValidationError

from dnsapp.models.name_server import validate_domain_name
from dnsapp.models.dns_record import DNSRecord
from dnsapp.models.reverse_zone import ReverseZone, ip_or_none


class DNSARecord(DNSRecord):

    class Meta:
        db_table = 'dns_a'
        app_label = 'dnsapp'
        unique_together = (('host', 'zone'), ('rev_host', 'rev_zone'))

    host = models.CharField(max_length=100, validators=[validate_domain_name])
    host.help_text = "Host name within its zone"

    ip = models.IPAddressField(blank=True)
    ip.help_text = "IP address"

    rev_host = models.CharField(max_length=16, blank=True)
    rev_host.help_text = "Reverse host name, IP suffix numbers (reverse order)"

    rev_zone = models.ForeignKey(ReverseZone, related_name='rev_zone')
    rev_zone.help_text = "Reverse zone"

    def __unicode__(self):
        return u"A %s.%s" % (self.host, str(self.zone))

    def clean(self):
        # Here, rev_zone should have been filled
        # and either ip or rev_host (or both) filled
        if self.rev_host:
            # Compute IP from reverse information
            newip = None
            try:
                newip = self.rev_zone.host2ip(self.rev_host)
            except:
                pass
            if newip is None:
                raise ValidationError("Invalid reverse host record")

            # Compare computed IP with self.ip
            if not self.ip:
                self.ip = newip
            elif self.ip != newip:
                raise ValidationError("IP address doesn't match reverse host")
        elif ip_or_none(self.ip) is not None:
            # Find reverse information from IP address
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
            if rev_zone is None:
                raise ValidationError(
                    "IP address doesn't belong to any reverse zone")

            self.rev_host = self.rev_zone.ip2host(self.ip)
            if not self.rev_host:
                raise ValidationError(
                    "IP address does not belong to the reverse zone")
        else:
            raise ValidationError("No valid IP address given")


class DNSARecordAdmin(admin.ModelAdmin):
    list_display = ('host', 'zone', 'ip', 'rev_zone')

admin.site.register(DNSARecord, DNSARecordAdmin)
