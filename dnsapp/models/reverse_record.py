from django.contrib import admin
from django.db import models

from dnsapp.models.dns_record import DNSRecord


class ReverseRecord(DNSRecord):
    class Meta:
        db_table = 'reverse_dns'
        app_label = 'dnsapp'

admin.site.register(ReverseRecord)
