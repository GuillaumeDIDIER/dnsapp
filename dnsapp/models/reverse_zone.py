from django.contrib import admin
from django.db import models
from zone import Zone


class ReverseZone(models.Model):
    """A reverse zone is a zone with an IP prefix"""

    class Meta:
        db_table = 'reverse_zone'
        app_label = 'dnsapp'

    zone = models.OneToOneField(Zone, unique=True)
    zone.help_text = "Corresponding zone"

    ip_prefix = models.CharField(max_length=16, primary_key=True)
    ip_prefix.help_text = "Prefix of IP addresses in this zone"

    def __unicode__(self):
        return self.ip_prefix


class ReverseZoneAdmin(admin.ModelAdmin):
    list_display = ('zone', 'ip_prefix')

admin.site.register(ReverseZone, ReverseZoneAdmin)
