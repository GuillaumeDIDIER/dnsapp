from .base import *

DATABASES['dns'] = {
    'ENGINE': 'django.db.backends.sqlite3',
    'NAME': 'dns.db',
}
