from django.contrib import admin
from django.db import models


class NameServer(models.Model):

    class Meta:
        db_table = 'nameserver'
        app_label = 'dnsapp'

    host = models.CharField(max_length=255, primary_key=True)
    host.help_text = "DNS of a nameserver"

    def __unicode__(self):
        return self.host

admin.site.register(NameServer)
