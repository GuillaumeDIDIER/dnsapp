# coding: utf-8
# Try to import local settings which may be written in settings/personal.py.
# from .dev import *
try:
    from .personal import *
except ImportError:
    from .dev import *
