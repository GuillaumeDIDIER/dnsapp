from django.contrib import admin
from django.db import models


class Zone(models.Model):

    class Meta:
        db_table = 'zone'
        app_label = 'dnsapp'

    zone = models.CharField(max_length=255, primary_key=True)
    description = models.CharField(max_length=255)

    def __unicode__(self):
        return self.zone


class ZoneAdmin(admin.ModelAdmin):
    list_display = ('zone', 'description')

admin.site.register(Zone, ZoneAdmin)
