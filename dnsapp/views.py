from django.core.exceptions import ValidationError
from django.core.urlresolvers import reverse
from django.db import IntegrityError
from django.http import HttpResponseRedirect
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.views.generic import DetailView
from django_tables2 import SingleTableView

from dnsapp.models import \
    ReverseZone, DNSARecord, DNSCNAMERecord, DNSMXRecord, Zone
from dnsapp.models.name_server import validate_host_name
from dnsapp.tables import \
    DNSARecordTable, DNSCNAMERecordTable, DNSMXRecordTable, ZoneTable
from dnsapp.utils.digg_pagination import DiggPaginator


def ip_view(request, ip=None, error_message=None):
    remote_ip = request.META['REMOTE_ADDR']
    if not ip:
        ip = remote_ip
    context = {'ip': ip}

    # Display error messages
    if error_message:
        context['error_message'] = error_message

    # Need zones list in remote IP configuration
    if ip == remote_ip:
        # TODO: remove reverse zones
        context['zones'] = [z.zone for z in Zone.objects.all()]

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


def set_remote_name(request):
    """Change the domain name of the remote IP address"""
    remote_ip = request.META['REMOTE_ADDR']
    if 'host' not in request.POST or 'zone' not in request.POST:
        return ip_view(request, remote_ip)
    newhost = request.POST['host'].strip()
    if newhost:
        # Validate new host value
        try:
            validate_host_name(newhost)
        except ValidationError:
            return ip_view(request, remote_ip, u"Invalid host name")

        # Add or modify record
        try:
            record = DNSARecord.objects.get(ip=remote_ip)
        except DNSARecord.DoesNotExist:
            record = DNSARecord(ip=remote_ip)

        record.host = newhost
        try:
            record.zone = Zone.objects.get(zone=request.POST['zone'])
        except Zone.DoesNotExist as e:
            return ip_view(request, remote_ip, str(e))

        try:
            record.fill_missing()
            record.full_clean()
            record.save()
        except (ValidationError, IntegrityError) as e:
            return ip_view(request, remote_ip, str(e))
    else:
        # Delete record
        try:
            record = DNSARecord.objects.get(ip=remote_ip)
            record.delete()
        except DNSARecord.DoesNotExist:
            pass

    return HttpResponseRedirect(reverse('dnsapp.views.ip_view'))


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

    def get_context_data(self, **kwargs):
        context = super(ZoneDetailView, self).get_context_data(**kwargs)
        context['mx_records'] = DNSMXRecord.objects.filter(zone=self.object)
        return context
