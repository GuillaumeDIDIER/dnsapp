import django_tables2 as tables
from django_tables2.utils import A  # alias for Accessor


class DNSARecordTable(tables.Table):
    host = tables.LinkColumn('dns-ip', args=[A('ip')])
    zone = tables.LinkColumn('zone', args=[A('zone')])
    ip = tables.LinkColumn('dns-ip', args=[A('ip')])

    class Meta:
        attrs = {"class": "dns"}


class DNSCNAMERecordTable(tables.Table):
    host = tables.Column()
    zone = tables.LinkColumn('zone', args=[A('zone')])
    data = tables.Column()

    class Meta:
        attrs = {"class": "dns"}


class DNSMXRecordTable(tables.Table):
    data = tables.Column()
    zone = tables.LinkColumn('zone', args=[A('zone')])
    mx_priority = tables.Column()

    class Meta:
        attrs = {"class": "dns"}


class ZoneTable(tables.Table):
    zone = tables.LinkColumn('zone', args=[A('zone')])
    soa_serial = tables.Column()
    description = tables.Column(orderable=False)

    class Meta:
        attrs = {"class": "zone"}
