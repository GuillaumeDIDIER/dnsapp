from django.db import models

from dnsapp.models.zone import Zone


class DNSRecord(models.Model):
    """Abstract model for DNS records"""
    DEFAULT_TTL = 3200

    class Meta:
        abstract = True

    zone = models.ForeignKey(Zone)
    zone.help_text = "Zone which owns the record"

    ttl = models.PositiveIntegerField(default=DEFAULT_TTL)
    ttl.help_text = "Time to live"
