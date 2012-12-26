from django.test import TestCase
from dnsapp.models import zone


class SimpleTest(TestCase):

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
