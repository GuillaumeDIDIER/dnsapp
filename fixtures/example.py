# coding: utf-8
"""Initial data for testing purpose"""
from dnsapp import factories

# Define 2 name servers
ns1 = factories.NameServerFactory(host=u"ns1.example.com.")
ns2 = factories.NameServerFactory(host=u"ns2.example.com.")

# Loopback on 127.0.0.0/8
lo_zone = factories.ZoneFactory(
    zone=u"loopback.example.com", soa_primary_ns=ns1)
rzone127 = factories.ReverseZoneFactory(
    ip_prefix=u"127.", soa_primary_ns=ns1, description="Zone 127/8")

# Private zones on 10.0.0.0/8, 172.16.0.0/12 and 192.168.0.0/16
pri_zone = factories.ZoneFactory(
    zone=u"private.example.com", soa_primary_ns=ns1)
rzone10= factories.ReverseZoneFactory(
   ip_prefix=u"10.", soa_primary_ns=ns1, description="Zone 10/8")
rzone172= factories.ReverseZoneFactory(
   ip_prefix=u"172.16.", soa_primary_ns=ns1, description="Zone 172.16/16")
rzone192= factories.ReverseZoneFactory(
   ip_prefix=u"192.168.", soa_primary_ns=ns1, description="Zone 192.168/16")

# Add the two nameservers to every zone
for z in lo_zone, rzone127, pri_zone, rzone10, rzone172, rzone192:
    z.nameservers.add(ns1)
    z.nameservers.add(ns2)

# Define a lot of servers in each reverse zone
zone_ip_list = [
    (lo_zone, u"127.0.0"),
    (lo_zone, u"127.0.42"),
    (pri_zone, u"10.0.0"),
    (pri_zone, u"10.13.37"),
    (pri_zone, u"172.16.42"),
    (pri_zone, u"192.168.0"),
]
for (z, ip_prefix) in zone_ip_list:
    for i in range(1, 100):
        ip = u"%s.%d" % (ip_prefix, i)
        host = u"host-%s" % (ip.replace(u".", u"-")
        factories.DNSARecordFactory(host=host, ip=ip, zone=z)

# Define CNAMEs and MX
for z, ip_prefix in (lo_zone, u"127.0.42"), (pri_zone, u"192.168.0"):
    for i in range(1, 4):
        mxhost = u"mx%d" % i
        ip = u"%s.%d" % (ip_prefix, i)
        data = u"host-%s" % (ip.replace(u".", u"-"))
        factories.DNSCNAMERecordFactory(host=mxhost, data=data, zone=z)
        factories.DNSMXRecordFactory(data=mxhost, mx_priority=i * 10, zone=z)
