from django.conf import settings
from django.conf.urls import patterns, include, url
from django.contrib import admin

import dnsapp.views

# admin.autodiscover()

handler404 = dnsapp.views.page404
handler500 = dnsapp.views.page500

urlpatterns = patterns('',
    url(r'static/(?P<path>.*)',
        'django.views.static.serve',
        {'document_root': settings.STATIC_ROOT}),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^404', dnsapp.views.page404),
    url(r'^500', dnsapp.views.page500),
    url(r'^$', dnsapp.views.home, name='home'),
    url(r'^dns-list', dnsapp.views.page404, name='dns-list'),
    url(r'^rdns-list', dnsapp.views.page404, name='rdns-list'),
    url(r'^ip/(?P<ip>[0-9.]+)?', dnsapp.views.ip, name='dns-ip'),
)
