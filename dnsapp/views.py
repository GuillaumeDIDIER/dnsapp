from django.shortcuts import render_to_response
from django.template import RequestContext
from django_tables2 import SingleTableView

from dnsapp.models import ReverseZone, DNSARecord
from dnsapp.tables import DNSARecordTable
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
