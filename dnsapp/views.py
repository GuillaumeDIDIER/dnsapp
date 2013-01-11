import django.shortcuts
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


def render(request, template, dictionary=None):
    ctx = RequestContext(
        request,
        dictionary if dictionary is not None else {},
        [ip_address_processor])
    return django.shortcuts.render_to_response(template, context_instance=ctx)


def page404(request):
    return render(request, 'dnsapp/404.html')


def page500(request):
    return render(request, 'dnsapp/500.html')


def home(request):
    return render(request, 'dnsapp/home.html')


def dns_record(request, ip):
    return page404(request)
