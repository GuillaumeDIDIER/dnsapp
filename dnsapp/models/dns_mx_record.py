from django.contrib import admin
from django.db import models

from dnsapp.models.dns_record import DNSRecord
from dnsapp.models.name_server import validate_domain_name


class DNSMXRecord(DNSRecord):

    class Meta:
        db_table = 'dns_mx'
        app_label = 'dnsapp'
        unique_together = ('zone', 'data')

    mx_priority = models.PositiveIntegerField(null=True)
    mx_priority.verbose_name = "MX priority"
    mx_priority.help_text = "MX priority"

    # Note: this field is NOT host, as it is the answer and not the query
    data = models.CharField(max_length=255, validators=[validate_domain_name])
    data.help_text = "IP address / Host name / Full domain name"

    def __unicode__(self):
        return u"MX %s for %s" % (self.data, str(self.zone))


class DNSMXRecordAdmin(admin.ModelAdmin):
    list_display = ('data', 'zone', 'mx_priority')

admin.site.register(DNSMXRecord, DNSMXRecordAdmin)
