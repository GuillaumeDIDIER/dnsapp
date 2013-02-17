from django.shortcuts import render_to_response
from django.template import RequestContext
from django.views.generic import DetailView
from django_tables2 import SingleTableView

from dnsapp.models import \
    ReverseZone, DNSARecord, DNSCNAMERecord, DNSMXRecord, Zone
from dnsapp.tables import \
    DNSARecordTable, DNSCNAMERecordTable, DNSMXRecordTable, ZoneTable
from dnsapp.utils.digg_pagination import DiggPaginator


def ip(request, ip=None):
    if not ip:
        ip = request.META['REMOTE_ADDR']
    context = {'ip': ip}
    try:
        record = DNSARecord.objects.get(ip=ip)
        context['record'] = record
        context['record_revzone'] = record.rev_zone
    except DNSARecord.DoesNotExist:
        try:
            context['record_revzone'] = ReverseZone.objects.get_by_ip(ip)
        except ReverseZone.DoesNotExist:
            pass
    return render_to_response('dnsapp/ip.html', context,
                              context_instance=RequestContext(request))


class ARecordListView(SingleTableView):
    model = DNSARecord
    table_class = DNSARecordTable
    table_pagination = {'klass': DiggPaginator}


class CNAMERecordListView(SingleTableView):
    model = DNSCNAMERecord
    table_class = DNSCNAMERecordTable
    table_pagination = {'klass': DiggPaginator}


class MXRecordListView(SingleTableView):
    model = DNSMXRecord
    table_class = DNSMXRecordTable
    table_pagination = {'klass': DiggPaginator}


class ZoneListView(SingleTableView):
    model = Zone
    table_class = ZoneTable
    table_pagination = {'klass': DiggPaginator}


class ZoneDetailView(DetailView):
    model = Zone
