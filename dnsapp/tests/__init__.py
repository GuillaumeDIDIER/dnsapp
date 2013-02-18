import unittest
import doctest
from .models import *
from .utils import digg_pagination, ip_address


def load_tests(loader, tests, ignore):
    tests.addTests(doctest.DocTestSuite(digg_pagination))
    tests.addTests(doctest.DocTestSuite(ip_address))
    return tests
