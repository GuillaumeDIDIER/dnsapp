from django.shortcuts import render_to_response as django_render_to_response
from django.template import RequestContext

from dnsapp.models import ReverseZone, DNSARecord


def ip_address_processor(request):
    ip = request.META['REMOTE_ADDR']
    context = {'remote_ip': ip}
    try:
        context['remote_zone'] = ReverseZone.objects.get_by_ip(ip)
    except ReverseZone.DoesNotExist:
        pass
    try:
        context['remote_record'] = DNSARecord.objects.get(ip=ip)
    except DNSARecord.DoesNotExist:
        pass
    return context


def render(request, template_name, dictionary=None):
    context = RequestContext(
        request,
        dictionary if dictionary is not None else {},
        [ip_address_processor])
    return django_render_to_response(template_name, context_instance=context)


def page404(request):
    return render(request, 'dnsapp/404.html')


def page500(request):
    return render(request, 'dnsapp/500.html')


def home(request):
    return render(request, 'dnsapp/home.html')


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
    return render(request, 'dnsapp/ip.html', context)
