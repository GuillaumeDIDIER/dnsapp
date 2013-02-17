import django_tables2 as tables
from django_tables2.utils import A  # alias for Accessor


class DNSARecordTable(tables.Table):
    host = tables.LinkColumn('dns-ip', args=[A('ip')])
    zone = tables.Column()
    ip = tables.LinkColumn('dns-ip', args=[A('ip')])

    class Meta:
        attrs = {"class": "dns"}
