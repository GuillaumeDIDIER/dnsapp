from dnsapp.models import ReverseZone, DNSARecord


def remote_ip(request):
    """Add information related to the remote IP address"""
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
