from django.test import TestCase
from dnsapp.models import ReverseZone, zone
from dnsapp import factories


class ReverseZoneTest(TestCase):
    multi_db = True

    def setUp(self):
        # Create dynamic fixtures
        localns = factories.NameServerFactory(host="ns.example.com")
        self.zone = factories.ZoneFactory(
            zone=u"local.example.com",
            soa_primary_ns=localns)
        self.revzone = factories.ReverseZoneFactory(
            ip_prefix=u"127.",
            soa_primary_ns=localns)

    def test_get_by_ip(self):
        # Test normal call
        self.assertEquals(
            ReverseZone.objects.get_by_ip('127.0.0.1'),
            self.revzone)
        # Test erroneous call
        self.assertRaises(
            ReverseZone.DoesNotExist,
            ReverseZone.objects.get_by_ip, '127.0.0')

    def test_host2ip(self):
        # Test normal call
        self.assertEquals(self.revzone.host2ip('42.0.0'), '127.0.0.42')
        # Test invalid resulting IP
        self.assertIsNone(self.revzone.host2ip('42.0'))
        self.assertIsNone(self.revzone.host2ip('42.0a'))

    def test_ip2host(self):
        # Test normal call
        self.assertEquals(self.revzone.ip2host('127.0.0.42'), '42.0.0')
        # Test invalid IP
        self.assertIsNone(self.revzone.ip2host('127.0.42'))
        self.assertIsNone(self.revzone.ip2host('127.0.0.42a'))


class ZoneTest(TestCase):

    def test_zone_serial2tuple(self):
        """Test serial2tuple function"""
        self.assertEqual(zone.serial2tuple(1337011342), (1337, 1, 13, 42))

    def test_zone_tuple2serial(self):
        """Test tuple2serial function"""
        self.assertEqual(zone.tuple2serial(1337, 1, 13, 42), 1337011342)

    def test_zone_increment_serial(self):
        """Test increment_serial function"""
        # Test today serial
        today_serial = zone.increment_serial()
        self.assertEqual(today_serial % 100, 0, "NN is not 00")
        next_serial = zone.increment_serial(today_serial)
        if next_serial == today_serial + 100:
            # Day change event, restart test
            today_serial = zone.increment_serial()
            next_serial = zone.increment_serial(today_serial)
        self.assertEqual(next_serial, today_serial + 1)
