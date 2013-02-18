import factory
from . import models
from .models.reverse_zone import ptr2ip, ip2ptr


class NameServerFactory(factory.Factory):
    FACTORY_FOR = models.NameServer

    host = factory.Sequence(lambda n: u"ns%s.example.com." % n)


class ZoneFactory(factory.Factory):
    FACTORY_FOR = models.Zone

    zone = factory.Sequence(lambda n: u"local-%s.example.com." % n)
    description = factory.LazyAttribute(lambda z: z.zone)
    soa_primary_ns = factory.SubFactory(NameServerFactory,
                                        host=u"ns.example.com.")
    soa_resp_person = u"root.example.com"


class ReverseZoneFactory(ZoneFactory):
    FACTORY_FOR = models.ReverseZone

    @classmethod
    def _prepare(cls, create, **kwargs):
        ip_prefix = kwargs.pop('ip_prefix', u"127.")
        if 'zone' not in kwargs or ptr2ip(kwargs['zone']) is None:
            kwargs['zone'] = ip2ptr(ip_prefix)
        zone = super(ReverseZoneFactory, cls)._prepare(create, **kwargs)
        zone.ip_prefix = ptr2ip(zone.zone)
        if create:
            zone.save()
        return zone


class DNSRecordFactory(factory.DjangoModelFactory):
    FACTORY_FOR = models.DNSRecord

    zone = factory.SubFactory(ZoneFactory)


class DNSARecordFactory(DNSRecordFactory):
    FACTORY_FOR = models.DNSARecord

    host = factory.Sequence(lambda n: u"host-%s" % n)
    ip = factory.Sequence(lambda n: u"127.%s.%s.%s" %
                          ((int(n) / 65536) % 256,
                           (int(n) / 256) % 256,
                           int(n) % 256))
    rev_host = factory.LazyAttribute(lambda r: r.rev_zone.ip2host(r.ip))
    rev_zone = factory.LazyAttribute(
        lambda r: models.ReverseZone.objects.get_by_ip(r.ip))


class DNSCNAMERecordFactory(DNSRecordFactory):
    FACTORY_FOR = models.DNSCNAMERecord

    host = factory.Sequence(lambda n: u"alias-%s" % n)
    data = factory.Sequence(lambda n: u"host-%s.example.com." % n)


class DNSMXRecordFactory(DNSRecordFactory):
    FACTORY_FOR = models.DNSMXRecord

    mx_priority = 10
    data = factory.Sequence(lambda n: u"mx-%s.example.com." % n)
