# coding: utf-8
from settings.base import *

# Try to import local settings
# To use development configuration, write in settings/personal.py:
# from settings.dev import *
try:
    from settings.personal import *
except ImportError:
    pass
