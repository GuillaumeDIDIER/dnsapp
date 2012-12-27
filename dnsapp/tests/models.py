from django.test import TestCase
from dnsapp.models import ReverseZone, reverse_zone, zone


class ReverseZoneTest(TestCase):
    fixtures = ['tests.json']
    multi_db = True

    def setUp(self):
        self.revzone127 = ReverseZone.objects.get(ip_prefix='127.')

    def test_ptr2ip(self):
        # Valid calls
        self.assertEquals(reverse_zone.ptr2ip('4.3.2.1.in-addr.arpa'),
                          '1.2.3.4')
        self.assertEquals(reverse_zone.ptr2ip('42.in-addr.arpa.'), '42.')
        self.assertEquals(reverse_zone.ptr2ip('42.in-addr.arpa'), '42.')
        self.assertEquals(reverse_zone.ptr2ip('1.42.in-addr.arpa'), '42.1.')
        # Invalid calls
        self.assertIsNone(reverse_zone.ptr2ip('.1.in-addr.arpa'))
        self.assertIsNone(reverse_zone.ptr2ip('2..1.in-addr.arpa'))
        self.assertIsNone(reverse_zone.ptr2ip('5.4.3.2.1.in-addr.arpa'))
        self.assertIsNone(reverse_zone.ptr2ip('4.3.2.1a.in-addr.arpa'))

    def test_ip2ptr(self):
        # Valid calls
        self.assertEquals(reverse_zone.ip2ptr('1.2.3.4'),
                          '4.3.2.1.in-addr.arpa')
        self.assertEquals(reverse_zone.ip2ptr('42.'), '42.in-addr.arpa')
        self.assertEquals(reverse_zone.ip2ptr('42.1.'), '1.42.in-addr.arpa')
        # Invalid calls
        self.assertIsNone(reverse_zone.ip2ptr('.1.'))
        self.assertIsNone(reverse_zone.ip2ptr('1..2'))
        self.assertIsNone(reverse_zone.ip2ptr('1.2.3.4.5'))
        self.assertIsNone(reverse_zone.ip2ptr('1.2.3.4a'))

    def test_get_by_ip(self):
        # Test normal call
        self.assertEquals(
            ReverseZone.objects.get_by_ip('127.0.0.1'),
            self.revzone127)
        # Test erroneous call
        self.assertRaises(
            ReverseZone.DoesNotExist,
            ReverseZone.objects.get_by_ip, '127.0.0')

    def test_host2ip(self):
        # Test normal call
        self.assertEquals(self.revzone127.host2ip('42.0.0'), '127.0.0.42')
        # Test invalid resulting IP
        self.assertIsNone(self.revzone127.host2ip('42.0'))
        self.assertIsNone(self.revzone127.host2ip('42.0a'))

    def test_ip2host(self):
        # Test normal call
        self.assertEquals(self.revzone127.ip2host('127.0.0.42'), '42.0.0')
        # Test invalid IP
        self.assertIsNone(self.revzone127.ip2host('127.0.42'))
        self.assertIsNone(self.revzone127.ip2host('127.0.0.42a'))


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
