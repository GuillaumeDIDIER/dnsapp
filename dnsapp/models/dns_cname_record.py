from django.contrib import admin
from django.db import models

from dnsapp.models.dns_record import DNSRecord
from dnsapp.models.name_server import validate_domain_name


class DNSCNAMERecord(DNSRecord):

    class Meta:
        db_table = 'dns_cname'
        app_label = 'dnsapp'
        unique_together = ('host', 'zone')

    host = models.CharField(max_length=100, validators=[validate_domain_name])
    host.help_text = "Host name within its zone"

    data = models.CharField(max_length=255, validators=[validate_domain_name])
    data.help_text = "Host name / Full domain name"

    def __unicode__(self):
        return u"CNAME %s.%s" % (self.host, str(self.zone))


class DNSCNAMERecordAdmin(admin.ModelAdmin):
    list_display = ('host', 'zone', 'data')

admin.site.register(DNSCNAMERecord, DNSCNAMERecordAdmin)
