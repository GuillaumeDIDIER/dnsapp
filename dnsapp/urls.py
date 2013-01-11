from django.conf import settings
from django.conf.urls import patterns, include, url
from django.contrib import admin

import dnsapp.views

# admin.autodiscover()

urlpatterns = patterns('',
    url(r'static/(?P<path>.*)',
        'django.views.static.serve',
        {'document_root': settings.STATIC_ROOT}),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^404', dnsapp.views.page404),
    url(r'^500', dnsapp.views.page500),
    url(r'^$', dnsapp.views.home, name='home'),
    url(r'^about-ip', dnsapp.views.page404, name='about-ip'),
    url(r'^dns-list', dnsapp.views.page404, name='dns-list'),
    url(r'^rdns-list', dnsapp.views.page404, name='rdns-list'),
    url(r'^dns-record/(?P<ip>[a-zA-Z0-9.-]+)',
        dnsapp.views.dns_record, name='dns-record'),
)
