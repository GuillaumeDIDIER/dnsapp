# coding: utf-8
from dnsapp import factories

ns1 = factories.NameServerFactory(host=u"heol.polytechnique.fr.")
ns2 = factories.NameServerFactory(host=u"frankiz.polytechnique.fr.")

eleves = factories.ZoneFactory(
    zone=u"eleves.polytechnique.fr",
    description=u"Zone élèves",
    soa_primary_ns=ns1,
    soa_resp_person=u"root.frankiz.polytechnique.fr")
eleves.nameservers.add(ns1)
eleves.nameservers.add(ns2)

rzone201 = factories.ReverseZoneFactory(
    ip_prefix=u"129.104.201.",
    description=u"Bataclan et bâtiment binet",
    soa_primary_ns=ns1,
    soa_resp_person=u"root.frankiz.polytechnique.fr")
rzone201.nameservers.add(ns1)
rzone201.nameservers.add(ns2)

factories.DNSARecordFactory(host=u"frankiz", ip=u"129.104.201.51", zone=eleves)
factories.DNSARecordFactory(host=u"heol", ip=u"129.104.201.53", zone=eleves)
factories.DNSCNAMERecordFactory(host=u"fkz", data="frankiz", zone=eleves)
factories.DNSMXRecordFactory(data=u"frankiz", mx_priority=10, zone=eleves)
factories.DNSMXRecordFactory(data=u"heol", mx_priority=20, zone=eleves)
