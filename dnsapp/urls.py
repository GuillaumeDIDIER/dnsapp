from django.conf import settings
from django.conf.urls import patterns, include, url
from django.contrib import admin
from django.views.generic import TemplateView

import dnsapp.views

# admin.autodiscover()

handler404 = TemplateView.as_view(template_name='dnsapp/404.html')
handler500 = TemplateView.as_view(template_name='dnsapp/500.html')

urlpatterns = patterns('',
    url(r'static/(?P<path>.*)',
        'django.views.static.serve',
        {'document_root': settings.STATIC_ROOT}),
    url(r'^admin/', include(admin.site.urls)),
    url(r'^404', handler404),
    url(r'^500', handler500),
    url(r'^$', TemplateView.as_view(template_name='dnsapp/home.html'),
        name='home'),
    # A Record
    url(r'^a-records', handler404, name='arec-list'),
    # Reverse A record
    url(r'^rev-a-records', handler404, name='rarec-list'),
    # CNAME Records
    url(r'^cname-records', handler404, name='cnrec-list'),
    # MX Record
    url(r'^mx-records', handler404, name='mxrec-list'),
    # Zones
    url(r'^zones', handler404, name='zone-list'),
    # IP description
    url(r'^ip/(?P<ip>[0-9.]+)?', dnsapp.views.ip, name='dns-ip'),
)
