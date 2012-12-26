from django.contrib import admin
from django.db import models


class ReverseZone(models.Model):

    class Meta:
        db_table = 'reverse_zone'
        app_label = 'dnsapp'

    zone = models.CharField(max_length=255, primary_key=True)
    description = models.CharField(max_length=255)

    def __unicode__(self):
        return self.zone


class ReverseZoneAdmin(admin.ModelAdmin):
    list_display = ('zone', 'description')

admin.site.register(ReverseZone, ReverseZoneAdmin)
